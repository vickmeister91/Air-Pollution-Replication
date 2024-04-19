#!/usr/bin/env python
# coding: utf-8

# ## Introduction
# This Jupyter Notebook serves as a comprehensive report detailing the location cleaning task for this project. The project revolves around a dataset generated using GPT 3.5, which contains summaries of various cases, along with location information. The primary aim was to clean, analyze, and potentially improve the quality of the location data extracted from the text of the cases. This report outlines the objectives, methods, and results of the work carried out to fulfill these goals.
# 

# ## Objectives
# The project had three main objectives:
# 1. **Data Cleaning**: The first objective was to clean the location variables in the dataset to make them suitable for analysis. This included structuring the location data into various administrative levels for easier interpretation.
# 2. **Quality Assessment**: The second objective was to qualitatively evaluate the quality of the location data that was initially present in the dataset. This involved identifying the share of unidentified or ambiguous location entries.
# 3. **Potential Improvement (N/A)**: The third objective was to improve the location data, if the quality was deemed inadequate. This involved creating a new code strategy for better extraction of location information from the text of the cases. (I do believe the data looks good enough at the state level. But I would love to learn more about the level of the study and see if it is necessary to go back and improve the text mining process)
# 
# 

# ## Methodology
# The project was executed in a Python environment, utilizing libraries such as Pandas for data manipulation, Matplotlib for data visualization, and regular expressions for string pattern matching. The workflow was as follows:
# 
# 1. **Data Loading**: The dataset `chatgptfull.csv` was loaded into a Pandas DataFrame for analysis.
# 2. **Initial Assessment**: An initial examination of the dataset was performed to understand the structure and identify the cleaning requirements.
# 3. **Data Cleaning**: The location variables were cleaned using GPT 4 and organized into different administrative levels like Zone, State, Union Territory, etc.
# 4. **Quality Assessment**: A qualitative analysis was performed on the cleaned location data. This involved calculating the share of unidentified entries across all administrative levels and visualizing this information.
# 

# In[ ]:


import os
import json
import time
import openai
import pandas as pd
from tqdm import tqdm
import re
import matplotlib.pyplot as plt
from geopy.geocoders import Nominatim
import ast

openai.api_key = ""
# Get the directory of the current script (run only when using batch scripts)
script_directory = os.path.dirname(os.path.abspath(__file__))

# Change the current working directory to the script's directory
os.chdir(script_directory)

# Confirm the change
print("Current Working Directory has been changed to:", os.getcwd())


# In[ ]:



chatgptfull = pd.read_csv('chatgptfull.csv')
chatgptfull.head()
wd = os.getcwd()
os.makedirs("temp", exist_ok=True)
temp_folder_path = wd+"temp/'

outputdf = pd.DataFrame()
gpt_output = []

zones, states, union_territories, autonomous_divisions, divisions, districts, subdistricts, cities = [], [], [], [], [], [], [], []


# ## Prompt: 
# "You are an Indian classifier. You will be given a text that may or may not contain location information. You job is to parse the text into various location categories in India. Your outputs are: 
# "The Zone is: "
# "The State is: "
# "The Union Territory is: "
# "The Autonomous Division is: "
# "The Division is: "
# "The District is: "
# "The Subdistricts is: "
# "The City is: "
# When the text does not contain any location information or if the text is nonsense. You output the xxx is N/A. 
# You will do the same even if the location provided only contain 1 or a few levels. 

# In[ ]:



# Function to make an API call
def api_call(location, iteration):
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {
                    "role": "system",
                    "content": "You are an Indian classifier. You will be given a text that may or may not contain location information. You job is to parse the text into various location categories in India. Your outputs are: \n\"The Zone is: \"\n\"The State is: \"\n\"The Union Territory is: \" \n\"The Autonomous Division is: \"\n\"The Division is: \"\n\"The District is: \"\n\"The Subdistricts is: \"\n\"The City is: \"\n\n\nWhen the text does not contain any location information or if the text is nonsense. You output the xxx is N/A. \n\nYou will do the same even if the location provided only contain 1 or a few levels."
                },
                {
                    "role": "user",
                    "content": location
                }
            ],
            temperature=0,
            max_tokens=3000,
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
start_iteration = int(input("Enter the iteration number to start from: "))

# Loop through the DataFrame
total_rows = len(pd.read_csv(csvpath))
for index, row in tqdm(enumerate(pd.read_csv(csvpath).iterrows(), start=start_iteration), total=total_rows - start_iteration + 1, desc="Processing locations"):
    if index < start_iteration:
        continue
    location = row[1]['location']
    api_call(location, index)
    time.sleep(1)
    


# In[ ]:



# tempFolderPath = 'C:/Users/andre/OneDrive/Work/Georgetown RA/Joshi-DeJure/0_data/interim/temp/'
# Create empty list to store the GPT outputs
gpt_outputs = []

# Loop through all the files in the temp folder
for i in range(len(chatgptfull)):
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
gpt_outputs_df = pd.DataFrame({'gptoutput': gpt_outputs})

# Perform a left join on the index
chatgptfull_merged = chatgptfull.join(gpt_outputs_df)


# In[ ]:


# Save the merged DataFrame to a new CSV file
chatgptfull_merged.to_csv(wd+r'/chatgptfull_merged.csv', index=False)


# In[ ]:



merged_data = chatgptfull_merged

# Initialize empty lists for each administrative level
zones = []
states = []
union_territories = []
autonomous_divisions = []
divisions = []
districts = []
subdistricts = []
cities = []

# Loop through the gptoutput column to extract and parse the administrative levels
for output in merged_data['gptoutput']:
    # Using regular expressions to find the relevant information
    zone = re.search(r'"The Zone is: (.*?)"', output).group(1) if re.search(r'"The Zone is: (.*?)"', output) else "N/A"
    state = re.search(r'"The State is: (.*?)"', output).group(1) if re.search(r'"The State is: (.*?)"', output) else "N/A"
    union_territory = re.search(r'"The Union Territory is: (.*?)"', output).group(1) if re.search(r'"The Union Territory is: (.*?)"', output) else "N/A"
    autonomous_division = re.search(r'"The Autonomous Division is: (.*?)"', output).group(1) if re.search(r'"The Autonomous Division is: (.*?)"', output) else "N/A"
    division = re.search(r'"The Division is: (.*?)"', output).group(1) if re.search(r'"The Division is: (.*?)"', output) else "N/A"
    district = re.search(r'"The District is: (.*?)"', output).group(1) if re.search(r'"The District is: (.*?)"', output) else "N/A"
    subdistrict = re.search(r'"The Subdistricts is: (.*?)"', output).group(1) if re.search(r'"The Subdistricts is: (.*?)"', output) else "N/A"
    city = re.search(r'"The City is: (.*?)"', output).group(1) if re.search(r'"The City is: (.*?)"', output) else "N/A"

    # Append the extracted information to the respective lists
    zones.append(zone)
    states.append(state)
    union_territories.append(union_territory)
    autonomous_divisions.append(autonomous_division)
    divisions.append(division)
    districts.append(district)
    subdistricts.append(subdistrict)
    cities.append(city)

# Add new columns to the DataFrame for each administrative level
merged_data['Zone'] = zones
merged_data['State'] = states
merged_data['Union_Territory'] = union_territories
merged_data['Autonomous_Division'] = autonomous_divisions
merged_data['Division'] = divisions
merged_data['District'] = districts
merged_data['Subdistrict'] = subdistricts
merged_data['City'] = cities

# Save the DataFrame with the new columns to a CSV file
merged_data.to_csv(wd+r"/location_cleaned.csv", index=False)


# In[ ]:


#Due to some error, the merge is off by one row. THe first row is extra and removed manually.

merged_data = pd.read_csv('location_cleaned.csv')
# List of administrative levels to check for N/A values
admin_levels = ['Zone', 'State', 'Union_Territory', 'Autonomous_Division', 'Division', 'District', 'Subdistrict', 'City']

# Empty dictionary to store the share of N/A and non-N/A values for each administrative level
admin_level_summary = {}

# Loop through each administrative level to calculate the share of N/A and non-N/A values
for level in admin_levels:
    total_entries = len(merged_data)
    na_count = merged_data[level].isna().sum()
    non_na_count = total_entries - na_count
    na_share = (na_count / total_entries) * 100
    non_na_share = (non_na_count / total_entries) * 100
    
    admin_level_summary[level] = {'N/A Share': na_share, 'Non-N/A Share': non_na_share}

# Convert the summary to a DataFrame for better readability
summary_df = pd.DataFrame(admin_level_summary)

# Set up the figure and axis for the bar plot
fig, ax = plt.subplots(figsize=(14, 8))

# Create bar plot
summary_df.T.plot(kind='bar', stacked=True, ax=ax, color=['#FF9999', '#99FF99'])

# Add labels and title
plt.xlabel('Administrative Levels', fontsize=14)
plt.ylabel('Percentage Share (%)', fontsize=14)
plt.title('Share of N/A and Non-N/A Values for Each Administrative Level', fontsize=16)

# Add legend
plt.legend(title='Value Type', fontsize=12)

# Annotate the bars with the actual percentages
for p in ax.patches:
    ax.annotate(f"{p.get_height():.2f}%", (p.get_x() + p.get_width() / 2., p.get_y() + p.get_height() / 2),
                ha='center', va='center', fontsize=12, color='black')

# Show the plot
plt.show()


# In[ ]:


# Create a boolean mask for rows where all administrative levels are N/A
unidentified_mask = merged_data[admin_levels].isna().all(axis=1)

# Count the number of entirely unidentified observations
unidentified_count = unidentified_mask.sum()

# Calculate the total number of observations
total_observations = len(merged_data)

# Calculate the share of unidentified and identified observations
unidentified_share = (unidentified_count / total_observations) * 100
identified_share = 100 - unidentified_share

# Data for the pie chart
labels = ['Unidentified', 'Identified']
sizes = [unidentified_share, identified_share]
colors = ['gold', 'yellowgreen']
explode = (0.1, 0)  # Explode the first slice

# Create the pie chart
plt.figure(figsize=(10, 6))
plt.pie(sizes, explode=explode, labels=labels, colors=colors, autopct='%1.2f%%', shadow=True, startangle=140)
plt.axis('equal')  # Equal aspect ratio ensures that the pie is drawn as a circle.
plt.title('Share of Unidentified Observations in Administrative Regions')
plt.show()


# In[ ]:


# Data for the charts
outer_sizes = [88.21, 11.79]
inner_sizes = [75.22, 24.78]
outer_explode = (0, 0.1)

# Plot the bigger pie chart (outer circle)
fig, ax = plt.subplots()
ax.axis('equal')

# Create the outer pie chart
outer_pie, _, outer_autotexts = ax.pie(
    outer_sizes, labels=None, autopct='%1.2f%%',
    startangle=90, counterclock=False, radius=1.0,
    colors=['yellowgreen', 'gold'], explode=outer_explode,
    wedgeprops=dict(width=0.3, edgecolor='w')
)

# Create the inner pie chart
inner_pie, _, inner_autotexts = ax.pie(
    inner_sizes, labels=None, autopct='%1.2f%%',
    startangle=90, counterclock=False, radius=0.7,
    colors=['orange', 'lightcoral'], wedgeprops=dict(width=0.3, edgecolor='w')
)

# Create a combined legend with percentages
legend_labels = [
    'Identified (Yellowgreen) - 88.21%',
    'Unidentified (Gold) - 11.79%',
    'Error/Not Possible (Orange) - 75.22% of Unidentified',
    'Other (Lightcoral) - 24.78% of Unidentified'
]
legend_colors = ['yellowgreen', 'gold', 'orange', 'lightcoral']
legend_handles = [plt.Rectangle((0,0),1,1, color=color) for color in legend_colors]

plt.legend(legend_handles, legend_labels, title="Legend", loc="upper left", bbox_to_anchor=(1, 1))

plt.title('Nested Pie Chart: Share of Unidentified Observations and Error/Not Possible')
plt.show()


# ### Flagging cities that do not have districts and other superior levels

# In[37]:


cleaned_location = pd.read_csv('location_cleaned.csv')
cleaned_location.head()


# In[38]:


# Filtering the DataFrame
filtered_df = cleaned_location[cleaned_location['City'].notna() & 
                 cleaned_location[['District']].isna().all(axis=1)]

# Displaying the filtered DataFrame
filtered_df[['City', 'State', 'Union_Territory', 'Autonomous_Division', 'Division', 'District', 'Subdistrict']]



# ### Find district names from the cities in the filtered locations
# #### Making a dictionary for cities and districts

# In[ ]:


# Initialize the Geolocator with a user agent
geolocator = Nominatim(user_agent="geoapiExercises")

# Function to get location details by city name
def get_location_by_city(city_name, state_name):
    query = f"{city_name}, {state_name}, India" if state_name else f"{city_name}, India"
    location = geolocator.geocode(query)
    if location:
        return location.raw
    else:
        return None

# List of cities and states from your filtered DataFrame
cities_to_lookup = zip(filtered_df['City'].tolist(), filtered_df['State'].tolist())

# Dictionary to store the fetched details
city_mapping = {}
total = len(filtered_df)

# Loop to find the details of each city
for city, state in tqdm(cities_to_lookup, total=total, desc="Fetching location data", ascii=False, ncols=100, bar_format='{l_bar}{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}, {rate_fmt}{postfix}]'):  # tqdm for progress bar
    location_data = get_location_by_city(city, state)
    if location_data:
        display_name = location_data['display_name']
        # Store the details in a harmonized format, parsing as needed
        city_mapping[city] = display_name.split(", ")
    else:
        city_mapping[city] = ["Could not find data"]
    
    # Pause to respect rate limits
    time.sleep(0.1)


# #### Parse the dictionary

# In[40]:


city_mapping_df = pd.DataFrame(list(city_mapping.items()), columns=['City', 'Location_Info'])
city_mapping_df.to_csv(wd+r'/city_mapping.csv', index=False)


# In[ ]:


city_mapping_df[['City', 'Location_Info']]


# In[ ]:


# Convert the dictionary to a DataFrame
city_mapping_df = pd.DataFrame(list(city_mapping.items()), columns=['City', 'Location_Info'])

# Merge the new DataFrame with the filtered_df
merged_df = pd.merge(filtered_df, city_mapping_df, on='City', how='left')

# Initialize empty columns for State, District, and other geographical levels
for col in ['State', 'District', 'Subdistrict', 'Division', 'Union_Territory', 'Autonomous_Division']:
    merged_df[col] = None

# Function to extract relevant information based on common keywords
def extract_info(row):
    location_info = row['Location_Info']
    for info in location_info:
        if "District" in info:
            row['District'] = info
        elif "State" in info:
            row['State'] = info
        elif "Subdistrict" in info:
            row['Subdistrict'] = info
        elif "Division" in info:
            row['Division'] = info
        elif "Union Territory" in info:
            row['Union_Territory'] = info
        elif "Autonomous Division" in info:
            row['Autonomous_Division'] = info
    return row

# Apply the function to each row
transformed_df = merged_df.apply(extract_info, axis=1)

# Save the transformed DataFrame to a new CSV file
transformed_df.to_csv(wd+r'/transformed_city_mapping.csv', index=False)


# #### Loading a dictionary for mapping states to districts

# In[ ]:


district_mapping = pd.read_excel(wd+r'/India States Wiki.xlsx', sheet_name='Mapping')
district_mapping.head()


# In[ ]:


district_to_states = {}

# Populate the dictionary
for index, row in district_mapping.iterrows():
    state = row['State/Union Territory']
    districts = row['Districts'].split(', ')
    for district in districts:
        district_to_states[district] = state  # Corrected this line


# Still a few states aren't IDed. Based on my observation, the state name comes right after the district names. So I will try to extract the state name from the text and then map it to the district name.

# In[ ]:


# Function to extract district and state information
def extract_info(row):
    location_info = row['Location_Info']
    for i, info in enumerate(location_info):
        if "District" in info:
            # Extracting the district name from the string
            district_name = info.replace(' District', '').strip()
            row['District'] = district_name
            # Using known districts to find state
            if district_name in district_to_states:
                row['State'] = district_to_states[district_name]
            else:
                # If state is not found in the dictionary, look for it in the next item in location_info
                if i+1 < len(location_info):
                    potential_state = location_info[i+1].strip()
                    row['State'] = potential_state
    return row

# Initialize empty columns for State and District in your DataFrame
merged_df['State'] = None
merged_df['District'] = None

# Apply the function to each row
transformed_df = merged_df.apply(extract_info, axis=1)

# Save the transformed DataFrame to a new CSV file
transformed_df.to_csv(wd+r'/transformed_city_mapping.csv', index=False)


# In[45]:


transformed_df = pd.read_csv('transformed_city_mapping.csv')


# In[46]:


# Step 1: Split the transformed_city_mapping_df into two subsets: identified and unidentified
identified_df = transformed_df.dropna(subset=['District', 'State'])
unidentified_df = transformed_df[pd.isna(transformed_df['District']) | pd.isna(transformed_df['State'])]


# In[47]:




# Step 2: Merge the identified_df back into the original cleaned_location_df
# Using 'Unnamed: 0' as the merge key in both DataFrames
merged_cleaned_location_df = pd.merge(cleaned_location, identified_df[['Unnamed: 0', 'District', 'State']], 
                                      on='Unnamed: 0', how='left', suffixes=('', '_new'))

# Step 3: Replace the original District and State columns with the new identified data where applicable
merged_cleaned_location_df['District'].fillna(merged_cleaned_location_df['District_new'], inplace=True)
merged_cleaned_location_df['State'].fillna(merged_cleaned_location_df['State_new'], inplace=True)

# Step 4: Drop the temporary new columns
merged_cleaned_location_df.drop(columns=['District_new', 'State_new'], inplace=True)


# In[48]:


merged_cleaned_location_df.head()
merged_cleaned_location_df.to_csv(wd+r'/merged_cleaned_location.csv', index=False)


# In[51]:


merged_loc_df = merged_cleaned_location_df.copy()
# Update the District and State names for observations where City name is 'Delhi' or 'New Delhi'
merged_loc_df.loc[merged_loc_df['City'].isin(['Delhi', 'New Delhi']), ['District', 'State']] = 'New Delhi'


# In[53]:


unidentified_df = merged_loc_df[pd.isna(merged_loc_df['District']) | pd.isna(merged_loc_df['State'])]
unidentified_df.head()
unidentified_df.to_csv(wd+r'/unidentified.csv', index=False)


# In[55]:


identified_df = merged_loc_df.dropna(subset=['District', 'State'])

# Replace city names that are "Tis Hazari Courts, Delhi" with "Delhi" in the identified_df
identified_df.loc[identified_df['City'] == 'Tis Hazari Courts, Delhi', 'City'] = 'Delhi'

identified_df.to_csv(wd+r'/identified.csv', index=False)


# In[ ]:




