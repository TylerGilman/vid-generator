import json


# Function to format time for .ass subtitles
def format_time(seconds):
    hours = int(seconds / 3600)
    minutes = int((seconds % 3600) / 60)
    seconds = seconds % 60
    return "{:01d}:{:02d}:{:06.3f}".format(hours, minutes, seconds).replace(".", ",")


# Start of the .ass file content
ass_content = """[Script Info]
Title: Generated Subtitles
ScriptType: v4.00+
WrapStyle: 0
ScaledBorderAndShadow: yes
YCbCr Matrix: None

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,20,&H00FFFFFF,&H000000FF,&H00000000,&H64000000,0,0,0,0,100,100,0,0,1,1,0,2,10,10,10,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""

# Load the JSON data
with open("./tmp/subs.json", "r") as file:
    data = json.load(file)

# Process each transcription result to format it into an .ass subtitle
for item in data:
    if "result" in item:  # Check if 'result' key exists in the dictionary
        for sub_item in item["result"]:  # Iterate through the list under 'result' key
            start_time = format_time(sub_item["start"]).replace(",", ".")[:-1]
            # print("START: ", start_time)
            end_time = format_time(sub_item["end"]).replace(",", ".")[:-1]
            # print("END: ", end_time)
            text = sub_item["word"].replace(
                "\n", "\\N"
            )  # Adjust this if the structure is different
            ass_content += "Dialogue: 0,{start},{end},Default,,0,0,0,,{text}\n".format(
                start=start_time, end=end_time, text=text
            )

# Save the formatted subtitles to an .ass file
with open("./tmp/output.ass", "w") as file:
    file.write(ass_content)

print("Subtitles have been written to ./tmp/output.ass")
