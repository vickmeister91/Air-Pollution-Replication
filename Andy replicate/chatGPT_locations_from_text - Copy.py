#!/usr/bin/env python
# coding: utf-8

# In[19]:


import pandas as pd
import numpy as np
import openai
from tqdm.notebook import tqdm
tqdm.pandas()
import time
from statsmodels.stats.weightstats import ztest as ztest
import tiktoken
import os


# In[ ]:



# Get the directory of the current script (run only when using batch scripts)
script_directory = os.path.dirname(os.path.abspath(__file__))

# Change the current working directory to the script's directory
os.chdir(script_directory)

# Confirm the change
print("Current Working Directory has been changed to:", os.getcwd())


# In[4]:


df = pd.read_csv("possible_air_corpus_with_meta_and_text.csv")


# In[5]:


df = df.sample(frac=1)


# In[6]:


df.head()


# In[7]:


len(df)


# In[8]:


def count_tokens(text):
    
    encoding = tiktoken.get_encoding("gpt2")


    input_ids = encoding.encode(text)
    num_tokens = len(input_ids)
    
    return num_tokens


# In[9]:


df["num_tokens"] = df["text"].apply(lambda x : count_tokens(x))


# In[10]:


df["num_tokens"].describe()


# In[12]:


def break_up_text_to_chunks(text, chunk_size=3500, overlap=100):

    encoding = tiktoken.get_encoding("gpt2")

    tokens = encoding.encode(text)
    num_tokens = len(tokens)
    
    chunks = []
    for i in range(0, num_tokens, chunk_size - overlap):
        chunk = tokens[i:i + chunk_size]
        chunks.append(chunk)
    
    return chunks


# In[13]:


df["chunks"] = df["text"].apply(lambda x : break_up_text_to_chunks(x))


# In[26]:




# In[27]:


def prompt_fn(chunks_list):
    
    prompt_response = []

    encoding = tiktoken.get_encoding("gpt2")
    
    
    for i, chunk in enumerate(chunks_list):
        
        #time.sleep(10)

        prompt_request = "In the following judgement order chunk, give me the location where this judgement had a jurisdiction (it can be a city, state or the entire country). If it is not possible to give the jurisdiction, simply write 'NOT POSSIBLE'." + encoding.decode(chunks_list[i])
        messages = [{"role": "system", "content": "You have to extract locations from text."}]    
        messages.append({"role": "user", "content": prompt_request})

        # https://towardsdatascience.com/gpt-3-parameters-and-prompt-design-1a595dc5b405
        response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=messages,
                temperature=0, # The temperature parameter is set between 0 and 1, with 0 being the most predictable and 1 being the most random
                max_tokens=10, # maximum tokens to be generated
                top_p=1,
                frequency_penalty=0,
                presence_penalty=0
        )
        prompt_response.append(response["choices"][0]["message"]['content'].strip())
        
    
    final_locs = str(prompt_response)
    
    return final_locs
        
        
    
    


# In[16]:


df = df.reset_index(drop=True)


# In[14]:


# kanoon_ids already done - 
# import glob
# import os

# list_paths = glob.glob("/Users/shashanksingh/Desktop/India_air/locresponses/*.txt")
# list_done = []
# for path in list_paths:
    
#     kanoon_id_done = int(os.path.split(path)[-1].replace(".txt", ""))
    
#     list_done.append(kanoon_id_done)


# In[15]:


# keep only the ones which are not done

# df = df[~df["kanoon_id"].isin(list_done)]
# df = df.reset_index(drop=True)


# In[17]:


len(df)


# In[30]:


df.chunks.head(10)


# In[20]:


new_directory_name = "locresponses"
path = os.path.join(os.getcwd(), new_directory_name)

try:
    os.makedirs(path, exist_ok=True)  # exist_ok=True allows the directory to already exist
    print(f"Directory '{new_directory_name}' created successfully")
except OSError as error:
    print(f"Directory '{new_directory_name}' could not be created: {error}")


# In[29]:


#df["chatgpt_summary"] = df["chunks"].progress_apply(lambda x : prompt_fn(x))
import tqdm

res = path+r"/"
for index in tqdm.trange(len(df)):
    
    time.sleep(5)
    
    text_chunks = df["chunks"][index]
    kanoon_id = int(df["kanoon_id"][index])
    

    
    try:
        summary = prompt_fn(text_chunks)

        filepath = res+str(int(kanoon_id))+".txt"

        f = open(filepath, "w+")

        f.write(summary)

        f.close()

    except:

        continue
        # print("{kanoon_id} is unsuccessful")
                
        # filepath = res+str(int(kanoon_id))+".txt"

        # f = open(filepath, "w+")

        # f.write("ERROR")

        # f.close()
        
    
    


# In[18]:


a = [1,2,3]


# In[19]:


str(a)


# In[ ]:




