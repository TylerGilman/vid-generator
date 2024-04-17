#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./transcribe.sh <YouTube URL> <Title> <Output Path>"
  exit 1
fi

# Run the Download script to download video and audio separately

# Run the Download script to download video and audio separately
python ./core/download.py -u "$1" -o ./tmp/

# Extract audio from the video for transcription
ffmpeg -i ./tmp/audio.mp3 -acodec pcm_s16le -ac 1 -ar 16000 ./tmp/output.wav || { echo "Failed to extract audio."; exit 1; }

# Run transcription script (ensure this handles errors internally)
python ./core/transcribe.py

# Deletes editing files
# Convert the JSON file to .ass format (ensure file exists)
[ -f ./tmp/subs.json ] && python ./core/jsonToAss.py ./tmp/subs.json ./tmp/output.ass || { echo "Subtitle JSON not found."; exit 1; }

# Add subtitles to video by burning them into the video (ensure file exists)
[ -f ./tmp/output.ass ] && ffmpeg -i ./tmp/video.mp4 -vf "ass=./tmp/output.ass" -c:a copy ./tmp/video_subs.mp4 || { echo "Failed to add subtitles."; exit 1; }

# Merge the clipped audio file and the clipped video into one video
ffmpeg -i ./tmp/video_subs.mp4 -i ./tmp/audio.mp3 -c:v copy -c:a aac -strict experimental ./tmp/merged_output.mp4 || { echo "Failed to merge audio and video."; exit 1; }


# Define intermediate file paths
AI_OUTPUT="./tmp/ai.txt"
SUBTITLES_JSON="./tmp/subs.json"

# OPENAI api to get best quotes
python3 core/chatgpt.py ./tmp/text.json ./tmp/ai.txt

# Get the timestamps associated with those quotes
python3 core/findtimebyquote.py ./tmp/subs.json ./tmp/timestamps.txt


TIMESTAMP_FILE="./tmp/timestamps.txt"
INPUT_VIDEO="./tmp/merged_output.mp4"
./core/editclips.sh INPUT_VIDEO TIMESTAMP_FILE
EDIT_OUTPUT=".clips/final_output.mp4"
# Converts to vertical "Movie style" (ensure file exists)

ffmpeg -i EDIT_OUTPUT -vf "crop=720:1080:(iw-720)/2:0, pad=720:1280:0:100:black" -c:a copy cropped_output.mp4
MOVIE_OUTPUT="tmp/movie.mp4"
ffmpeg -i cropped_output.mp4 -ss 00:00:00 -t 00:00:58 -c:v libx264 -c:a aac -preset fast -crf 22 MOVIE_OUTPUT 

# Add title
./core/title tmp/movie.mp4 "$2" "$3" 
# Deletes editing files
# Uncomment the following line to delete the temporary files after processing
# rm -rf ./tmp/*

