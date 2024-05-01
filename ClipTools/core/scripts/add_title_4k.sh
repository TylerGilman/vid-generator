#!/bin/bash

# Adds a title and an image overlay to the Video with fade effects
# Args: file_path, Title Message, font_path, png_path, Output Path
# Check if the correct number of arguments is provided
if [ "$#" -ne 5 ]; then
  echo "Usage: ./title.sh <Input Path> <Title Message> <Font Path> <PNG Path> <Output Path>"
  exit 1
fi

# Calculate fade duration in frames (assuming 25 fps, adjust accordingly)
fade_duration=1 # 1 second fade duration
fade_in_start=0    # start fade in at 0 seconds
fade_out_start=5   # start fade out at 5 seconds, for 1 second

ffmpeg -i "$1" -i "$4" -filter_complex \
"[1:v]scale=iw*2.15:ih*2.15[image]; \
 [0:v][image] overlay=x=(W-w)/2:y=500:enable='between(t,0,6)', \
 drawtext=text='$2':fontfile='$3':fontsize=52:fontcolor=black:box=0:x=(W-text_w)/2:y=680:enable='between(t,0,6)'" \
-codec:a copy "$5"

