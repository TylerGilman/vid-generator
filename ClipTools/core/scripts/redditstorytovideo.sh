#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: ./fullrun.sh <Text File Path> <Title> <Output Path>"
  exit 1
fi
# Directory for temporary files
mkdir -p ./tmp
mkdir -p ./output

# Title 
# Generate audio from title text
# Write the title text to a file
echo "$2" > ./tmp/title_text.txt
#python3 ./core/texttospeech.py -f ./tmp/title_text.txt -o "./tmp/title_audio.mp3" || { echo "Text to speech conversion failed."; exit 1; }

# Speed up the audio
ffmpeg -i ./tmp/title_audio.mp3 -filter:a "atempo=1" -vn ./tmp/spedup_title_audio.mp3 || { echo "Failed to speed up audio."; exit 1; }

# Get the duration of the sped-up audio
audio_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ./tmp/spedup_title_audio.mp3)
audio_duration=$(printf "%.0f" "$audio_duration")  # Convert to an integer


# Get the total duration of the input video
input_video_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ./inputs/video.mp4)
input_video_duration=$(printf "%.0f" "$input_video_duration")  # Convert to an integer

# Check and print the durations for debugging
echo "Audio Duration: $audio_duration"
echo "Buffer Duration: $buffer_duration"
echo "Total Title Duration: $total_duration"
echo "Input Video Duration: $input_video_duration"

# Calculate remaining video duration
if (( total_duration < input_video_duration )); then
    remaining_duration=$((input_video_duration - audio_duration))
else
    echo "Error: Title video duration exceeds input video length."
    exit 1
fi

echo "Remaining Duration: $remaining_duration"

ffmpeg -i ./inputs/video.mp4 -i ./tmp/spedup_title_audio.mp3 -t $audio_duration -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -strict experimental ./tmp/untitled_intro.mp4 || { echo "Failed to create title video."; exit 1; }

# Create the second video starting right after the first ends
ffmpeg -ss $audio_duration -i ./inputs/video.mp4 -t $input_video_duration -c copy ./tmp/trimmed_video.mp4 || { echo "Failed to trim the remaining video."; exit 1; }

./core/scripts/add_title_4k.sh ./tmp/untitled_intro.mp4 "$2" ./fonts/ElevateSans.ttf ./inputs/reddit.png ./tmp/titled_intro.mp4    




# Assuming the audio file is already generated and available at ./tmp/audio.mp3
# Assuming the original video is at ./tmp/video.mp4
# Run the Text to Speech script to generate an MP3 from a text file
#python3 ./core/texttospeech.py -f "$1" -o "./inputs/audio.mp3" || { echo "Text to speech conversion failed."; exit 1; }
ffmpeg -i ./inputs/audio.mp3 -filter:a "atempo=1.5" -vn ./tmp/spedup_audio.mp3 || { echo "Failed to speed up audio."; exit 1; }
ffmpeg -i ./tmp/spedup_audio.mp3 -acodec pcm_s16le -ac 1 -ar 16000 -fflags +genpts ./tmp/output.wav || { echo "Failed to convert MP3 to WAV."; exit 1; }

# Get durations in seconds
audio_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ./tmp/spedup_audio.mp3 | bc)
video_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ./tmp/spedup_audio.mp3 | bc)

# Run transcription script (ensure this handles errors internally)
python3 ./core/transcribe_audio.py -i ./tmp/output.wav


# Define font path
font_path="./fonts/Mont.ttf"

# Convert the JSON file to .ass format and specify the font (ensure file exists)
[ -f ./tmp/subs.json ] && python3 ./core/jsonToAss.py "$font_path" || { echo "Subtitle JSON not found."; exit 1; }

# Add subtitles to the trimmed video
[ -f ./tmp/output.ass ] && ffmpeg -i ./tmp/trimmed_video.mp4 -vf "ass=./tmp/output.ass" -c:v libx264 -preset fast -crf 22 -an ./tmp/video_subs.mp4 || { echo "Failed to add subtitles."; exit 1; }

# Merge the audio file and the subtitled video into one video
ffmpeg -i ./tmp/video_subs.mp4 -i ./tmp/spedup_audio.mp3 -c:v copy -c:a aac -strict experimental ./tmp/merged_output.mp4 || { echo "Failed to merge audio and video."; exit 1; }


ffmpeg -i ./tmp/titled_intro.mp4 -i ./tmp/merged_output.mp4 -filter_complex "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[v][a]" -map "[v]" -map "[a]" ./tmp/concatenated_video.mp4 || { echo "Failed to concatenate videos."; exit 1; }
# Cut video to 58 seconds long
#./core/scripts/add_title_4k.sh ./tmp/merged_output.mp4 "$2" ./fonts/Montserrat-ExtraBold.ttf ./inputs/reddit.png "$3"
#./core/scripts/add_title_1080.sh ./tmp/merged_output.mp4 "$2" ./fonts/Montserrat-ExtraBold.ttf ./inputs/reddit.png "$3"

output_path="$3"
output_dir="./output"
output_base=$(basename "$output_path" .mp4)

segment_duration=58 # segment duration in seconds

mkdir -p "$output_dir" || { echo "Failed to create output directory."; exit 1; }


# Clean up temporary files
# Uncomment the following lines to delete the temporary files after processing
#rm -rf ./tmp/*
#rm -rf ./clips/*
