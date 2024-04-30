#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./fullrun.sh <YouTube URL> <Title> <Output Path>"
  exit 1
fi

# Run the Download script to download video and audio separately
python3 ./core/download.py -u "$1" -o ./tmp/

# Extract audio from the video for transcription
ffmpeg -i ./tmp/audio.mp3 -acodec pcm_s16le -ac 1 -ar 16000 ./tmp/output.wav || { echo "Failed to extract audio."; exit 1; }

# default output locations
#outfileResults = "./tmp/subs.json"
#outfileText = "./tmp/text.json"
# Run transcription script (ensure this handles errors internally)
python3 ./core/transcribe.py -i ./tmp/output.wav

# Deletes editing files
# Convert the JSON file to .ass format (ensure file exists)
[ -f ./tmp/subs.json ] && python3 ./core/jsonToAss.py ./tmp/subs.json ./tmp/output.ass || { echo "Subtitle JSON not found."; exit 1; }

# Add subtitles to video by burning them into the video (ensure file exists)
[ -f ./tmp/output.ass ] && ffmpeg -i ./tmp/video.mp4 -vf "ass=./tmp/output.ass" -c:a copy ./tmp/video_subs.mp4 || { echo "Failed to add subtitles."; exit 1; }

# Merge the clipped audio file and the clipped video into one video
ffmpeg -i ./tmp/video_subs.mp4 -i ./tmp/audio.mp3 -c:v copy -c:a aac -strict experimental ./tmp/merged_output.mp4 || { echo "Failed to merge audio and video."; exit 1; }


# OPENAI api to get best quotes
python3 core/chatgpt.py -i ./tmp/text.json -o ./tmp/ai.txt

# Get the timestamps associated with those quotes
python3 core/findtimebyquote.py -s ./tmp/subs.json -a ./tmp/ai.txt -o ./tmp/timestamps.txt


./core/editclips.sh ./tmp/merged_output.mp4 ./tmp/timestamps.txt
# Converts to vertical "Movie style" (ensure file exists)

# Blur crop and borders
ffmpeg -i ./clips/final_output.mp4 -vf "gblur=sigma=20" -c:a copy ./tmp/blurred.mp4

ffmpeg -i ./tmp/blurred.mp4 -vf "crop=1008:356:0:0" -c:v libx264 -crf 18 ./tmp/top_blur.mp4
ffmpeg -i ./tmp/blurred.mp4 -vf "crop=1008:356:0:1080" -c:v libx264 -crf 18 ./tmp/bottom_blur.mp4
ffmpeg -i ./clips/final_output.mp4 -vf "crop=1008:1080:(iw-900)/2:(ih-1080)/2" -c:v libx264 -crf 18 ./tmp/cropped.mp4


ffmpeg -i ./tmp/top_blur.mp4 -i ./tmp/cropped.mp4 -i ./tmp/bottom_blur.mp4 -filter_complex "[0:v][1:v][2:v] vstack=inputs=3" -c:a copy ./tmp/edited.mp4


ffmpeg -i ./tmp/edited.mp4 -ss 00:00:00 -t 00:00:58 -c:v libx264 -c:a aac -preset fast -crf 22 ./tmp/movie.mp4

# Add title
./core/title.sh tmp/movie.mp4 "$2" "$3" 
# Deletes editing files
# Uncomment the following line to delete the temporary files after processing
#rm -rf ./tmp/*
#rm -rf ./clips/*

