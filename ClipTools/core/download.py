import argparse
from pytube import YouTube
import pytube.exceptions
import os


def download_video(url, output_path="./"):
    yt = YouTube(url)
    streams = yt.streams.filter(
        adaptive=True
    )  # Adaptive is necessary for highest resolution
    print(streams)

    try:
        video_stream = streams.get_by_itag(313)  # 4K video
        audio_stream = streams.get_by_itag(140)  # Audio
        if not video_stream:
            raise pytube.exceptions.VideoUnavailable(yt.video_id)
        print("Downloaded 4k video")
    except pytube.exceptions.VideoUnavailable:
        try:
            video_stream = streams.get_by_itag(137)  # 1080p video
            audio_stream = streams.get_by_itag(140)  # Audio
            if not video_stream:
                raise pytube.exceptions.VideoUnavailable(yt.video_id)
            print("Downloaded 1080p video")
        except pytube.exceptions.VideoUnavailable:
            print("Unable to download 4k or 1080p video")
            return 1

    # Ensuring the output directory exists
    if not os.path.exists(output_path):
        os.makedirs(output_path)

    video_output_path = os.path.join(output_path, "video.mp4")
    audio_output_path = os.path.join(output_path, "audio.mp3")

    # Download if streams are not None
    if video_stream and audio_stream:
        video_stream.download(output_path=output_path, filename="video.mp4")
        audio_stream.download(output_path=output_path, filename="audio.mp3")
        print(f"Video downloaded to: {video_output_path}")
        print(f"Audio downloaded to: {audio_output_path}")
    else:
        print("Failed to find suitable video and/or audio streams.")
        return 1

    return 0


def main():
    parser = argparse.ArgumentParser(
        description="Downloads Youtube URL to highest possible quality mp4 and audio."
    )
    parser.add_argument("-u", "--url", help="Youtube URL", required=True)
    parser.add_argument("-o", "--out", help="Download output path", default="./")

    args = parser.parse_args()
    err = download_video(args.url, args.out)
    if err:
        print("Video not available in 1080 or 4k")


if __name__ == "__main__":
    main()
