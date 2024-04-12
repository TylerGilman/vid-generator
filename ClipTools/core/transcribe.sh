
#!/usr/bin/env python3

import wave
import sys
import json
from vosk import Model, KaldiRecognizer, SetLogLevel

# You can set log level to -1 to disable debug messages
SetLogLevel(0)

if len(sys.argv) < 2:
    print("Usage: {} <audiofile>".format(sys.argv[0]))
    sys.exit(1)

wf = wave.open(sys.argv[1], "rb")
if wf.getnchannels() != 1 or wf.getsampwidth() != 2 or wf.getcomptype() != "NONE":
    print("Audio file must be WAV format mono PCM.")
    sys.exit(1)

model = Model("./models/vosk-model-en-us-0.42-gigaspeech")

rec = KaldiRecognizer(model, wf.getframerate())
rec.SetWords(True)
rec.SetPartialWords(True)

results = []

while True:
    data = wf.readframes(200)
    if len(data) == 0:
        break
    if rec.AcceptWaveform(data):
        results.append(json.loads(rec.Result()))
    else:
        results.append(json.loads(rec.PartialResult()))

final_result = json.loads(rec.FinalResult())
results.append(final_result)

# Output the results as JSON
with open("output.json", "w") as outfile:
    json.dump(results, outfile)

print("Results written to output.json")

