#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./fullrun.sh <Text File Path> <Title> <Output Path>"
  exit 1
fi

# Directory for temporary files
mkdir -p ./tmp
#ffmpeg -i ./tmp/cropped_output.mp4 -c:v copy -an video.mp4


# Run the Text to Speech script to generate an MP3 from a text file
# python3 ./core/texttospeech.py -f "$1" -o "./tmp/audio.mp3" || { echo "Text to speech conversion failed."; exit 1; }

# Convert MP3 to WAV for further processing
ffmpeg -i ./tmp/audio.mp3 -acodec pcm_s16le -ac 1 -ar 16000 -fflags +genpts ./tmp/output.wav || { echo "Failed to convert MP3 to WAV."; exit 1; }

# Assuming mp4 video is already created and exists as ./tmp/video.mp4

# Run transcription script (ensure this handles errors internally)
python3 ./core/transcribe.py -i ./tmp/output.wav

# Assuming transcribe.py outputs ./tmp/subs.json

# Convert the JSON file to .ass format (ensure file exists)
[ -f ./tmp/subs.json ] && python3 ./core/jsonToAss.py ./tmp/subs.json ./tmp/output.ass || { echo "Subtitle JSON not found."; exit 1; }


# Add subtitles to video by burning them into the video (ensure file exists)
[ -f ./tmp/output.ass ] && ffmpeg -i ./tmp/video.mp4 -vf "ass=./tmp/output.ass" -c:v libx264 -preset fast -crf 22 -an ./tmp/video_subs.mp4 || { echo "Failed to add subtitles."; exit 1; }

# Merge the audio file and the subtitled video into one video
ffmpeg -i ./tmp/video_subs.mp4 -i ./tmp/audio.mp3 -c:v copy -c:a aac -strict experimental ./tmp/merged_output.mp4 || { echo "Failed to merge audio and video."; exit 1; }

ffmpeg -i ./tmp/merged_output.mp4 -ss 00:00:00 -t 00:00:58 -c:v libx264 -c:a aac -preset fast -crf 22 ./tmp/movie.mp4

# Add title
./core/add_title.sh tmp/movie.mp4 "$2" "fonts/Roboto-BoldItalic.ttf" "$3"
# Deletes editing files
# Uncomment the following line to delete the temporary files after processing
#rm -rf ./tmp/*
#rm -rf ./clips/*

