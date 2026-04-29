const form = document.getElementById('createForm');
const statusEl = document.getElementById('status');
const submitButton = form ? form.querySelector('button[type="submit"]') : null;
const imageInput = document.getElementById('image');
const imagePreview = document.getElementById('imagePreview');
const uploadIcon = document.getElementById('uploadIcon');
const uploadTitle = document.getElementById('uploadTitle');
const uploadSub = document.getElementById('uploadSub');

let isSubmitting = false;

if (imageInput) {
  imageInput.addEventListener('change', (event) => {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = function(e) {
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

    setStatus('Listing uploaded successfully.');
    form.reset();
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
