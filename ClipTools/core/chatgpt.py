import sys
from openai import OpenAI

# Take command-line arguments for input and output files
if len(sys.argv) != 3:
    print("Usage: python script.py <input_file> <output_file>")
    sys.exit(1)

input_file_path = sys.argv[1]
output_file_path = sys.argv[2]

client = OpenAI()

# Read the content of the text file
with open(input_file_path, "r") as file:
    file_content = file.read()

prompt_context = "You are going to receive the transcript of a YouTube video. You need to create a list of the 5 most interesting quotations from the video. Quote the transcript exactly and return the list as a list of comma-separated values"

# Combine the file content with your additional prompt
full_prompt = prompt_context + file_content

# Prepare to write the output to a text file
with open(output_file_path, "w") as output_file:
    stream = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "assistant", "content": full_prompt}],
        stream=True,
    )
    for chunk in stream:
        if chunk.choices[0].delta.content is not None:
            # Write the received content to a file instead of printing it
            output_file.write(chunk.choices[0].delta.content)
