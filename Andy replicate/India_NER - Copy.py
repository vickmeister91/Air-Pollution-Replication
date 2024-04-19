#!/usr/bin/env python
# coding: utf-8

# # Intro
# In this notebook, I attemp to conduct NER for Indian locations using several methods, the first method is using pre trained models from hugging face. 

# In[5]:


from geopy.geocoders import Nominatim
from tqdm import tqdm
import pandas as pd
import time
from math import isnan
import googlemaps
import json
import ast
import numpy as np


# In[2]:



# Initialize the Geolocator with a user agent
geolocator = Nominatim(user_agent="geoapiExercises")
# Function to get location details by available admin levels
def get_location_by_admin_levels(city=None, district=None, state=None, union_territory=None):
    query_parts = []
    
    def is_valid_part(part):
        return part and (not isinstance(part, float) or not isnan(part)) and str(part).lower() != "nan"
    
    if is_valid_part(city):
        query_parts.append(str(city))
    if is_valid_part(district):
        query_parts.append(str(district))
    if is_valid_part(state):
        query_parts.append(str(state))
    if is_valid_part(union_territory):
        query_parts.append(str(union_territory))
    
    query = ', '.join(query_parts) + ", India" if query_parts else None
    
    if query:
        location = geolocator.geocode(query)
        if location:
            return location.raw['display_name']
        else:
            return None
    return None

# Read the nonempty_admin CSV file into a DataFrame
nonempty_admin_df = pd.read_csv("C:/Users/andre/OneDrive - AWJCorp/Work/Georgetown RA/Joshi-DeJure/0_data/interim/nonempty_admin.csv")  # Replace with the actual path

# Initialize an empty list to store location details
location_details = []

# Loop through the DataFrame
for index, row in tqdm(nonempty_admin_df.iterrows(), total=nonempty_admin_df.shape[0], desc="Fetching location data"):
    city = row['City']
    district = row['District']
    state = row['State']
    union_territory = row['Union_Territory']
    
    # Get the location details
    location_data = get_location_by_admin_levels(city, district, state, union_territory)
    
    # Append to the list
    location_details.append(location_data if location_data else "Could not find data")
    
    # Pause to respect rate limits
    time.sleep(0.1)

# Add the location details as a new column to the original DataFrame
nonempty_admin_df['Location_Details'] = location_details

nonempty_admin_df.to_csv("C:/Users/andre/OneDrive - AWJCorp/Work/Georgetown RA/Joshi-DeJure/0_data/interim/new_location_mapping.csv", index=False)


# In[3]:


gmaps = googlemaps.Client(key='AIzaSyD0QRf3SB_1FAR6Kt8bnK2-72YpVn9M19Q')


# In[4]:


# Ordered list of administrative levels from largest to smallest
admin_levels = ['Zone', 'State', 'Union_Territory', 'Autonomous_Division', 'Division', 'District', 'Subdistrict', 'City']

# Create an empty list to store the results
api_outputs = []

# Loop through the DataFrame and update administrative levels
for index, row in tqdm(nonempty_admin_df.iterrows(), total=nonempty_admin_df.shape[0]):
    non_na_values = row[admin_levels].dropna()
    
    if len(non_na_values) >= 2:
        upper_bound = non_na_values.iloc[0]
        lower_bound = non_na_values.iloc[-1]
        
        # Create a partial address by concatenating upper and lower bounds
        partial_address = f"{lower_bound}, {upper_bound}"
        
        # Get geocode information for the partial address
        full_info = gmaps.geocode(partial_address)
        
        # Store the API's output as a string
        api_output_str = str(full_info)
        
        api_outputs.append(api_output_str)
    else:
        api_outputs.append(None)

# Add the API outputs as a new column to the original DataFrame
nonempty_admin_df['API_Output'] = api_outputs

nonempty_admin_df.to_csv("C:/Users/andre/OneDrive - AWJCorp/Work/Georgetown RA/Joshi-DeJure/0_data/interim/new_location_mapping.csv", index=False)


# In[6]:


nonempty_admin_df.head()


# In[11]:


def parse_api_output(row):
    # Initialize empty variables for each level
    locality = admin_level_1 = admin_level_2 = admin_level_3 = complete_address = ''
    
    if pd.notna(row['API_Output']):
        try:
            # Convert the string representation of a list of dictionaries to an actual list of dictionaries
            api_output_list = ast.literal_eval(row['API_Output'])
        
            # Loop through the list to get the first dictionary (we assume it's the most detailed one)
            if api_output_list:
                api_output = api_output_list[0]
                
                # Get the formatted address
                complete_address = api_output.get('formatted_address', '')
                
                # Parse address components to get admin levels
                for component in api_output.get('address_components', []):
                    if 'locality' in component['types']:
                        locality = component['long_name']
                    elif 'administrative_area_level_1' in component['types']:
                        admin_level_1 = component['long_name']
                    elif 'administrative_area_level_2' in component['types']:
                        admin_level_2 = component['long_name']
                    elif 'administrative_area_level_3' in component['types']:
                        admin_level_3 = component['long_name']
                
        except ValueError:
            print(f"Error parsing row: {row['API_Output']}")
    
    return pd.Series([locality, admin_level_1, admin_level_2, admin_level_3, complete_address], 
                     index=['Localities', 'Admin_Level_1', 'Admin_Level_2', 'Admin_Level_3', 'Complete_Address'])


# In[12]:


# Replace this line with your actual dataframe
nonempty_admin_df = pd.read_csv("C:/Users/andre/OneDrive - AWJCorp/Work/Georgetown RA/Joshi-DeJure/0_data/interim/new_location_mapping.csv")

# Apply the function and create new columns for admin levels and full address
parsed_df = nonempty_admin_df.apply(parse_api_output, axis=1)

# Merge the new columns back to the original DataFrame
result_df = pd.concat([nonempty_admin_df, parsed_df], axis=1)

# Show the DataFrame with the parsed admin levels and full address
print(result_df)


# In[13]:


result_df.head()


# In[14]:


result_df.to_csv("C:/Users/andre/OneDrive - AWJCorp/Work/Georgetown RA/Joshi-DeJure/0_data/interim/supplement_loc.csv", index=False)


# At this point, about 100 more cases have state, district identified. To really figure out the last ~20 cases, some manual coding is needed.

# Now this section goes back to the raw data to retry to extract locations using GPT 4 instead of gpt 3.5.
#  
# First, I will identify the kanoon id for cases that do not have a state or district identified.  Then, I will use GPT 4 to extract the location for these unidentified cases.

# In[23]:


unidentified_df = pd.read_csv("unidentified.csv")


# In[24]:


# Subset the DataFrame where the 'location' column has the value "ERROR"
subset_df = unidentified_df[unidentified_df['location'] == "ERROR"]


# In[25]:


subset_df.head()


# In[20]:


raw_df = pd.read_csv("possible_air_corpus_with_meta_and_text_cities.csv")
raw_df.head()


# In[ ]:


subset_df = subset_df[['kanoon_id', 'location']]

error_id = subset_df


# In[ ]:


error_df = pd.merge(error_id, raw_df, on='kanoon_id', how='left')
error_df.head()

