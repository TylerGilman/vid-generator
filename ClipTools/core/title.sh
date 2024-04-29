#!/bin/bash

# Adds a title to the Video
# Args: file_path, Title Message, Output Path
# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./title.sh <Input Path> <Title Message> <Output Path>"
  exit 1
fi

# Maximum text width in pixels (e.g., 80% of video width)
MAX_TEXT_WIDTH=0.8

INPUT="$1"
TEXT="$2"
OUTPUT="$3"

# Fetch video width
WIDTH=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=s=x:p=0 "$INPUT")

# Calculate max allowed text width in pixels
MAX_PIXELS=$(echo "$WIDTH * $MAX_TEXT_WIDTH" | bc)

# Define initial font size
FONT_SIZE=72

# Function to calculate text width based on font size
function calc_text_width() {
  echo $(ffmpeg -hide_banner -loglevel error -f lavfi -i color=c=black:s=1920x1080 -vf "drawtext=text='$TEXT':fontfile=./fonts/Roboto-BoldItalic.ttf:fontsize=$1:fontcolor=black" -vframes 1 -f rawvideo -pix_fmt rgb24 - 2>/dev/null | strings | grep -aEo 'w=[0-9]+' | cut -d'=' -f2)
}

# Calculate text width with initial font size TEXT_WIDTH=$(calc_text_width $FONT_SIZE)
# Reduce font size until text width is within the maximum width
while [ "$TEXT_WIDTH" -gt "$MAX_PIXELS" ]; do
  FONT_SIZE=$((FONT_SIZE-1))
  TEXT_WIDTH=$(calc_text_width $FONT_SIZE)
done

# Apply text with calculated font size
ffmpeg -i "$INPUT" -vf "drawtext=text='$TEXT':fontfile=./fonts/Roboto-BoldItalic.ttf:fontsize=$FONT_SIZE:fontcolor=black:box=1:boxcolor=white@1:boxborderw=10:x=(w-text_w)/2:y=233:enable='between(t,0,6)'" -codec:a copy "$OUTPUT"
