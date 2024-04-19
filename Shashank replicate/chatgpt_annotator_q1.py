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


question = "In the following summary of a judgement order, predict on a scale of 0-100 if the order had a pro-environmental impact where 100 is the most pro-environment. Give a number from 0 to 100 and then give the reason separated from the binary answer with a colon. The summary is as follows - "


# In[6]:

# openai.api_key = ""


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
    messages = [{"role": "system", "content": "You are a annotator"}]    
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


# list_paths = glob.glob(wd+"/q1responses/*.txt")
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
res_path = wd+r"/q1responses/"
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


# In[13]:


import pandas as pd
import numpy as np
import openai
from tqdm.notebook import tqdm
tqdm.pandas()
from statsmodels.stats.weightstats import ztest as ztest
import glob
import os
import regex as re
pd.set_option('display.max_columns', None)


# In[14]:


res_path = wd+r"/q1responses/*.txt"
paths = glob.glob(res_path)


# In[15]:


dict_vals = {}
list_kanoon_ids = []

for path in paths:
    
    f = open(path).read()
    
    val = re.findall(r"\d+", f)[0]
    
    kanoon_id = int(os.path.split(path)[-1].replace(".txt", ""))
    
    dict_vals[kanoon_id] = val
    
    list_kanoon_ids.append(kanoon_id)
    
    #list_vals.append(val)


# In[ ]:


df = pd.DataFrame()


# In[ ]:


df["Kanoon_ID"] = list_kanoon_ids


# In[ ]:


df["chatgpt_val"] = df["Kanoon_ID"].apply(lambda x : dict_vals[x])


# In[ ]:


df_null = df[df["chatgpt_val"]==""]


# In[ ]:


df_null


# In[ ]:


df["chatgpt_val"] = df["chatgpt_val"].apply(lambda x : float(x))


# In[ ]:


df["chatgpt_binary"] = df["chatgpt_val"].apply(lambda x :1 if x>50 else 0)


# In[ ]:


df["chatgpt_binary"].describe()


# In[ ]:


df_cases = pd.read_csv(wd+r"/case_data_final_with_additional_variables.csv")


# In[ ]:


df_cases = df_cases[["Kanoon_ID", "impact_coded"]]


# In[ ]:



df_merged = pd.merge(df, df_cases, on = ["Kanoon_ID"])


# In[ ]:


df_merged.describe()


# In[ ]:


import seaborn as sns


# In[ ]:


sns.kdeplot(data=df_merged[["impact_coded", "chatgpt_binary"]])


# In[ ]:


#perform two sample z-test
ztest(df_merged["impact_coded"], df_merged["chatgpt_binary"], value=0) 


# In[ ]:


# chatgpt as third coder, average over 3
# heterogenous analysis of kind of case vis-a-vis chatgpt, common support (find the exact types of cases)
# regress on length, type, govt, appeal, constitutional
# extract locations (jurisdictions)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




