#!/bin/bash
# generate.sh — run this after adding new stories
# place this file in the same folder as index.html

STORIES_DIR="stories"
INDEX="index.html"

if [ ! -d "$STORIES_DIR" ]; then
  echo "No 'stories' folder found. Make sure your Instagram stories folder is here."
  exit 1
fi

# collect all image/video files sorted by path (chronological via YYYYMM folders)
FILES=$(find "$STORIES_DIR" -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o \
  -iname "*.png" -o -iname "*.webp" -o \
  -iname "*.mp4" -o -iname "*.mov" -o -iname "*.webm" \
\) | sort)

if [ -z "$FILES" ]; then
  echo "No media files found in '$STORIES_DIR'."
  exit 1
fi

# build the JS array lines
LINES=""
while IFS= read -r f; do
  LINES="$LINES  \"$f\",\n"
done <<< "$FILES"

# replace everything between FILES_START and FILES_END
perl -i -0pe "s|// FILES_START.*?// FILES_END|// FILES_START\n${LINES}  // FILES_END|s" "$INDEX"

COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
echo "Done — $COUNT files written to index.html"
