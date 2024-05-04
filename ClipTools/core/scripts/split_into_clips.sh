#!/bin/bash

# Check if a file path has been provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <Video Path>"
  exit 1
fi

video_path="$1"
output_dir=$(dirname "$video_path")
output_base=$(basename "$video_path" .mp4)  # Change '.mp4' according to your video file extension if different
segment_duration=58  # segment duration in seconds

# Create the output directory if it doesn't exist
mkdir -p "$output_dir/segments"

# Split the video into 58-second segments
ffmpeg -i "$video_path" -c copy -map 0 -segment_time $segment_duration -f segment -reset_timestamps 1 "$output_dir/segments/${output_base}_segment%d.mp4"

echo "Video has been split into segments, saved in $output_dir/segments/"
