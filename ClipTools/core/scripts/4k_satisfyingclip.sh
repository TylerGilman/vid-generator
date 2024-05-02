#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./4k_satisfyingclip.sh <YouTube URL> <Number of Clips> <Output File>"
  exit 1
fi
# Directory setup
mkdir -p ./clips
mkdir -p ./tmp

python ./core/download_full_youtube.py -u "$1" -o ./tmp/

# Merge the clipped audio file and the clipped video into one video
ffmpeg -i ./tmp/video.mp4 -i ./tmp/audio.mp3 -c:v copy -c:a aac -strict experimental ./tmp/movie.mp4 || { echo "Failed to merge audio and video."; exit 1; }
:'
# Add blur and borders to improve resolution retention
ffmpeg -i ./tmp/movie.mp4 -vf "gblur=sigma=50" -c:a copy ./tmp/blurred.mp4
ffmpeg -i ./tmp/blurred.mp4 -vf "crop=2008:356:0:0" -c:v libx264 -crf 18 ./tmp/top_blur.mp4
ffmpeg -i ./tmp/blurred.mp4 -vf "crop=2008:356:0:2160" -c:v libx264 -crf 18 ./tmp/bottom_blur.mp4
ffmpeg -i ./tmp/movie.mp4 -vf "crop=2008:2160:(iw-2008)/2:(ih-2160)/2" -c:v libx264 -crf 18 ./tmp/cropped.mp4

ffmpeg -i ./tmp/top_blur.mp4 -i ./tmp/cropped.mp4 -i ./tmp/bottom_blur.mp4 -filter_complex "[0:v][1:v][2:v] vstack=inputs=3" -c:a copy ./tmp/edited.mp4
'
ffmpeg -i ./tmp/movie.mp4 -vf "crop=1215:2160:(iw-1215)/2:(ih-2160)/2" -c:v libx264 -crf 18 ./tmp/cropped.mp4
# Get the duration of the full video in seconds
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ./tmp/cropped.mp4)
DURATION=${DURATION%.*}  # Convert duration to an integer

# Check if the video is too short for the number of requested clips
if [[ $DURATION -lt $((15 * $1)) ]]; then  # assuming each clip needs at least 15 seconds
    echo "Video is too short for the number of requested clips."
    exit 1
fi
# Cut out the requested number of clips
for i in $(seq 1 "$2"); do
  # Generate a random clip length between 5-10 seconds
  length=$(($RANDOM % 5 + 5))
  
  # Ensure the clip fits within the remaining duration
  max_start=$((DURATION - length))
  if [[ max_start -le 0 ]]; then
    echo "Video remaining duration too short for another clip of length $length."
    break
  fi

  start=$(($RANDOM % max_start))

  # Format start time as HH:MM:SS
  hours=$(($start / 3600))
  mins=$(($start % 3600 / 60))
  secs=$(($start % 60))
  start_time=$(printf "%02d:%02d:%02d" $hours $mins $secs)

  ffmpeg -i ./tmp/cropped.mp4 -ss $start_time -t 00:00:$length -c:v libx264 -c:a aac -preset fast -crf 22 ./clips/clip_${i}.mp4
done

# After generating clips
echo "Files in clips directory:"
ls -l ./clips/

# Create a filelist.txt for concatenation
> filelist.txt
for f in ./clips/*.mp4; do 
  if [ -f "$f" ]; then
    echo "file '$f'" >> filelist.txt
  else
    echo "No clips found."
    exit 1
  fi
done

# Check filelist.txt before attempting to concatenate
echo "Contents of filelist.txt:"
#cat filelist.txt

# Concatenate clips into one video
ffmpeg -f concat -safe 0 -i filelist.txt -c copy "$3" 

# Clean up if necessary
rm -rf ./tmp/*
rm -rf ./clips/*

