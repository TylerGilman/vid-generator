#!/bin/bash

# Adds a title and an image overlay to the Video with fade effects
# Args: file_path, Title Message, font_path, png_path, Output Path
# Check if the correct number of arguments is provided
if [ "$#" -ne 5 ]; then
  echo "Usage: ./title.sh <Input Path> <Title Message> <Font Path> <PNG Path> <Output Path>"
  exit 1
fi

ffmpeg -i "$1" -i "$4" -filter_complex \
"[1:v]scale=iw*1:ih*1[image]; \
 [0:v][image] overlay=x=(W-w)/2:y=500, \
 drawtext=text='$2':fontfile='$3':fontsize=30:fontcolor=black:x=(W-text_w)/2:y=700" \
-codec:a copy "$5"

