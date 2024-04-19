#!/usr/bin/env python
# coding: utf-8

# In[4]:


# Import necessary libraries
import pandas as pd
import os
import json

# Initialize an empty DataFrame to store results
kanoon_df = pd.DataFrame(columns=['Kanoon_ID', 'Content'])

# Get the directory of the current script (run only when using batch scripts)
script_directory = os.path.dirname(os.path.abspath(__file__))

# Change the current working directory to the script's directory
os.chdir(script_directory)

# Confirm the change
print("Current Working Directory has been changed to:", os.getcwd())
wd=os.getchdir()
tempdir = wd+r'/temp'
# List all JSON files in the directory
file_names = [f for f in os.listdir(tempdir) if f.endswith('.json')]

# Loop through each file
for file in file_names:
    try:
        # Extract Kanoon ID from the file name
        kanoon_id = file.split('-')[0]
        
        # Read the JSON file
        with open(f'{tempdir}/{file}', 'r') as f:
            json_data = json.load(f)
        
        # Extract the assistant's content
        content = json_data['choices'][0]['message']['content']
        
        # Check if Kanoon ID already exists in the DataFrame
        existing_row = kanoon_df[kanoon_df['Kanoon_ID'] == kanoon_id]
        
        if not existing_row.empty:
            # Append the new content to the existing content for the same Kanoon ID
            existing_idx = existing_row.index[0]
            kanoon_df.at[existing_idx, 'Content'] += ' ' + content
        else:
            # Add a new row for the new Kanoon ID
            new_row = pd.DataFrame({'Kanoon_ID': [kanoon_id], 'Content': [content]})
            kanoon_df = pd.concat([kanoon_df, new_row], ignore_index=True)
            
    except Exception as e:
        print(f"Error in file: {file}, {str(e)}")

# Save the DataFrame to a CSV file
kanoon_df.to_csv(wd+r'/combined_gpt_take2.1.csv', index=False)


# ## Prompt
# 
# You are an Indian classifier. You will be given a text that definitely contains geographical location names in India. Your job is to parse the text into various location categories in India. Your outputs are: 
# "The State is: `state name 1`, (significance)" 
# "The District is: `District name 1`, (significance)"
# "The City is:  `City name 1`, (significance)"
# - When the text does not contain any location information or if the text is nonsense. You output the xxx is N/A. 
# - You will do the same even if the location provided only contains 1 or a few levels. 
# - If there are multiple locations at the same level, for example, multiple states, the output format you MUST follow is: The State is: `state name 1`; `state name2`, etc.
# -Use as few words as possible to describe a location's significance. 

# In[1]:


import openai
import os
import json
import time
import pandas as pd
from tqdm import tqdm


# Create a temp folder if it doesn't exist
os.makedirs(wd+r'/temp2',exists_ok=True)
temp_folder_path = wd+r'/temp2'
# Your prompt variable
prompt = "You are an Indian classifier. You will be given a text that definitely contains geographical location names in India. Your job is to parse the text into various location categories in India. Your outputs are: \n\"The State is: `state name 1`, (significance)\" \n \"The District is: `District name 1`, (significance)\" \n \"The City is:  `City name 1`, (significance)\" \n - When the text does not contain any location information or if the text is nonsense. You output the xxx is N/A. \n - You will do the same even if the location provided only contains 1 or a few levels. \n - If there are multiple locations at the same level, for example, multiple states, the output format you MUST follow is: The State is: `state name 1`; `state name2`, etc. \n -Use as few words as possible to describe a location's significance. "

# Function to make API calls
def api_call(location, iteration):
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {
                    "role": "system",
                    "content": prompt
                },
                {
                    "role": "user",
                    "content": location
                }
            ],
            temperature=0,
            max_tokens=2000,
            top_p=1,
            frequency_penalty=0,
            presence_penalty=0
        )

        # Save the response as a JSON file
        json_file_path = os.path.join(temp_folder_path, f"{iteration}.json")
        with open(json_file_path, 'w') as f:
            json.dump(response, f)

    except Exception as e:
        print(f"API call failed at iteration {iteration} with error: {e}")

# Input for starting iteration
# start_iteration = int(input("Enter the iteration number to start from: "))
start_iteration = 1

# Path to your CSV file
csvpath = wd+r"/combined_gpt_take2.1.csv"

# Loop through the DataFrame
total_rows = len(pd.read_csv(csvpath))
for index, row in tqdm(enumerate(pd.read_csv(csvpath).iterrows(), start=start_iteration), total=total_rows - start_iteration + 1, desc="Processing locations"):
    if index < start_iteration:
        continue
    location = row[1]['Content']  # Make sure the column name is correct
    api_call(location, index)
    time.sleep(1)


# In[2]:


gpt_outputs = []

new_df = pd.read_csv(csvpath)
# Loop through all the rows in the new DataFrame
for i in range(len(new_df)):
    json_file_path = os.path.join(temp_folder_path, f"{i}.json")
    
    # Check if the file exists
    if os.path.exists(json_file_path):
        with open(json_file_path, 'r') as f:
            data = json.load(f)
        
        # Extract the GPT response from the JSON
        gpt_output = data.get('choices', [{}])[0].get('message', {}).get('content', "N/A")
        gpt_outputs.append(gpt_output)
    else:
        gpt_outputs.append("N/A")

# Create a new DataFrame for the GPT outputs
gpt_outputs_df = pd.DataFrame({'gpt_output': gpt_outputs})

# Perform a left join on the index
new_df_merged = new_df.join(gpt_outputs_df)


# In[3]:


# Save the new DataFrame to a CSV file
new_df_merged.to_csv(wd+r'/combined_gpt_take2.2.csv', index=False)


# In[ ]:




