from vosk import Model, KaldiRecognizer
import wave
import json
import argparse

# Credit to SingerLinks below.
# https://singerlinks.com/2021/07/how-to-convert-speech-to-text-using-python-and-vosk/
"""
this script reads a mono wav file (inFileName) and writes out a json file (outfileResults) with the speech to text conversion results.  It then writes out another json file (outfileText) that only has the "text" values.
"""

inFileName = "./tmp/output.wav"
outfileResults = "./tmp/subs.json"
outfileText = "./tmp/text.json"


def transcribe_video(input, output_subs, output_text):
    subs_list = []
    text_list = []
    wf = wave.open(input, "rb")
    model = Model("./models/vosk-model-en-us-0.22")
    recognizer = KaldiRecognizer(model, wf.getframerate())
    recognizer.SetWords(True)

    while True:
        data = wf.readframes(4000)
        if len(data) == 0:
            break

        if recognizer.AcceptWaveform(data):
            recognizerResult = recognizer.Result()
            resultDict = json.loads(recognizerResult)
            subs_list.append(resultDict)
            # Add the 'text' value to textResults as well
            text_list.append(resultDict.get("text", ""))

    # process "final" result
    finalResultDict = json.loads(recognizer.FinalResult())
    subs_list.append(finalResultDict)
    text_list.append(finalResultDict.get("text", ""))

    # write results to a file
    with open(output_subs, "w") as output:
        json.dump(subs_list, output, indent=4)

    # write text portion of results to a file
    with open(output_text, "w") as output:
        print(json.dumps(text_list, indent=4), file=output)
    return 0  # No error handline for text io


def main():
    parser = argparse.ArgumentParser(
        description="Downloads Youtube URL to highest possible quality mp4 and audio."
    )
    parser.add_argument("-i", "--input", help="Audio file to transcribe", required=True)
    parser.add_argument(
        "-s", "--subs", help="Output subtitle path", default="./tmp/subs.json"
    )
    parser.add_argument(
        "-t", "--text", help="Output subtitle path", default="./tmp/text.json"
    )

    args = parser.parse_args()
    err = transcribe_video(args.input, args.subs, args.text)
    if err:
        print("Failed to transcribe audio file")


if __name__ == "__main__":
    main()
