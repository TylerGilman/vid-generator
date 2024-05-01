#!/bin/bash

# Adds a title to the Video
# Args: file_path, Title Message, font_path, Output Path
# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
  echo "Usage: ./title.sh <Input Path> <Title Message> <Font Path> <Output Path>"
  exit 1
fi

ffmpeg -i "$1" -vf "drawtext=text='$2':fontfile='$3':fontsize=50:fontcolor=black:box=1:boxcolor=white@1:x=(w-text_w)/2:y=233:enable='between(t,0,2)'" -codec:a copy "$4"
