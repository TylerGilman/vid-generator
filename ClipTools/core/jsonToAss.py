import json


# Function to format time for .ass subtitles
def format_time(seconds):
    hours = int(seconds / 3600)
    minutes = int((seconds % 3600) / 60)
    seconds = seconds % 60
    return "{:01d}:{:02d}:{:06.3f}".format(hours, minutes, seconds)


def process_karaoke(word_list, group_size):
    grouped_words = []
    for i in range(0, len(word_list), group_size):
        group = word_list[i : i + group_size]
        if group:
            start_time = format_time(group[0]["start"]).replace(",", ".")[:-1]
            end_time = format_time(group[-1]["end"]).replace(",", ".")[:-1]
            # Initialize karaoke line with an empty string
            karaoke_line = ""
            for word in group:
                # Example: Each syllable takes about 30 centiseconds (adjust according to your timings)
                duration = word["end"] - word["start"] / 100
                # Add a space between each word with karaoke timing
                karaoke_line += f"{{\\k{duration}}}{word['word']} "
            grouped_words.append(
                (start_time, end_time, karaoke_line.strip())
            )  # .strip() to remove any trailing space
    return grouped_words


# Load the JSON data
with open("./tmp/subs.json", "r") as file:
    data = json.load(file)

# Process each transcription result to format it into an .ass subtitle with karaoke effects
ass_content = """[Script Info]
Title: Generated Subtitles
ScriptType: v4.00+
WrapStyle: 0
ScaledBorderAndShadow: yes
YCbCr Matrix: None
PlayResX: 720
PlayResY: 1280

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Futura,50,&H00FFFFFF,&H000000FF,&H00000000,&H64000000,-1,0,0,0,100,100,0,0,1,2,0,5,10,10,10,1
[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
# Number of words per subtitle
words_per_subtitle = 3

# Center position for the video
center_x = 720 // 2
center_y = 1280 // 2

# Bounce range (pixels)
bounce_range_x = 5
bounce_range_y = 2
for item in data:
    if "result" in item:
        groups = process_karaoke(item["result"], words_per_subtitle)
        for start_time, end_time, text in groups:
            ass_content += (
                f"Dialogue: 0,{start_time},{end_time},Default,,0,0,0,,{text}\n"
            )

# Save the formatted subtitles to an .ass file
with open("./tmp/output.ass", "w") as file:
    file.write(ass_content)

print("Karaoke subtitles have been written to ./tmp/output.ass")
