#!/bin/bash

# Check if the correct number of arguments were passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_transcript_json> <output_timestamps_txt>"
    exit 1
fi

TRANSCRIPT_JSON="$1"
TIMESTAMPS_TXT="$2"

# Define intermediate file paths
AI_OUTPUT="./tmp/ai.txt"
SUBTITLES_JSON="./tmp/subs.json"

# OPENAI api to get best quotes
python3 core/chatgpt.py "$TRANSCRIPT_JSON" "$AI_OUTPUT"

# Get the timestamps associated with those quotes
python3 core/findtimebyquote.py "$SUBTITLES_JSON" "$TIMESTAMPS_TXT"
