import argparse
from pytube import YouTube
import os

"""
Downloads video and audio mp4 and mp3 respective into output_path
"""


def download_video(url, output_path="./"):
    yt = YouTube(url)
    streams = yt.streams.filter(
        adaptive=True
    )  # Adaptive is necessary for highest resolution
    print(streams)
    video_stream = streams.get_by_itag(313)  # 3840x2160
    audio_stream = streams.get_by_itag(140)  # Audio

    # Ensuring the output directory exists
    if not os.path.exists(output_path):
        os.makedirs(output_path)

    video_output_path = os.path.join(output_path, "video.mp4")
    audio_output_path = os.path.join(output_path, "audio.mp3")

    # Correcting the download method usage
    video_stream.download(output_path=output_path, filename="video.mp4")
    audio_stream.download(output_path=output_path, filename="audio.mp3")

    print(f"Video downloaded to: {video_output_path}")
    print(f"Audio downloaded to: {audio_output_path}")


def transcribe(audio_path):
    # Placeholder for transcribe function
    # Implement transcription logic here
    print(f"Transcribing audio from: {audio_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Downloads Youtube URL to highest possible quality mp4 and audio."
    )
    parser.add_argument("-u", "--url", help="Youtube URL", required=True)
    parser.add_argument("-o", "--out", help="Download output path", default="./")

    args = parser.parse_args()

    # Calling download_video with provided URL and output path
    download_video(args.url, args.out)


if __name__ == "__main__":
    main()
