#!/bin/bash
set -e

echo "🚀 Starting batch M4B builder with full path safety..."

# Loop through each subdirectory in /temp
find /temp -mindepth 1 -maxdepth 1 -type d | while IFS= read -r DIR; do
  BOOK_NAME="$(basename "$DIR")"
  OUTPUT_FILE="/temp/${BOOK_NAME}.m4b"

  echo -e "\n📁 Processing: $BOOK_NAME"

  # Get sorted audio files
  mapfile -t AUDIO_FILES < <(find "$DIR" -type f -iname '*.mp3' | sort)
  if [[ ${#AUDIO_FILES[@]} -eq 0 ]]; then
    echo "⚠️  No MP3s found in \"$DIR\" — skipping"
    continue
  fi

  FIRST_FILE="${AUDIO_FILES[0]}"
  TITLE_RAW=$(ffprobe -v error -show_entries format_tags=title -of default=nw=1:nk=1 "$FIRST_FILE")
  TITLE_CLEAN=$(echo "$TITLE_RAW" | sed -E 's/^[0-9]+ - //')
  ALBUM=$(ffprobe -v error -show_entries format_tags=album -of default=nw=1:nk=1 "$FIRST_FILE")
  AUTHOR=$(ffprobe -v error -show_entries format_tags=artist -of default=nw=1:nk=1 "$FIRST_FILE")
  YEAR=$(ffprobe -v error -show_entries format_tags=date -of default=nw=1:nk=1 "$FIRST_FILE")
  COMMENT=$(ffprobe -v error -show_entries format_tags=comment -of default=nw=1:nk=1 "$FIRST_FILE")

  echo "📋 Metadata:"
  echo "   Title : ${TITLE_CLEAN}"
  echo "   Album : ${ALBUM}"
  echo "   Author: ${AUTHOR}"
  echo "   Year  : ${YEAR}"
  echo "   Genre : Audiobook"
  echo "   Comment: ${COMMENT}"

  # Extract cover image
  COVER_IMAGE="${DIR}/cover.jpg"
  ffmpeg -y -i "$FIRST_FILE" -an -vcodec copy "$COVER_IMAGE" 2>/dev/null || true
  [[ ! -s "$COVER_IMAGE" ]] && COVER_IMAGE=""

  # Build chapter list
  CHAPTER_FILE="${DIR}/chapters.txt"
  > "$CHAPTER_FILE"
  i=1
  for file in "${AUDIO_FILES[@]}"; do
    base_title=$(ffprobe -v error -show_entries format_tags=title -of default=nw=1:nk=1 "$file")
    clean_title=$(echo "$base_title" | sed -E 's/^[0-9]+ - //')
    printf "CHAPTER%02d=00:00:00.000\n" "$i" >> "$CHAPTER_FILE"
    printf "CHAPTER%02dNAME=%s\n" "$i" "$clean_title" >> "$CHAPTER_FILE"
    ((i++))
  done

  # Build command
  CMD=(m4b-tool merge)
  for f in "${AUDIO_FILES[@]}"; do
    CMD+=("$f")
  done
  CMD+=(
    --output-file="$OUTPUT_FILE"
    --name="$TITLE_CLEAN"
    --album="$ALBUM"
    --artist="$AUTHOR"
    --year="${YEAR:-2023}"
    --genre="Audiobook"
    --add-chapter-from="$CHAPTER_FILE"
  )
  [[ -n "$COMMENT" ]] && CMD+=(--comment "$COMMENT")
  [[ -f "$COVER_IMAGE" ]] && CMD+=(--cover "$COVER_IMAGE")

  echo "🎧 Running m4b-tool for: \"$BOOK_NAME\""
  if "${CMD[@]}"; then
    echo "✅ Created: \"$OUTPUT_FILE\""
  else
    echo "❌ Failed on: \"$BOOK_NAME\""
  fi

  rm -f "$CHAPTER_FILE"
done

echo -e "\n🎉 All done!"
