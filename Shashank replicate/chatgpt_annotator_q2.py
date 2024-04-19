#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import openai
from tqdm.notebook import tqdm
tqdm.pandas()
from statsmodels.stats.weightstats import ztest as ztest
import glob
import os


# In[ ]:


# Get the directory of the current script (run only when using batch scripts)
script_directory = os.path.dirname(os.path.abspath(__file__))

# Change the current working directory to the script's directory
os.chdir(script_directory)

# Confirm the change
print("Current Working Directory has been changed to:", os.getcwd())
wd=os.getchdir()


# In[2]:


list_paths = glob.glob(wd+r"/chatgptsummaries/*.txt")


# In[3]:


list_kanoon = []
list_text = []

for path in list_paths:
    
    text = open(path, "r").read()
    kanoon_id = int(os.path.split(path)[-1].replace(".txt", ""))
    
    if text != "ERROR":
        
        list_kanoon.append(kanoon_id)
        list_text.append(text)
        
        


# In[4]:


df = pd.DataFrame()

df["kanoon_id"] = list_kanoon
df["summary"] = list_text


# In[5]:


question = "In the following judgement order summary, did the court ask the pollution control board to take an action? Give a binary answer, yes or no and then describe the action separated from the binary answer with a colon. The order is as follows - "


# In[6]:




# In[7]:


from tenacity import (
    retry,
    stop_after_attempt,
    wait_random_exponential,
)  # for exponential backoff


@retry(wait=wait_random_exponential(min=1, max=60), stop=stop_after_attempt(6))
def chatGPTresp(question, text, **kwargs):
    
    text = text.lower()
    text = text.replace("\n", "")
    text = text.replace("\t", "")
    text = text.replace("\t", "")
    
    prompt_request = question + text
    messages = [{"role": "system", "content": "You are an annotator"}]    
    messages.append({"role": "user", "content": prompt_request})


    response = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=messages,
                temperature=0, # The temperature parameter is set between 0 and 1, with 0 being the most predictable and 1 being the most random
                max_tokens=500, # maximum tokens to be generated
                top_p=1,
                frequency_penalty=0,
                presence_penalty=0,
                **kwargs
        )

    result = ''
    for choice in response.choices:
        result += choice.message.content
        

        
    return result
    
    


# In[8]:


df = df.sample(frac=1)
df = df.reset_index(drop=True)


# In[9]:


len(df)


# In[10]:


# list_paths = glob.glob(wd+r"/q2responses/*.txt")
list_done = []
# for path in list_paths:
    
#     kanoon_id_done = int(os.path.split(path)[-1].replace(".txt", ""))
    
#     list_done.append(kanoon_id_done)


# In[11]:


df = df[~df["kanoon_id"].isin(list_done)]
df = df.reset_index(drop=True)


# In[12]:


import tqdm
import time
res_path = wd+"/q2responses/"
for index in tqdm.trange(len(df)):

    
    summary = df["summary"][index]
    
    kanoon_id = df["kanoon_id"][index]
    
    #if kanoon_id not in list_done:
        
    #time.sleep(1)
    
    resp = chatGPTresp(question, summary)

    filepath = res_path+str(int(kanoon_id))+".txt"

    f = open(filepath, "w+")

    f.write(resp)

    f.close()

