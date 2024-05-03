#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./3k_satisfyingclip.sh <YouTube URL> <Number of Clips> <Output File>"
  exit 1
fi

# Directory setup
mkdir -p ./clips
mkdir -p ./tmp

# Download video and audio (assuming script splits them)
python ./core/download_full_youtube.py -u "$1" -o ./tmp/ || {
  echo "Failed to download video."
  exit 1
}

# Merge the clipped audio file and the clipped video into one video
ffmpeg -i ./tmp/video.mp4 -i ./tmp/audio.mp3 -c:v copy -c:a aac -strict experimental ./tmp/movie.mp4 || {
  echo "Failed to merge audio and video."
  exit 1
}

# Crop the video to the desired dimensions
ffmpeg -i ./tmp/movie.mp4 -vf "crop=1215:2160:(iw-1215)/2:(ih-2160)/2" -c:v libx264 -crf 18 ./tmp/cropped.mp4 || {
  echo "Failed to crop video."
  exit 1
}

# Get the duration of the full video in seconds
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ./tmp/cropped.mp4)
DURATION=${DURATION%.*}  # Convert duration to an integer

if [[ $DURATION -lt $((10 * $2)) ]]; then  # assuming each clip needs at least 10 seconds total duration
  echo "Video is too short for the number of requested clips."
  exit 1
fi

# Cut out the requested number of clips
for i in $(seq 1 "$2"); do
  length=$(($RANDOM % 6 + 5))  # Random length between 5-10 seconds
  max_start=$((DURATION - length))
  if [[ max_start -le 0 ]]; then
    echo "Video remaining duration too short for another clip of length $length."
    break
  fi

  start=$(($RANDOM % max_start))
  ffmpeg -i ./tmp/cropped.mp4 -ss $(printf "%02d:%02d:%02d" $(($start / 3600)) $(($start % 3600 / 60)) $(($start % 60))) -t $(printf "00:00:%02d" $length) -c:v libx264 -c:a aac -preset fast -crf 22 ./clips/clip_${i}.mp4 || {
    echo "Failed to create clip $i."
    continue
  }
done

# Create a filelist.txt for concatenation
echo -n "" > filelist.txt
for f in ./clips/*.mp4; do
  echo "file '$f'" >> filelist.txt
done

# Debug: Show contents of filelist.txt to confirm files are listed correctly
cat filelist.txt

# Concatenate clips into one video
ffmpeg -f concat -safe 0 -i filelist.txt -c copy "$3" || {
  echo "Failed to concatenate clips."
  exit 1
}

# Clean up
#rm -rf ./tmp/*
#rm -rf ./clips/*

