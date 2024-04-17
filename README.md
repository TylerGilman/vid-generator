# vid-generator

## Description:
Tools for automating editing Videos, specifically from Youtube into high quality shorts.

## Installation Instructions:
Include detailed instructions on how to set up and install your project. This should cover any prerequisites, dependencies, and step-by-step instructions to get the project running.

## Usage:
1. Clone directory

2. Create virtual machine and install required packages
python3 -m venv .venv 
pip install whatava you dont have idk

3. Set OpenAI key as ENV var (only necessary for fullrun.sh)
export OPENAI_API_KEY="API-KEY"

4. Enter ClipTools
cd Cliptools
6. Run scripts singleclip.sh or fullrun.sh 
### fullrun.sh 
./core/fullrun.sh "YOUTUBE URL" "Video Title" "OUTPUT PATH"

## Contributing:
Big Dan

## Features and Roadmap:
singleclip.sh creates a single 58 second short with captions and the correct aspect ratio
fullrun.sh creates a 58 second short that is edited by chatgpt. The model can be set in chatgpt.py
There should be additional scripts to add titles and to add "subscribe" reminders to the ends of videos
Increasing video quality would be very nice. 


## License: ??

## API:
___

## Contact Information:
Email: tylersgiman@gmail.com

## Acknowledgments:
Credit anyone whose code was used in the project, and any other acknowledgments.

