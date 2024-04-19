
### Python modules required: (some unused but keeping them for safety)
1. pandas
2. numpy
3. nltk
4. seaborn
5. matplotlib
6. ast
7. networkx
8. beautifulsoup4
9. regex
10. tqdm
11. glob
12. os
13. multiprocessing
14. numexpr
15. fuzzywuzzy
16. lxml
17. plotly.express
18. requests
19. openai
20. statsmodels
21. tiktoken
22. time

<p style="font-size:24px;"> **Shashank Replication:** </p>

## Schema: 
check_all_pollution_cases_citations.py --> find_acts.py --> NER_place_extraction.py
then importance_formula_and_analyse_parties.ipynb

Unpack the contents of <u>shashank replicate</u> folder in the working directory

**Edit the following scripts:**

*check_all_pollution_cases_citations.py*
+ import/sync [citations data folder](https://www.dropbox.com/scl/fo/bc2v5kd1e3vfu1lbksnb1/h/ANALYSIS/DATA/processed_data/citations_data_full?rlkey=4wmgcxy6ioswyjpijxmsehpfn&dl=1) (citations_data) to local folder from dropbox
+ replace the folder path in the script to point to the above folder

*find_acts.py*
+ import/sync [kanoon metadata folder](https://www.dropbox.com/scl/fo/qd5kuwsz89yz0hd26tk7v/h?rlkey=kf6mjw49zswy2cscgw8psyl3i&dl=1) to local folder from dropbox
+ replace the folder path (kanoon_metadata_path) in the script to poin to the above folder
+ similar exercise for citations data as well

*NER_place_extraction.py*
+ Kanoon raw txt files: import/sync from dropbox
+ replace the folder path in the script (KANOON = ...)
+ ensure the output file "possible_air_corpus_with_meta_and_text.csv" is in same folder as scripts

*importance_formula_and_analyse_parties.py*
+ Import Kanoon html files from dropbox
+ replace "path_to_text" with the path of the folder containing html files
+ ensure the output file "case_data_final_with_additional_variables.csv" is in same folder as scripts

*chatgpt_qx_annotator.py (5 files)*
+ download chatgptsummaries folder in the same directory as the scripts
*missing_final_aggregator.py*
+ ensure this file can collate all the 5 respnses into a final csv ("chatgptfull.csv")
+ need to enter api key for openai

run batch script <u>"run_script_shashank.bat"</u>

<p style="font-size:24px;"> **Andy Replication:** </p>

## Schema:
"chatGPT_locations_from_text - Copy.py" --> "Location - Copy.py" -->
"India_NER - Copy.py" --> "gpt_take2 - Copy.py" --> Final Merge - Copy.py"

I have added the "copy" suffix to identify my edited version
+ unpack the contents of <u+ Andy replicate </u+ to working directory
ensure that "chatgptfull.csv" and "possible_air_corpus_with_meta_and_text.csv" files which are output from shashank's code are in the same folder (working diretory) as the scripts. Also include "India States Wiki.xlsx" file in the same folder
+ need to enter api key for openai in "chatGPT_locations_from_text - Copy.py" , "Location - Copy.py" and "gpt_take2 - Copy.py"
+ then simply execute the <u+"run_scripts_andy.bat"</u+

<p style="font-size:24px;"> **Olexiy Replication:** </p>

We will be excluding the extraction of pollution data from GIS. If needed the entire replication instructions (involving multiple steps) are described in detail here

This replication concerns the data cleaning and extraction using the processed csv files obtained from GIS softare

+ Download the [entire folder](https://www.dropbox.com/scl/fo/spfgqb2n917ku76fwzuo3/AMHRc5cHfbFW9tCljUaCLK4?rlkey=3x2qrrqx6cxsykpq28d18wacg&st=20ggcyua&dl=0) from dropbox into the working directory
+ open master.do in the "olexiy replicate" folder and assign the path to the working directory to the global macro "your_path_here"
+ execute the master.do file

<p style="font-size:24px;"> **Viknesh Replication:** </p>

+ unpack contents of <u+ Viknesh replicate </u+ to working directory
+ ensure "main_df.csv" from Andy and "air_pollution_olexiy_combined.csv" from Olexiy are in the working directory
+ ensure shashank's files (previously mentioned) are also in the same
+ execute <u+"run_scripts_viknesh.bat"</u+

### Additional Instructions:

+ Before executing .bat files make sure that the R, STATA and Python executables are added to the system path
+ Edit the batch files accordinly if Python is not installed via Anaconda or the Anaconda environment is not base
+ Edit the Stata version in the command line (better yet use path ro stata exe file)
+ For smooth execution, designate a working directory and unpack/download the replication contents as per above isntructions
(this is to ensure the output files are used by subsequent scripts without broken paths)
+ Follow the order of replication as in the readme closely
+ check replication usccess by comparing with files in **Olexiy files** folder for Olexiy and [dropbox folder](https://www.dropbox.com/scl/fo/qtmghtt5k5xntk8k71lo1/h?rlkey=z707hlxkcijxa3u4ko5f3jo77&st=7nl6ylt3&dl=0) for the others
+ Also make sure to add api key in the specifiedf files above


