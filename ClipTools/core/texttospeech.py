import argparse
import requests
import os
import uuid
from elevenlabs import VoiceSettings


def split_text(text, max_length=500):
    """Splits text into chunks not exceeding max_length, without cutting words."""
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
    """Converts text to speech and appends the result to an existing audio file."""
    chunks = split_text(text)
    url = "https://api.elevenlabs.io/v1/text-to-speech/pNInz6obpgDQGcFmaJgB"

    querystring = {"optimize_streaming_latency": "4", "output_format": "mp3_44100_32"}
    headers = {
        "xi-api-key": "505d0fe2f0cae064dd61906c454aab12",
        "Content-Type": "application/json"
    }

    for chunk in chunks:
        payload = {
            "text": chunk,
            "model_id": "eleven_turbo_v2",
            "voice_settings": {
                "stability": 0,
                "similarity_boost": 1,
                "style": 1,
                "use_speaker_boost": True
            }
        }
        response = requests.request("POST", url, json=payload, headers=headers, params=querystring)
        # Append each chunk's audio to the output file
        with open(output_path, "ab") as f:
            for audio_chunk in response:
                f.write(audio_chunk)

    print(f"Appended audio to {output_path} successfully!")

def main():
    parser = argparse.ArgumentParser(
        description="Converts a text file to speech using ElevenLabs API and appends to an MP3 file."
    )
    parser.add_argument("-f", "--file", help="Text file location", required=True)
    parser.add_argument("-o", "--out", help="Output audio file path", default="./output.mp3")
    args = parser.parse_args()

    # Read the entire text file
    with open(args.file, 'r') as file:
        content = file.read()

    # Convert and append the text to speech
    text_to_speech_file(content, args.out)

if __name__ == "__main__":
    main()