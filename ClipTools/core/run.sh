#!/bin/bash

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: ./transcribe.sh <Youtube Url>"
    exit 1
fi

# Run the Download script to download video and audio seperately
python ./core/download.py -u "$1" -o ./tmp/

# Copy the audio file into .wav
#

ffmpeg -i ./tmp/audio.mp3 -acodec pcm_s16le -ac 1 -ar 16000 ./tmp/output.wav

python ./core/transcribe.py 

# Convert the json file to .ass
python ./core/jsonToAss.py ./tmp/subs.json ./tmp/output.ass

# Merge the original mp3 file and mp4 into 1 video
ffmpeg -i ./tmp/video.mp4 -i ./tmp/audio.mp3 -c:v copy -c:a aac -strict experimental ./tmp/output.mp4
# Add subtitles to video
# Burining into video
ffmpeg -i ./tmp/output.mp4 -vf "ass=./tmp/output.ass" -c:a copy ./tmp/subs_output.mp4

# Converts to verticle "Movie style"
ffmpeg -i ./tmp/subs_output.mp4 -vf "crop=720:1079:(iw-720)/2:(ih-1080)/2, pad=720:1280:0:100:black" -c:a copy cropped_output.mp4

# Splits into 59 second clips
ffmpeg -i cropped_output.mp4 -c copy -map 0 -segment_time 58 -f segment output%03d.mp4

# Deletes editing files
#rm -rf ./tmp/*
