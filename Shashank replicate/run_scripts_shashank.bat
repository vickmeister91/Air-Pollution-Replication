@echo off
cd /d "%~dp0"
echo Activating Anaconda environment and running Python script...
call conda activate base
python check_all_pollution_cases_citations.py
python find_acts.py
python NER_place_extraction.py
python importance_formula_and_analyse_parties.py

python chatgpt_annotator_q1.py
python chatgpt_annotator_q2.py
python chatgpt_annotator_q3.py
python chatgpt_annotator_q4.py
python chatgpt_annotator_q5.py
echo Python script finished.
call conda deactivate base
pause
