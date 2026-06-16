const form = document.getElementById('createForm');
const statusEl = document.getElementById('status');
const submitButton = form ? form.querySelector('button[type="submit"]') : null;
const imageInput = document.getElementById('image');
const imagePreview = document.getElementById('imagePreview');
const uploadIcon = document.getElementById('uploadIcon');
const uploadTitle = document.getElementById('uploadTitle');
const uploadSub = document.getElementById('uploadSub');
const ownerIdInput = document.getElementById('ownerId');
const signInBtn = document.getElementById('signInBtn');
const signOutBtn = document.getElementById('signOutBtn');
const authMeta = document.getElementById('authMeta');
const authCopy = document.getElementById('authCopy');

let isSubmitting = false;
let auth = null;
let googleProvider = null;

setSubmitEnabled(false);

function setSubmitEnabled(enabled) {
  if (submitButton) {
    submitButton.disabled = !enabled || isSubmitting;
  }
}

async function loadUserListings(userId) {
  if (!userId) {
    const section = document.getElementById('yourListingsSection');
    if (section) {
      section.style.display = 'none';
    }
    return;
  }

  try {
    const response = await fetch('/api/exchange-listings', { cache: 'no-store' });
    if (!response.ok) {
      return;
    }

    const allListings = await response.json();
    const userListings = Array.isArray(allListings)
      ? allListings.filter(listing => listing.ownerId === userId)
      : [];

    const section = document.getElementById('yourListingsSection');
    const container = document.getElementById('listingsContainer');

    if (!section || !container) {
      return;
    }

    if (userListings.length === 0) {
      section.style.display = 'none';
      return;
    }

    section.style.display = 'block';
    container.innerHTML = userListings
      .map(
        (listing) => `
          <div class="listing-card">
            <img src="${listing.imageUrl || '/uploads/placeholder.jpg'}" alt="${listing.name}" class="listing-image" />
            <h3 class="listing-name">${listing.name || 'Untitled'}</h3>
            <p class="listing-price">$${Number(listing.price || 0).toFixed(2)}</p>
            <div class="listing-actions">
              <button type="button" class="listing-delete-btn" onclick="deleteListing('${listing.id}')">DELETE</button>
            </div>
          </div>
        `
      )
      .join('');
  } catch (error) {
    console.error('Failed to load user listings:', error);
  }
}

async function deleteListing(listingId) {
  if (!listingId || !confirm('Delete this listing? This cannot be undone.')) {
    return;
  }

  try {
    const response = await fetch(`/api/exchange-listings/${listingId}`, {
      method: 'DELETE',
      headers: {
        'x-admin-password': 'admin123',
      },
    });

    if (!response.ok) {
      setStatus('Failed to delete listing.', true);
      return;
    }

    setStatus('Listing deleted successfully.');
    if (auth && auth.currentUser) {
      await loadUserListings(auth.currentUser.uid);
    }
  } catch (error) {
    setStatus(error.message || 'Delete failed.', true);
  }
}

function updateAuthUi(user) {
  if (!ownerIdInput) {
    return;
  }

  if (user) {
    ownerIdInput.value = user.uid;
    if (authMeta) {
      authMeta.textContent = `Signed in as ${user.email || user.displayName || user.uid}`;
    }
    if (authCopy) {
      authCopy.textContent = 'Your seller UID is linked automatically to each listing.';
    }
    if (signInBtn) {
      signInBtn.style.display = 'none';
    }
    if (signOutBtn) {
      signOutBtn.style.display = 'inline-flex';
    }
    setSubmitEnabled(true);
    loadUserListings(user.uid);
    return;
  }

  ownerIdInput.value = '';
  if (authMeta) {
    authMeta.textContent = 'Not signed in.';
  }
  if (authCopy) {
    authCopy.textContent = 'Connect your Firebase account so every upload is tied to your seller UID.';
  }
  if (signInBtn) {
    signInBtn.style.display = 'inline-flex';
  }
  if (signOutBtn) {
    signOutBtn.style.display = 'none';
  }
  const section = document.getElementById('yourListingsSection');
  if (section) {
    section.style.display = 'none';
  }
  setSubmitEnabled(false);
}

function initFirebaseAuth() {
  if (!window.firebase || !window.__FIREBASE_CONFIG__) {
    if (authMeta) {
      authMeta.textContent = 'Firebase auth unavailable in this browser session.';
    }
    setSubmitEnabled(false);
    return;
  }

  if (!firebase.apps.length) {
    firebase.initializeApp(window.__FIREBASE_CONFIG__);
  }

  auth = firebase.auth();
  googleProvider = new firebase.auth.GoogleAuthProvider();

  auth.onAuthStateChanged((user) => {
    updateAuthUi(user);
  });
}

async function signInWithGoogle() {
  if (!auth || !googleProvider) {
    setStatus('Firebase auth is unavailable.', true);
    return;
  }

  try {
    await auth.signInWithPopup(googleProvider);
  } catch (error) {
    setStatus(error.message || 'Sign-in failed.', true);
  }
}

async function signOut() {
  if (!auth) {
    return;
  }

  try {
    await auth.signOut();
  } catch (error) {
    setStatus(error.message || 'Sign-out failed.', true);
  }
}

initFirebaseAuth();

if (signInBtn) {
  signInBtn.addEventListener('click', signInWithGoogle);
}

if (signOutBtn) {
  signOutBtn.addEventListener('click', signOut);
}

if (imageInput) {
  imageInput.addEventListener('change', (event) => {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = function (e) {
        if (imagePreview) {
          imagePreview.src = e.target.result;
          imagePreview.style.display = 'block';
        }
        if (uploadIcon) uploadIcon.style.display = 'none';
        if (uploadTitle) uploadTitle.style.display = 'none';
        if (uploadSub) uploadSub.style.display = 'none';
      }
      reader.readAsDataURL(file);
    } else {
      if (imagePreview) {
        imagePreview.src = '';
        imagePreview.style.display = 'none';
      }
      if (uploadIcon) uploadIcon.style.display = 'block';
      if (uploadTitle) uploadTitle.style.display = 'block';
      if (uploadSub) uploadSub.style.display = 'block';
    }
  });
}

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

        loadUserListings(auth.currentUser.uid);
      setStatus('Listing uploaded successfully.');
      form.reset();
      if (auth && auth.currentUser && ownerIdInput) {
        ownerIdInput.value = auth.currentUser.uid;
      }
      if (imagePreview) {
        imagePreview.src = '';
        imagePreview.style.display = 'none';
      }
      if (uploadIcon) uploadIcon.style.display = 'block';
      if (uploadTitle) uploadTitle.style.display = 'block';
      if (uploadSub) uploadSub.style.display = 'block';
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
