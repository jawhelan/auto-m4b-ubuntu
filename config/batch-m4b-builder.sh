#!/bin/bash
set -e

echo "🚀 Starting batch M4B builder..."

# Loop through each subfolder inside /temp
for DIR in /temp/*; do
  if [[ -d "$DIR" ]]; then
    BOOK_NAME=$(basename "$DIR")
    OUTPUT_FILE="/temp/${BOOK_NAME}.m4b"

    echo ""
    echo "📁 Processing folder: $BOOK_NAME"
    echo "🔍 Scanning for audio files..."

    # Find first MP3 or M4B for metadata
    SOURCE_FILE=$(find "$DIR" -type f \( -iname '*.mp3' -o -iname '*.m4b' \) | sort | head -n 1)
    if [[ -z "$SOURCE_FILE" ]]; then
      echo "⚠️  No MP3 or M4B files found in $DIR — skipping"
      continue
    fi

    echo "🔎 Using $SOURCE_FILE for metadata extraction..."

    # Extract metadata
    TITLE=$(ffprobe -v error -show_entries format_tags=title -of default=nw=1:nk=1 "$SOURCE_FILE")
    ALBUM=$(ffprobe -v error -show_entries format_tags=album -of default=nw=1:nk=1 "$SOURCE_FILE")
    AUTHOR=$(ffprobe -v error -show_entries format_tags=artist -of default=nw=1:nk=1 "$SOURCE_FILE")
    YEAR=$(ffprobe -v error -show_entries format_tags=date -of default=nw=1:nk=1 "$SOURCE_FILE")

    echo "📝 Metadata:"
    echo "   Title : ${TITLE:-N/A}"
    echo "   Album : ${ALBUM:-Audiobook}"
    echo "   Author: ${AUTHOR:-Unknown Author}"
    echo "   Year  : ${YEAR:-2023}"

    # Extract cover image
    COVER_IMAGE="${DIR}/cover.jpg"
    echo "🎨 Attempting to extract cover art..."
    ffmpeg -y -i "$SOURCE_FILE" -an -vcodec copy "$COVER_IMAGE" 2>/dev/null
    if [[ -s "$COVER_IMAGE" ]]; then
      echo "✅ Cover image saved to $COVER_IMAGE"
    else
      echo "⚠️  No embedded cover art found."
      COVER_IMAGE=""
    fi

    # Handle existing output
    if [[ -f "$OUTPUT_FILE" ]]; then
      echo "⚠️  Removing existing output file: $OUTPUT_FILE"
      rm "$OUTPUT_FILE"
    fi

    echo "🎧 Merging audio files in $DIR → ${BOOK_NAME}.m4b"

    # Build m4b-tool command
    CMD=(m4b-tool merge "$DIR"
      --output-file="$OUTPUT_FILE"
      --name="${TITLE:-$BOOK_NAME}"
      --album="${ALBUM:-Audiobook}"
      --artist="${AUTHOR:-Unknown Author}"
      --year="${YEAR:-2023}"
    )

    # Add cover if available
    if [[ -f "$COVER_IMAGE" ]]; then
      echo "🖼️  Adding cover to ${BOOK_NAME}"
      CMD+=(--cover "$COVER_IMAGE")
    else
      echo "⚠️  No cover found for $BOOK_NAME — proceeding without it"
    fi

    echo "🛠️  Running: ${CMD[*]}"
    if "${CMD[@]}"; then
      echo "✅ Done: ${BOOK_NAME}.m4b created successfully."
    else
      echo "❌ Failed to process $BOOK_NAME"
      echo "🔁 Command was: ${CMD[*]}"
    fi
  fi
done

echo ""
echo "🎉 All audiobooks in /temp processed successfully!"
