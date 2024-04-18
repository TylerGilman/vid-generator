#!/bin/bash

# Adds a title to the Video
# Args: file_path, Title Message
# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./title.sh <Input Path> <Title Message> <Output Path>"
  exit 1
fi


ffmpeg -i "$1" -vf "drawtext=text='$2':fontfile="./fonts/Roboto-BoldItalic.ttf":fontsize=48:fontcolor=yellow:box=1:boxcolor=black@1:x=(w-text_w)/2:y=233:enable='between(t,0,2)'" -codec:a copy "$3"
