#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np

import nltk

 
# essential entity models downloads
nltk.downloader.download('maxent_ne_chunker')
nltk.downloader.download('words')
nltk.downloader.download('treebank')
nltk.downloader.download('maxent_treebank_pos_tagger')
nltk.downloader.download('punkt')
nltk.download('averaged_perceptron_tagger')


# In[2]:


citations_data = r"C:\Users\wb570559\Dropbox\AIR POLLUTION PROJECT\ANALYSIS\DATA\processed_data\citations_data_full\\"


# In[3]:


# data of matched acts/additional corpus - 

df = pd.read_csv(citations_data+"possible_air_corpus_with_meta.csv")


# In[4]:


df.head()


# In[5]:


## add text - 
import glob
import os
import tqdm
from bs4 import BeautifulSoup 


# In[6]:


KANOON = r"D:\indian_kanoon_raw\\"
file_paths = glob.glob(KANOON+"**\**\**\*.txt")


# In[7]:


kanoon_ids = list(df["kanoon_id"].unique())


# In[8]:


kanoon_ids[0]


# In[9]:


os.path.split(file_paths[0])


# In[10]:


kanoon_dict = {}

for kanoon_path in tqdm.tqdm(file_paths):
    
    id_ = os.path.split(kanoon_path)[-1]
    
    kanoon_dict[id_] = kanoon_path


# In[11]:


list_text = []

dict_text = {}

for kanoon_id in tqdm.tqdm(kanoon_ids):
    
    kanoon_id_raw = kanoon_id
    
    kanoon_id = str(kanoon_id)+".txt"
    
    path = kanoon_dict[kanoon_id]
    
    f = open(path, "r", encoding="utf-8")
    
    text = f.read()
    
    soup = BeautifulSoup(text,'lxml')
    
    judgement = soup.findAll("div", {"class": "judgments"})[0].text
    
    try:
        docsource_main = soup.findAll("div", {"class": "docsource_main"})[0].text
        judgement = judgement.replace(docsource_main, "")
    except:
        pass
    
    try:
        doc_title = soup.findAll("div", {"class": "doc_title"})[0].text
        judgement = judgement.replace(doc_title, "")
    except:
        pass
    
    try:
        doc_author = soup.findAll("div", {"class": "doc_author"})[0].text
        judgement = judgement.replace(doc_author, "")
    except:
        pass
    
    try:
        doc_bench = soup.findAll("div", {"class": "doc_bench"})[0].text
        judgement = judgement.replace(doc_bench, "")
    except:
        pass
    
    dict_text[kanoon_id_raw] = judgement
    
    


# In[12]:


df["text"] = df["kanoon_id"].apply(lambda x : dict_text[x])


# In[13]:


df["text"][0]


# In[14]:


df.to_csv(citations_data+"possible_air_corpus_with_meta_and_text.csv", index=False)


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




