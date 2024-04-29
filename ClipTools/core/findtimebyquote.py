import json
import argparse


# Read the content into list of text and cleans out characters
# Must be a better way to match this shit together
def read_file_into_list(ai_input):
    with open(ai_input, "r") as file:
        content = file.read()
        content = (
            content.replace('"', "").replace("[", "").replace("]", "").replace("\n", "")
        )
        quote_list = [item.strip() for item in content.split(",")]
    return quote_list


def format_time(seconds):
    hours = int(seconds / 3600)
    minutes = int((seconds % 3600) / 60)
    seconds = seconds % 60 + 0.25
    return "{:01d}:{:02d}:{:06.3f}".format(hours, minutes, seconds)


def find_time_by_quote(subtitles, quote):
    for subtitle in subtitles:
        text = subtitle["text"].replace("[", "").replace("]", "").replace("\n", "")

        if quote.strip().lower() in text.strip().lower():
            start_time = subtitle["result"][0]["start"]
            end_time = subtitle["result"][-1]["end"]
            return start_time, end_time
    return None


def ai_input_to_timestamps(subs, ai_input, output_file):
    # Load the JSON data
    with open(subs, "r") as file:
        subtitles = json.load(file)

    quote_list = read_file_into_list(ai_input)
    timestamps = []
    for quote in quote_list:
        time_range = find_time_by_quote(subtitles, quote)
        if time_range:
            timestamps.append(time_range)

    # Write timestamps to a file
    with open(output_file, "w") as f:
        for start, end in timestamps:
            f.write(f"{format_time(start)[:-1]},{format_time(end)[:-1]}\n")


def main():
    parser = argparse.ArgumentParser(
        description="Finds the timestamps for the given list of quotes."
    )
    parser.add_argument("-s", "--subs", help="Subtitles file", required=True)
    parser.add_argument("-a", "--ai", help="AI input", required=True)
    parser.add_argument("-o", "--out", help="Download output path", required=True)
    args = parser.parse_args()
    err = ai_input_to_timestamps(args.subs, args.ai, args.out)
    if err:
        print("Unable to create timestamps")

    return


if __name__ == "__main__":
    main()
