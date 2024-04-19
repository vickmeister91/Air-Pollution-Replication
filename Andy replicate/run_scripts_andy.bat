@echo off
cd /d "%~dp0"
echo Activating Anaconda environment and running Python script...
call conda activate base
python "chatGPT_locations_from_text - Copy.py"
python "Location - Copy.py"
python "India_NER - Copy.py"
python "gpt_take2 - Copy.py"
python "Final Merge - Copy.py"

echo Python script finished.
call conda deactivate base
pause
