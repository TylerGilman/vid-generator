#!/bin/bash

# Adds a title and an image overlay to the Video with fade effects
# Args: file_path, Title Message, font_path, png_path, Output Path
# Check if the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
  echo "Usage: ./title.sh <Input Path> <Title Message> <Font Path> <PNG Path> <Output Path> <Part Number>"
  exit 1
fi

ffmpeg -i "$1" -i "$4" -filter_complex \
"[1:v]scale=iw*2.15:ih*2.15[image]; \
 [0:v][image] overlay=x=(W-w)/2:y=500:enable='between(t,0,6)', \
 drawtext=text='$2':fontfile='$3':fontsize=35:fontcolor=black:x=(W-text_w)/2:y=680:enable='between(t,0,6)', \
 drawtext=text='Part $6':fontfile='$3':fontsize=55:fontcolor=black:x=(W-text_w)/2:y=(H*1/4):enable='between(t,0,6)'" \
-codec:a copy "$5"

