#!/usr/bin/env python
# coding: utf-8

# In[26]:


import pandas as pd
import json
import re
import ast
import numpy as np


# In[ ]:


# Get the directory of the current script (run only when using batch scripts)
script_directory = os.path.dirname(os.path.abspath(__file__))

# Change the current working directory to the script's directory
os.chdir(script_directory)

# Confirm the change
print("Current Working Directory has been changed to:", os.getcwd())
wd=os.getchdir()


# In[10]:


df_take2 = pd.read_csv(wd+r"/combined_gpt_take2.2.csv")


# In[11]:


# Function to parse and associate the significance of locations for each case
def parse_and_associate_significance(row):
    if pd.isnull(row):
        return {}
    
    parsed_dict = {}
    patterns = [
        ("State", r"The State is: ([^\n]*)"),
        ("District", r"The District is: ([^\n]*)"),
        ("City", r"The City is: ([^\n]*)"),
    ]
    
    for key, pattern in patterns:
        match = re.search(pattern, row)
        if match:
            locations_and_significance = match.group(1).split(", (")
            locations = locations_and_significance[0].split(", ")
            significance = locations_and_significance[1].rstrip(")") if len(locations_and_significance) > 1 else None

            if significance:
                significance_list = significance.split(", ")
                parsed_dict[key] = dict(zip(locations, significance_list))
            else:
                parsed_dict[key] = {location: None for location in locations}
    
    return parsed_dict

# Apply the function to the 'gpt_output' column
df_take2['parsed_gpt_output_with_significance'] = df_take2['gpt_output'].apply(parse_and_associate_significance)


# In[ ]:


df_take2.to_csv(wd+r"/combined_gpt_take2.2_sig.csv", index=False)


# In[19]:


df_take2 = pd.read_csv(wd+r"/combined_gpt_take2.2_sig.csv")


# In[21]:


def extract_extended_fields(text, start_field, end_field):
    """
    Extract the field value from the text based on the start_field and end_field.
    """
    pattern = f"{start_field}': {{(.*?)}}(?=, '{end_field}')"
    match = re.search(pattern, text)
    return match.group(1) if match else None


df_take2['State_text'] = df_take2['parsed_gpt_output_with_significance'].apply(lambda x: extract_extended_fields(x, 'State', 'District'))
df_take2['District_text'] = df_take2['parsed_gpt_output_with_significance'].apply(lambda x: extract_extended_fields(x, 'District', 'City'))
df_take2['City_text'] = df_take2['parsed_gpt_output_with_significance'].apply(lambda x: extract_extended_fields(x, 'City', '}'))


# In[22]:


df_take2.head()


# In[23]:



# Function to separate the texts before and after ':'
def separate_fields(text):
    if text:
        parts = text.split(':')
        if len(parts) == 2:
            return parts[0].strip("' "), parts[1].strip("' ")
    return None, None

# Separating the 'State_text', 'District_text', and 'City_text' into '_name' and '_meaning'
df_take2['State_name'], df_take2['State_meaning'] = zip(*df_take2['State_text'].apply(separate_fields))
df_take2['District_name'], df_take2['District_meaning'] = zip(*df_take2['District_text'].apply(separate_fields))
df_take2['City_name'], df_take2['City_meaning'] = zip(*df_take2['City_text'].apply(separate_fields))


# In[24]:


df_take2.head()


# In[27]:


# Function to split values separated by ';' and expand them into multiple columns
def split_and_expand(series, prefix):
    # Replace None with an empty string so the split operation doesn't fail
    split_values = series.fillna('').str.split(';')
    
    # Find the maximum number of split parts
    max_splits = max(split_values.apply(len))
    
    # Create new columns for each split part
    new_cols = {f"{prefix}{i+1}": [x[i] if i < len(x) else np.nan for x in split_values] for i in range(max_splits)}
    
    return pd.DataFrame(new_cols)


# Splitting and expanding 'State_name' and 'State_meaning'
state_names_expanded = split_and_expand(df_take2['State_name'], 'State_name_')
state_meanings_expanded = split_and_expand(df_take2['State_meaning'], 'State_meaning_')

# Splitting and expanding 'District_name' and 'District_meaning'
district_names_expanded = split_and_expand(df_take2['District_name'], 'District_name_')
district_meanings_expanded = split_and_expand(df_take2['District_meaning'], 'District_meaning_')

# Splitting and expanding 'City_name' and 'City_meaning'
city_names_expanded = split_and_expand(df_take2['City_name'], 'City_name_')
city_meanings_expanded = split_and_expand(df_take2['City_meaning'], 'City_meaning_')

# Concatenating the expanded columns back to the original DataFrame
df_take2_expanded = pd.concat([df_take2, state_names_expanded, state_meanings_expanded, 
                               district_names_expanded, district_meanings_expanded, 
                               city_names_expanded, city_meanings_expanded], axis=1)


# In[28]:


df_take2_expanded.to_csv(wd+r"/combined_gpt_take2.2_sig_expanded.csv", index=False)


# In[29]:


# Shifting the columns to the left to fill any empty cells while maintaining the DataFrame's structure
df_take2_condensed = df_take2_expanded.apply(lambda x: pd.Series(x.dropna().values), axis=1)

# Renaming the columns to match the original DataFrame
df_take2_condensed.columns = [col if i < len(df_take2_expanded.columns) else f"Unnamed_{i}" for i, col in enumerate(df_take2_condensed.columns)]


# In[30]:


# Identifying the original column names
original_columns = df_take2_expanded.columns.tolist()

# Shifting the columns to the left to fill any empty cells while maintaining the DataFrame's structure
df_take2_condensed = df_take2_expanded.apply(lambda x: pd.Series(x.dropna().values), axis=1)

# Renaming the columns to match the original DataFrame
df_take2_condensed.columns = original_columns[:df_take2_condensed.shape[1]] + [None] * (df_take2_condensed.shape[1] - len(original_columns))


# In[31]:


df_take2_condensed.to_csv(wd+r"/combined_gpt_take2.2_sig_condensed.csv", index=False)


# In[37]:


identified_df = pd.read_csv(wd+r"/identified.csv")


# In[38]:


# Convert all column names to lowercase for both dataframes
identified_df.columns = identified_df.columns.str.lower()
df_take2_condensed.columns = df_take2_condensed.columns.str.lower()

# Concatenate the two dataframes
final_df_lower = pd.concat([identified_df, df_take2_condensed], axis=0, ignore_index=True, sort=False)


# In[39]:


final_df_lower.to_csv(wd+r"/combined_gpt_final.csv", index=False)


# In[46]:


columns_to_drop = ['zone','union_territory','autonomous_division', 'division',
                   'subdistrict', 'state_text','district_text','city_text', 'district_name_10',
                   'district_name_9','district_name_8','district_name_7','district_name_6','district_name_5',
                   'state_name_9','state_name_8','state_name_7','state_name_6','state_name_5','district_name_4',
                   'district_name_3','district_name_2','district_name_1','state_meaning_3','state_meaning_2',
                   'state_meaning_1']
final_df=final_df_lower.drop(columns=columns_to_drop)


# In[59]:


final_df.to_csv(r"/combined_gpt_final.csv", index=False)


# In[ ]:





# In[60]:


unidentified = pd.read_csv(wd+r"/unidentified.csv")


# In[61]:


final_df['identified'] = 1
unidentified['identified'] = 0


# In[62]:


# Convert all column names to lowercase for both dataframes
final_df.columns = final_df.columns.str.lower()
unidentified.columns = unidentified.columns.str.lower()

# Append the unidentified dataframe to the final dataframe
final_appended_df = pd.concat([final_df, unidentified], axis=0, ignore_index=True, sort=False)
final_appended_df['attempt_2']=final_appended_df['content'].notna().astype(int)



# Create a new dummy variable 'attempt_1' based on the conditions for 'indicator_col' and 'attempt_2' columns
condition_1 = (final_appended_df['identified'] == 0) & (final_appended_df['attempt_2'] == 0)
condition_2 = (final_appended_df['identified'] == 1) & (final_appended_df['attempt_2'] == 0)
final_appended_df['attempt_1'] = (condition_1 | condition_2).astype(int)


# In[63]:


final_appended_df.to_csv(wd+r"/main_df.csv", index=False)

