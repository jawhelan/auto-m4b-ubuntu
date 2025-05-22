#!/bin/bash
set -e

echo "🚀 Starting Batch M4B builder: Track - Chapter."

# Ensure chapter temp work dir exists
CHAPTER_TMP="/tmp/chapter_work"
mkdir -p "$CHAPTER_TMP"

for DIR in /temp/*/; do
  [ -d "$DIR" ] || continue
  BOOK_NAME=$(basename "$DIR")
  OUTPUT_FILE="/temp/${BOOK_NAME}.m4b"
  DONE_FILE="$DIR/.done"

  if [[ -f "$DONE_FILE" ]]; then
    echo "✅ Skipping already processed: $BOOK_NAME"
    continue
  fi

  echo ""
  echo "📁 Processing: $BOOK_NAME"

  # Get list of MP3 files
  FILES=()
  while IFS= read -r -d $'\0' f; do FILES+=("$f"); done < <(find "$DIR" -maxdepth 1 -iname "*.mp3" -print0 | sort -z)

  if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "⚠️  No MP3 files found — skipping."
    continue
  fi

  # Read tags from first file
  META="${FILES[0]}"
  AUTHOR=$(ffprobe -v error -show_entries format_tags=artist -of default=nw=1:nk=1 "$META")
  ALBUM=$(ffprobe -v error -show_entries format_tags=album -of default=nw=1:nk=1 "$META")
  YEAR=$(ffprobe -v error -show_entries format_tags=date -of default=nw=1:nk=1 "$META")
  COMMENT=$(ffprobe -v error -show_entries format_tags=comment -of default=nw=1:nk=1 "$META")

  echo "🎯 Metadata:"
  echo "   Album : ${ALBUM:-$BOOK_NAME}"
  echo "   Author: ${AUTHOR:-Unknown Author}"
  echo "   Year  : ${YEAR:-2023}"
  echo "   Comment: ${COMMENT:-None}"

  # Clean chapter tmp
  rm -rf "$CHAPTER_TMP"/*
  INDEX=1
  for FILE in "${FILES[@]}"; do
    cp "$FILE" "$CHAPTER_TMP/$(printf "%03d_Chapter_%d.mp3" $INDEX $INDEX)"
    ((INDEX++))
  done

  # Cover image
  COVER_IMAGE="$DIR/cover.jpg"
  COVER_ARG=()
  if [[ -f "$COVER_IMAGE" ]]; then
    COVER_ARG=(--cover "$COVER_IMAGE")
    echo "🖼️  Cover image found."
  else
    echo "⚠️  No cover image found."
  fi

  # Run m4b-tool
  echo "🎧 Creating: $OUTPUT_FILE"
  m4b-tool merge "$CHAPTER_TMP" \
    --output-file="$OUTPUT_FILE" \
    --name="$ALBUM" \
    --album="$ALBUM" \
    --artist="$AUTHOR" \
    --year="${YEAR:-2023}" \
    --genre="Audiobook" \
    --comment="$COMMENT" \
    --use-filenames-as-chapters \
    --no-chapter-reindexing \
    "${COVER_ARG[@]}"

  # Mark as done
  echo "✅ Processed on $(date)" > "$DONE_FILE"
done

echo ""
echo "🎉 All done!"
