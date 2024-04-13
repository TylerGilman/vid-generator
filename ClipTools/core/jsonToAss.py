import json


# Function to format time for .ass subtitles
def format_time(seconds):
    hours = int(seconds / 3600)
    minutes = int((seconds % 3600) / 60)
    seconds = seconds % 60
    return "{:01d}:{:02d}:{:06.3f}".format(hours, minutes, seconds)


# Function to process word groups into subtitle lines
def process_groups(word_list, group_size):
    grouped_words = []
    for i in range(0, len(word_list), group_size):
        group = word_list[i : i + group_size]
        if group:
            start_time = format_time(group[0]["start"]).replace(",", ".")[:-1]
            print(start_time)
            end_time = format_time(group[-1]["end"]).replace(",", ".")[:-1]
            text = " ".join([word["word"].replace("\n", "\\N") for word in group])
            grouped_words.append((start_time, end_time, text))
    return grouped_words


# Start of the .ass file content
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
Style: Default,Calibri,75,&H00FFFFFF,&H000000FF,&H00000000,&H64000000,0,0,0,0,100,100,0,0,1,2,0,2,10,10,10,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""

# Load the JSON data
with open("./tmp/subs.json", "r") as file:
    data = json.load(file)

# Number of words per subtitle
words_per_subtitle = 3  # Change this to set how many words per line you want

# Process each transcription result to format it into an .ass subtitle
for item in data:
    if "result" in item:
        groups = process_groups(item["result"], words_per_subtitle)
        for start_time, end_time, text in groups:
            ass_content += (
                f"Dialogue: 0,{start_time},{end_time},Default,,0,0,0,,{text}\n"
            )

# Save the formatted subtitles to an .ass file
with open("./tmp/output.ass", "w") as file:
    file.write(ass_content)

print("Subtitles have been written to ./tmp/output.ass")
