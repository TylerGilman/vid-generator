#!/bin/bash

# Path to the input video file
INPUT_VIDEO="./tmp/merged_output.mp4"

# Directory to save the clips
OUTPUT_DIR="./clips"
mkdir -p "$OUTPUT_DIR" # Ensure the directory exists

# Path to the timestamps file
TIMESTAMP_FILE="./tmp/timestamps.txt"

# List file for ffmpeg concat
LIST_FILE="$OUTPUT_DIR/concat_list.txt"
rm -f "$LIST_FILE"  # Remove old list file if it exists
touch "$LIST_FILE"

# Read lines from the timestamps file
mapfile -t TIMES < "$TIMESTAMP_FILE"

# Loop through each pair of start and end times
for i in "${!TIMES[@]}"; do
  # Split the time string into start and end times
  IFS=',' read -r START_TIME END_TIME <<< "${TIMES[i]}"

  # Format output file name
  OUTPUT_FILE="clip_$(printf "%02d" $((i + 1))).mp4"

  # Run FFmpeg to extract the clip
  ffmpeg -ss "$START_TIME" -to "$END_TIME" -i "$INPUT_VIDEO" -c:v copy -c:a aac -b:a 192k "$OUTPUT_DIR/$OUTPUT_FILE"

  # Append the output file to the list for concatenation
  echo "file '$OUTPUT_FILE'" >> "$LIST_FILE"
done

# Concatenate all clips
ffmpeg -f concat -safe 0 -i "$LIST_FILE" -c copy "$OUTPUT_DIR/final_output.mp4"

# Optionally, remove the individual clips and the list file
# rm -f "$OUTPUT_DIR/clip_*.mp4"
# rm -f "$LIST_FILE"

