# Photo Collage Website

## What This Is
Personal photo collage website for couple photos. Plain HTML/CSS/JS, no build step. Deploys via GitHub Pages to `https://adrianwu40-lgtm.github.io/photo-collage/`.

## Project Structure
```
index.html          — Single-page site, 3 scrolling sections of photos
css/style.css       — Flexbox layout, light green (#A8DCAB) background, responsive
js/lightbox.js      — Click-to-fullscreen viewer, Escape to close
images/             — 30 photos (JPG/JPEG)
```

## Design Details
- Vertically scrolling sections, each min-height 150vh
- Flexbox photo grid with organic vertical offsets (not a rigid grid)
- 280px square photos, 40px gaps
- Light green (#A8DCAB) background throughout
- 7 background classes available (bg-charcoal, bg-navy, bg-olive, bg-slate, bg-plum, bg-forest, bg-rust) — all currently set to #A8DCAB
- Hover: subtle scale + brightness lift
- Mobile (≤768px): 160px photos, 24px gaps, reduced padding

## Adding/Removing Photos
- **Add:** Put image in `images/`, add `<div class="photo"><img src="images/FILE.jpg" alt="" loading="lazy"></div>` inside a section's `.photo-grid`
- **Remove:** Delete the `<div>` from index.html, optionally delete the image file
- **New section:** Copy any `<section>` block, change the `bg-*` class, update image paths

## Current State
- 30 real photos across 3 sections (10 each)
- Deployed to GitHub Pages
- HEIC files already converted to JPG
