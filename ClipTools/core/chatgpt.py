from openai import OpenAI
import argparse

# Take command-line arguments for input and output files


def call_llm(input_file, output_file, prompt_context):
    client = OpenAI()
    # Read the content of the text file
    with open(input_file, "r") as file:
        file_content = file.read()
    # Combine the file content with your additional prompt
    full_prompt = prompt_context + file_content

    # Prepare to write the output to a text file
    with open(output_file, "w") as output_file:
        stream = client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "assistant", "content": full_prompt}],
            stream=True,
        )
        for chunk in stream:
            if chunk.choices[0].delta.content is not None:
                # Write the received content to a file instead of printing it
                output_file.write(chunk.choices[0].delta.content)


def main():
    prompt_context = "You are going to receive the transcript of a YouTube video. You need to identify the most interesting part of the video and return enough quotes for approximately 1 minute talking. Return quotes starting with the most interesting part of the video. Do not include sentances that are not very interesting! Return exactly the quotes as they were given. Quote the transcript exactly and return the list as a list of comma-separated values"

    parser = argparse.ArgumentParser(
        description="Downloads Youtube URL to highest possible quality mp4 and audio."
    )
    parser.add_argument("-i", "--input", help="Youtube URL", required=True)
    parser.add_argument("-o", "--out", help="Download output path", required=True)
    parser.add_argument(
        "-c", "--context", help="Prompt Context", default=prompt_context
    )
    args = parser.parse_args()
    err = call_llm(args.input, args.out, args.context)
    if err:
        print("Unable to call llm")


if __name__ == "__main__":
    main()
