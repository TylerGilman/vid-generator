from vosk import Model, KaldiRecognizer
import wave
import json

# Credit to SingerLinks below.
# https://singerlinks.com/2021/07/how-to-convert-speech-to-text-using-python-and-vosk/
"""
this script reads a mono wav file (inFileName) and writes out a json file (outfileResults) with the speech to text conversion results.  It then writes out another json file (outfileText) that only has the "text" values.
"""

inFileName = "./tmp/output.wav"
outfileResults = "./tmp/subs.json"
outfileText = "./tmp/text.json"

wf = wave.open(inFileName, "rb")

# initialize a str to hold results
results_list = []
textResults = []

# build the model and recognizer objects.
model = Model("./models/vosk-model-en-us-0.42-gigaspeech")
recognizer = KaldiRecognizer(model, wf.getframerate())
recognizer.SetWords(True)

while True:
    data = wf.readframes(4000)
    if len(data) == 0:
        break

    if recognizer.AcceptWaveform(data):
        recognizerResult = recognizer.Result()
        resultDict = json.loads(recognizerResult)
        results_list.append(resultDict)
        # Add the 'text' value to textResults as well
        textResults.append(resultDict.get("text", ""))


##    else:
##        print(recognizer.PartialResult())

# process "final" result
finalResultDict = json.loads(recognizer.FinalResult())
results_list.append(finalResultDict)
textResults.append(finalResultDict.get("text", ""))


# write results to a file
with open(outfileResults, "w") as output:
    json.dump(results_list, output, indent=4)

# write text portion of results to a file
with open(outfileText, "w") as output:
    print(json.dumps(textResults, indent=4), file=output)
