const lightbox = document.querySelector('.lightbox');
const lightboxImg = lightbox.querySelector('img');

document.addEventListener('click', (e) => {
  const img = e.target.closest('.photo')?.querySelector('img');
  if (!img) return;
  lightboxImg.src = img.src;
  lightbox.classList.add('active');
});

lightbox.addEventListener('click', () => {
  lightbox.classList.remove('active');
});

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    lightbox.classList.remove('active');
  }
});
