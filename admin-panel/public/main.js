const form = document.getElementById('createForm');
const statusEl = document.getElementById('status');
const listingGrid = document.getElementById('listingGrid');
const refreshBtn = document.getElementById('refreshBtn');
const adminPasswordInput = document.getElementById('adminPassword');

const PASSWORD_STORAGE_KEY = 'scentswap_admin_password';
adminPasswordInput.value = localStorage.getItem(PASSWORD_STORAGE_KEY) || '';

adminPasswordInput.addEventListener('input', () => {
  localStorage.setItem(PASSWORD_STORAGE_KEY, adminPasswordInput.value);
});

function setStatus(message, isError = false) {
  statusEl.textContent = message;
  statusEl.className = `status ${isError ? 'err' : 'ok'}`;
}

function adminHeaders() {
  const password = adminPasswordInput.value.trim();
  return {
    'x-admin-password': password,
  };
}

async function requestJson(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      ...(options.headers || {}),
      ...adminHeaders(),
    },
  });

  let payload = {};
  try {
    payload = await response.json();
  } catch (_) {
    payload = {};
  }

  if (!response.ok) {
    const message = payload.message || 'Request failed';
    throw new Error(message);
  }
  return payload;
}

function cardTemplate(item) {
  return `
    <article class="card">
      <img src="${item.imageUrl}" alt="${item.name}" />
      <div class="card-body">
        <strong>${item.name}</strong>
        <div class="tiny">Price: PKR ${Number(item.price).toFixed(2)}</div>
        <div class="tiny">${item.description}</div>
        <button class="danger" data-id="${item.id}">Delete</button>
      </div>
    </article>
  `;
}

async function loadListings() {
  try {
    const items = await requestJson('/api/exchange-listings/admin');
    if (!items.length) {
      listingGrid.innerHTML = '<p>No exchange listings yet.</p>';
      return;
    }
    listingGrid.innerHTML = items.map(cardTemplate).join('');
  } catch (error) {
    listingGrid.innerHTML = '<p>Could not load listings.</p>';
    setStatus(error.message, true);
  }
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();

  try {
    const fd = new FormData(form);
    const response = await fetch('/api/exchange-listings', {
      method: 'POST',
      body: fd,
    });

    const payload = await response.json();
    if (!response.ok) {
      throw new Error(payload.message || 'Upload failed');
    }

    setStatus('Listing uploaded successfully.');
    form.reset();
    await loadListings();
  } catch (error) {
    setStatus(error.message, true);
  }
});

refreshBtn.addEventListener('click', loadListings);

listingGrid.addEventListener('click', async (event) => {
  const button = event.target.closest('button[data-id]');
  if (!button) {
    return;
  }

  const id = button.dataset.id;
  if (!id) {
    return;
  }

  const shouldDelete = window.confirm('Delete this listing?');
  if (!shouldDelete) {
    return;
  }

  try {
    await requestJson(`/api/exchange-listings/${id}`, { method: 'DELETE' });
    setStatus('Listing deleted.');
    await loadListings();
  } catch (error) {
    setStatus(error.message, true);
  }
});

loadListings();
