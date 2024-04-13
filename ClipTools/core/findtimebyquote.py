import json
import sys

# Take command-line arguments for input JSON and output files
if len(sys.argv) != 3:
    print("Usage: python script.py <input_json_file> <output_file>")
    sys.exit(1)

input_json_path = sys.argv[1]
output_file_path = sys.argv[2]

# Load the JSON data
with open(input_json_path, "r") as file:
    subtitles = json.load(file)

file_path = "./tmp/ai.txt"

# Read the entire content of the file into a single string
with open(file_path, "r") as file:
    content = file.read()
    content = (
        content.replace('"', "").replace("[", "").replace("]", "").replace("\n", "")
    )
    quote_list = [item.strip() for item in content.split(",")]


def find_time_by_quote(subtitles, quote):
    for subtitle in subtitles:
        if quote in subtitle["text"]:
            start_time = subtitle["result"][0]["start"]
            end_time = subtitle["result"][-1]["end"]
            return start_time, end_time
    return None


timestamps = []
for quote in quote_list:
    time_range = find_time_by_quote(subtitles, quote)
    if time_range:
        timestamps.append(time_range)


def format_time(seconds):
    hours = int(seconds / 3600)
    minutes = int((seconds % 3600) / 60)
    seconds = seconds % 60
    return "{:01d}:{:02d}:{:06.3f}".format(hours, minutes, seconds)


# Write timestamps to a file
with open(output_file_path, "w") as f:
    for start, end in timestamps:
        f.write(f"{format_time(start)[:-1]},{format_time(end)[:-1]}\n")
