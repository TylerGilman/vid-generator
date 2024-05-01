#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./fullrun.sh <Text File Path> <Title> <Output Path>"
  exit 1
fi

# Directory for temporary files
mkdir -p ./tmp
mkdir -p ./output


# Assuming the audio file is already generated and available at ./tmp/audio.mp3
# Assuming the original video is at ./tmp/video.mp4

# Run the Text to Speech script to generate an MP3 from a text file
# python3 ./core/texttospeech.py -f "$1" -o "./inputs/audio.mp3" || { echo "Text to speech conversion failed."; exit 1; }

# Convert MP3 to WAV for further processing
ffmpeg -i ./inputs/audio.mp3 -acodec pcm_s16le -ac 1 -ar 16000 -fflags +genpts ./tmp/output.wav || { echo "Failed to convert MP3 to WAV."; exit 1; }

# Get durations in seconds
audio_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ./inputs/audio.mp3 | bc)
video_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ./inputs/video.mp4 | bc)

# Check if video needs to be looped to match or exceed the audio duration
if (( $(echo "$video_duration < $audio_duration" | bc -l) )); then
    # Calculate number of loops required to exceed audio duration
    loop_count=$(echo "($audio_duration / $video_duration) + 1" | bc)
    # Create a temporary file listing for ffmpeg loop
    echo "" > ./tmp/filelist.txt  # Clear file list
    for i in $(seq 1 $loop_count); do
        echo "file '$PWD/inputs/video.mp4'" >> ./tmp/filelist.txt
    done
    # Loop the video
    ffmpeg -f concat -safe 0 -i ./tmp/filelist.txt -c copy ./tmp/looped_video.mp4
    # Trim the looped video to match the audio duration
    ffmpeg -i ./tmp/looped_video.mp4 -t $audio_duration -c copy ./tmp/trimmed_video.mp4
elif (( $(echo "$video_duration > $audio_duration" | bc -l) )); then
    # If video is longer, just trim it
    ffmpeg -i ./inputs/video.mp4 -t $audio_duration -c copy ./tmp/trimmed_video.mp4
else
    # If durations match, use the original video for merging
    cp ./inputs/video.mp4 ./tmp/trimmed_video.mp4
fi


# Run transcription script (ensure this handles errors internally)
python3 ./core/transcribe_audio.py -i ./tmp/output.wav


# Define font path
font_path="./fonts/Mont.ttf"

# Convert the JSON file to .ass format and specify the font (ensure file exists)
[ -f ./tmp/subs.json ] && python3 ./core/jsonToAss.py "$font_path" || { echo "Subtitle JSON not found."; exit 1; }

# Add subtitles to the trimmed video
[ -f ./tmp/output.ass ] && ffmpeg -i ./tmp/trimmed_video.mp4 -vf "ass=./tmp/output.ass" -c:v libx264 -preset fast -crf 22 -an ./tmp/video_subs.mp4 || { echo "Failed to add subtitles."; exit 1; }

# Merge the audio file and the subtitled video into one video
ffmpeg -i ./tmp/video_subs.mp4 -i ./inputs/audio.mp3 -c:v copy -c:a aac -strict experimental ./tmp/merged_output.mp4 || { echo "Failed to merge audio and video."; exit 1; }

# Add title
./core/add_title.sh ./tmp/merged_output.mp4 "$2" "fonts/Montserrat-ExtraBoldItalic.ttf" "$3"

# Split the final video into segments of 55 seconds each
output_path=$3
output_dir="./output"
output_base=$(basename "$output_path" .mp4)

segment_duration=55
ffmpeg -i "./tmp/merged_output.mp4" -c copy -map 0 -segment_time $segment_duration -f segment -reset_timestamps 1 "${output_dir}/${output_base}%d.mp4" || { echo "Failed to split video into segments."; exit 1; }

# Clean up temporary files
# Uncomment the following lines to delete the temporary files after processing
#rm -rf ./tmp/*
#rm -rf ./clips/*