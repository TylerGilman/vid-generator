import argparse
import requests
import os
import tempfile
from pathlib import Path
import subprocess
import os

def concatenate_audio(file_paths, output_path):
    """Concatenates multiple audio files into a single file using FFmpeg."""
    concat_command = ['ffmpeg', '-y', '-loglevel', 'error', '-i',
                      "concat:" + '|'.join(file_paths),
                      '-acodec', 'copy', output_path]
    subprocess.run(concat_command, check=True)

def save_and_concatenate_audio(chunks, temp_dir, final_output_path):
    """Save temporary audio chunks and concatenate them."""
    temp_files = []
    try:
        for index, chunk in enumerate(chunks):
            temp_path = os.path.join(temp_dir, f"temp_audio_{index}.mp3")
            with open(temp_path, "wb") as f:
                f.write(chunk)
            temp_files.append(temp_path)

        concatenate_audio(temp_files, final_output_path)
    finally:
        for file in temp_files:
            os.remove(file)
def split_text(text, max_length=500):
    words = text.split()
    chunks = []
    current_chunk = words[0]

    for word in words[1:]:
        if len(current_chunk) + len(word) + 1 <= max_length:
            current_chunk += ' ' + word
        else:
            chunks.append(current_chunk)
            current_chunk = word
    chunks.append(current_chunk)  # Append the last chunk
    return chunks

def text_to_speech_file(text: str, output_path):
    chunks = split_text(text)
    url = "https://api.elevenlabs.io/v1/text-to-speech/pNInz6obpgDQGcFmaJgB"
    headers = {"xi-api-key": "c12c2a105f29f817ade498753196f46e", "Content-Type": "application/json"}

    with tempfile.TemporaryDirectory() as temp_dir:
        temp_paths = []
        for index, chunk in enumerate(chunks):
            payload = {
                "text": chunk,
                "model_id": "eleven_turbo_v2",
                "voice_settings": {"stability": 0, "similarity_boost": 1, "style": 1, "use_speaker_boost": True}
            }
            response = requests.post(url, json=payload, headers=headers).content
            temp_path = Path(temp_dir) / f"chunk_{index}.mp3"
            temp_path.write_bytes(response)
            temp_paths.append(str(temp_path))

        # Use FFmpeg to concatenate all parts into a single MP3
        concatenate_audio(temp_paths, output_path)

    print(f"Appended audio to {output_path} successfully!")

def main():
    parser = argparse.ArgumentParser(description="Converts a text file to speech using ElevenLabs API and appends to an MP3 file.")
    parser.add_argument("-f", "--file", help="Text file location", required=True)
    parser.add_argument("-o", "--out", help="Output audio file path", default="./output.mp3")
    args = parser.parse_args()

    with open(args.file, 'r') as file:
        content = file.read()

    text_to_speech_file(content, args.out)

if __name__ == "__main__":
    main()
