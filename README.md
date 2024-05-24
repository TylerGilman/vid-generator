# vid-generator

## Description:
Tools for automating editing Videos, specifically from Youtube into high quality shorts.
Uses VOSK to subtitle using local resources. Can use chatgpt to edit videos or you can grab single clips. 
Should allow easy manual edits somehow as well. git@github.com:TylerGilman/vid-generator.git

## Requirements:
ffmpeg
pyTube
Vosk 

#### 
Vosk - Download model https://alphacephei.com/vosk/models

## Usage:
1. Clone directory

2. Create virtual machine and install required packages
python3 -m venv .venv 


4. Set OpenAI key as ENV var (only necessary for fullrun.sh)
export OPENAI_API_KEY="API-KEY"

## These can be easily put together
5. Download Videos (could be combined but resolution is a different for each)
1080_download_satisfyingclip.sh
4k_download_satisfyingclip.sh


## Finish 
6. Create Final Video
redditstorytovideo.sh

or 

youtube_to_short_no_cut.sh



## Contributing:
Big Dan

## Features and Roadmap:
singleclip.sh creates a single 58 second short with captions and the correct aspect ratio
fullrun.sh creates a 58 second short that is edited by chatgpt. The model can be set in chatgpt.py
There should be additional scripts to add titles and to add "subscribe" reminders to the ends of videos
Increasing video quality would be very nice. 


## License: haha

## API:
___

## Contact Information:
Email: tylersgiman@gmail.com

## Acknowledgments:

