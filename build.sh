#!/bin/bash
set -e

cd "$(dirname "$0")"
IMG_DIR="images"

echo "=== Photo Collage Build ==="

# 1. Convert HEIC → JPG
for f in "$IMG_DIR"/*.HEIC "$IMG_DIR"/*.heic; do
  [ -f "$f" ] || continue
  base="${f%.*}"
  echo "Converting $f → ${base}.JPG"
  sips -s format jpeg "$f" --out "${base}.JPG" >/dev/null 2>&1
  rm "$f"
done

# 2. Sanitize filenames (replace spaces and special chars with underscores)
for f in "$IMG_DIR"/*; do
  [ -f "$f" ] || continue
  dir=$(dirname "$f")
  base=$(basename "$f")
  clean=$(echo "$base" | sed 's/[^a-zA-Z0-9._-]/_/g')
  if [ "$base" != "$clean" ]; then
    echo "Renaming $base → $clean"
    mv "$f" "$dir/$clean"
  fi
done

# 3. Compress large images (wider than 1200px)
for f in "$IMG_DIR"/*.JPG "$IMG_DIR"/*.JPEG "$IMG_DIR"/*.jpg "$IMG_DIR"/*.jpeg "$IMG_DIR"/*.png "$IMG_DIR"/*.PNG; do
  [ -f "$f" ] || continue
  width=$(sips -g pixelWidth "$f" 2>/dev/null | tail -1 | awk '{print $2}')
  if [ "$width" -gt 1200 ] 2>/dev/null; then
    echo "Compressing $f (${width}px → 1200px)"
    sips --resampleWidth 1200 "$f" >/dev/null 2>&1
  fi
done

# 4. Collect all images and sort
images=()
for f in "$IMG_DIR"/*.JPG "$IMG_DIR"/*.JPEG "$IMG_DIR"/*.jpg "$IMG_DIR"/*.jpeg "$IMG_DIR"/*.png "$IMG_DIR"/*.PNG; do
  [ -f "$f" ] || continue
  images+=("$(basename "$f")")
done

IFS=$'\n' images=($(sort <<<"${images[*]}")); unset IFS

total=${#images[@]}
echo "Found $total images"

if [ "$total" -eq 0 ]; then
  echo "No images found in $IMG_DIR/. Nothing to do."
  exit 0
fi

# Split into 3 sections
third=$(( (total + 2) / 3 ))
section1=("${images[@]:0:$third}")
section2=("${images[@]:$third:$third}")
section3=("${images[@]:$((third * 2))}")

# Helper: generate photo divs
photo_divs() {
  local arr=("$@")
  for img in "${arr[@]}"; do
    echo "      <div class=\"photo\"><img src=\"images/$img\" alt=\"\" loading=\"lazy\"></div>"
  done
}

# 5. Generate index.html
cat > index.html << 'HTMLHEAD'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Photo Collage</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>

  <section class="bg-navy">
    <div class="photo-grid">
HTMLHEAD

photo_divs "${section1[@]}" >> index.html

cat >> index.html << 'HTMLMID1'
    </div>
  </section>

  <section class="bg-olive">
    <div class="photo-grid">
HTMLMID1

photo_divs "${section2[@]}" >> index.html

cat >> index.html << 'HTMLMID2'
    </div>
  </section>

  <section class="bg-charcoal">
    <div class="photo-grid">
HTMLMID2

photo_divs "${section3[@]}" >> index.html

cat >> index.html << 'HTMLFOOT'
    </div>
  </section>

  <div class="lightbox">
    <img src="" alt="">
  </div>

  <script src="js/lightbox.js"></script>
</body>
</html>
HTMLFOOT

echo "Generated index.html with $total photos across 3 sections"

# 6. Commit & push
git add -A
if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "Update photos"
  git push -u origin main
  echo "Pushed to GitHub!"
fi

echo "=== Done ==="
