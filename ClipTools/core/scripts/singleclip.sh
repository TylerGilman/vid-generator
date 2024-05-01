#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: ./transcribe.sh <Youtube Url> <Start Time (HH:MM:SS)>"
  exit 1
fi

# Run the Download script to download video and audio separately
#python ./core/download.py -u "$1" -o ./tmp/

# Clip and convert video; check if operation was successful
#ffmpeg -ss "$2" -t 58 -i ./tmp/video.mp4 -c copy ./tmp/clipped_video.mp4 || { echo "Failed to clip video."; exit 1; }

# Clip and convert audio; check if operation was successful
#ffmpeg -ss "$2" -t 58 -i ./tmp/audio.mp3 -acodec pcm_s16le -ac 1 -ar 16000 ./tmp/output.wav || { echo "Failed to clip and convert audio."; exit 1; }

# Run transcription script (ensure this handles errors internally)
#python ./core/transcribe.py 

# Convert the JSON file to .ass format (ensure file exists)
#[ -f ./tmp/subs.json ] && python ./core/jsonToAss.py ./tmp/subs.json ./tmp/output.ass || { echo "Subtitle JSON not found."; exit 1; }

# Merge the clipped audio file and the clipped video into one video
#ffmpeg -i ./tmp/clipped_video.mp4 -i ./tmp/output.wav -c:v copy -c:a aac -strict experimental ./tmp/merged_output.mp4 || { echo "Failed to merge audio and video."; exit 1; }

# Add subtitles to video by burning them into the video (ensure file exists)
#[ -f ./tmp/output.ass ] && ffmpeg -i ./tmp/merged_output.mp4 -vf "ass=./tmp/output.ass" -c:a copy final_output.mp4 || { echo "Failed to add subtitles."; exit 1; }

# Converts to vertical "Movie style" (ensure file exists)
[ -f final_output.mp4 ] && ffmpeg -i final_output.mp4 -vf "crop=720:1080:(iw-720)/2:(ih-1080)/2, pad=720:1280:0:100:black" -c:a copy cropped_output.mp4 || { echo "Failed to convert to movie style."; exit 1; }

ffmpeg -i cropped_output.mp4 -ss 00:00:00 -t 00:00:58 -c copy done.mp4
# Deletes editing files
# Uncomment the following line to delete the temporary files after processing
# rm -rf ./tmp/*

