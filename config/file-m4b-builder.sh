#!/bin/bash
set -e

echo -e "\n🚀 Starting File M4B builder - Full name as chapter.\n"

for DIR in /temp/*; do
  [ -d "$DIR" ] || continue
  BOOK_NAME=$(basename "$DIR")
  DONE_FILE="$DIR/.done"
  OUTPUT_FILE="/temp/${BOOK_NAME}.m4b"

  # Skip if already processed
  if [ -f "$DONE_FILE" ]; then
    echo "✅ Already processed: \"$BOOK_NAME\" — skipping"
    continue
  fi

  echo -e "📁 Processing: \"$BOOK_NAME\""

  # Get first MP3 for metadata
  FIRST_MP3=$(find "$DIR" -type f -iname '*.mp3' | sort | head -n 1)
  if [ -z "$FIRST_MP3" ]; then
    echo "⚠️  No MP3 files found — skipping \"$BOOK_NAME\""
    continue
  fi

  # Extract metadata from first file only
  TITLE="Chapter 1"
  AUTHOR=$(ffprobe -v error -show_entries format_tags=artist -of default=nw=1:nk=1 "$FIRST_MP3")
  ALBUM=$(ffprobe -v error -show_entries format_tags=album -of default=nw=1:nk=1 "$FIRST_MP3")
  YEAR=$(ffprobe -v error -show_entries format_tags=date -of default=nw=1:nk=1 "$FIRST_MP3")
  COMMENT=$(ffprobe -v error -show_entries format_tags=comment -of default=nw=1:nk=1 "$FIRST_MP3")

  COVER="$DIR/cover.jpg"
  HAS_COVER=false
  [ -f "$COVER" ] && HAS_COVER=true

  # Run m4b-tool
  echo -e "🎧 Creating: \"$OUTPUT_FILE\""
  CMD=(m4b-tool merge "$DIR"
    --output-file "$OUTPUT_FILE"
    --name "$ALBUM"
    --album "$ALBUM"
    --artist "$AUTHOR"
    --year "$YEAR"
    --genre "Audiobook"
    --comment "$COMMENT"
    --no-chapter-reindexing
    --use-filenames-as-chapters
  )

  $HAS_COVER && CMD+=(--cover "$COVER")

  if "${CMD[@]}"; then
    echo "✅ Success: \"$BOOK_NAME\""
    echo "Processed on $(date)" > "$DONE_FILE"
  else
    echo "❌ Failed: \"$BOOK_NAME\""
  fi

done

echo -e "\n🎉 All audiobooks built successfully!\n"
