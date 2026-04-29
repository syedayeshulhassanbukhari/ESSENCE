const form = document.getElementById('createForm');
const statusEl = document.getElementById('status');
const submitButton = form ? form.querySelector('button[type="submit"]') : null;
let isSubmitting = false;

function setStatus(message, isError = false) {
  if (!statusEl) {
    return;
  }
  statusEl.textContent = message;
  statusEl.className = `status ${isError ? 'err' : 'ok'}`;
}

if (form) {
  form.addEventListener('submit', async (event) => {
  event.preventDefault();

  if (isSubmitting) {
    return;
  }

  isSubmitting = true;
  if (submitButton) {
    submitButton.disabled = true;
  }

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
  } catch (error) {
    setStatus(error.message, true);
  } finally {
    isSubmitting = false;
    if (submitButton) {
      submitButton.disabled = false;
    }
  }
  });
}
