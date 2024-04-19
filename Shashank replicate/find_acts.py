#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import pandas as pd
pd.set_option('display.max_columns', None)
import numpy as np
from nltk import FreqDist
import seaborn as sns
sns.set(rc={'figure.figsize':(11.7,8.27)})
import matplotlib.pyplot as plt
sns.set_palette("pastel")
import ast
import networkx as nx
from bs4 import BeautifulSoup
import regex as re
import tqdm
import glob
import os
from fuzzywuzzy import fuzz

import multiprocessing
from multiprocessing import Process, Manager

import numexpr as ne


# In[ ]:


citations_data = r"C:\Users\wb570559\Dropbox\AIR POLLUTION PROJECT\ANALYSIS\DATA\processed_data\citations_data_full\\"


# In[ ]:


df_main = pd.read_csv(citations_data+r"citations_data_full_kanoon.csv").drop(["Unnamed: 0"], axis=1)


# In[ ]:


df_main.head()


# In[ ]:


len(df_main)


# In[ ]:


len(df_main[df_main["acts_cited"]!="[]"])


# In[ ]:


df_non_null = df_main[df_main["acts_cited"]!="[]"]


# In[ ]:


preethikas_list = ["Water (Prevention and Control of Pollution) Act 1974 (Water Act)",
                  "Air (Prevention and Control of Pollution) Act 1981 (Air Act)",
                  "Environment (Protection) Act 1986 (EP Act)",
                  "E-Waste (Management) Rules 2016",
                  "Batteries (Management & Handling) Rules 2001",
                  "Battery Waste Management Rules 2020",
                  "Bio-Medical Waste Management Rules 2016",
                  "Plastic Waste Management Rules 2016",
                  "Solid Waste Management Rules 2016",
                  "Construction and Demolition Waste Management Rules 2016",
                  "Hazardous and Other Waste (Management and Transboundary Movement) Rules 2016",
                  "Manufacture, Storage and Import of Hazardous Chemicals Rules 1989 (MSIHC Rules)",
                  "Coastal Regulation Zone Notification 2019 (and related 2021 procedure for violation of the CRZ Notification)",
                  "Environment Impact Assessment Notification 2006",
                  "Wild Life (Protection) Act 1972",
                  "Forest (Conservation) Act 1980",
                  "Public Liability Insurance Act 1991",
                  "Biological Diversity Act 2002",
                  "National Green Tribunal Act 2010",
                  "Section 91 of the Civil Procedure Code",
                    "The Water (Prevention and Control of Pollution) Cess Act, 1977",
                    "The Forest (Conservation) Act, 1980",
                    "The Air (Prevention and Control of Pollution) Act, 1981",
                    "The Environment (Protection) Act, 1986",
                    "The Public Liability Insurance Act, 1991",
                    "The Biological Diversity Act, 2002"
                    ]


# In[ ]:


more_acts_from_text = ['the air  prevention and control of pollution  act  1981',
 'article 226 in the constitution of india   1949',
 'the environment  protection  act  1986',
 'the water  prevention and control of pollution  act  1974',
 'section 21 in the air  prevention and control of pollution  act  1981',
 'section 25 in the water  prevention and control of pollution  act  1974',
 'article 21 in the constitution of india   1949',
 'section 31 in the air  prevention and control of pollution  act  1981',
 'section 31a in the air  prevention and control of pollution  act  1981',
 'section 44 in the water  prevention and control of pollution  act  1974',
 'section 37 in the air  prevention and control of pollution  act  1981',
 'section 33a in the water  prevention and control of pollution  act  1974',
 'section 15 in the air  prevention and control of pollution  act  1981',
 'section 26 in the water  prevention and control of pollution  act  1974',
 'section 14 in the air  prevention and control of pollution  act  1981',
 'section 29 in the air  prevention and control of pollution  act  1981',
 'section 3 in the air  prevention and control of pollution  act  1981',
 'section 33 in the water  prevention and control of pollution  act  1974',
 'the national green tribunal act  2010',
 'section 25 in the air  prevention and control of pollution  act  1981',
 'section 5 in the environment  protection  act  1986',
 'section 47 in the water  prevention and control of pollution  act  1974',
 'section 43 in the water  prevention and control of pollution  act  1974',
 'section 28 in the water  prevention and control of pollution  act  1974',
 'section 3 in the environment  protection  act  1986',
 'section 6 in the air  prevention and control of pollution  act  1981',
 'article 32 in the constitution of india   1949',
 'section 15 in the environment  protection  act  1986',
 'm c  mehta vs union of india   ors on 18 march  2004',
 'section 24 in the water  prevention and control of pollution  act  1974']


# In[ ]:


final_list = preethikas_list+more_acts_from_text


# In[ ]:


def Punctuation(string):

    # punctuation marks
    punctuations = '''!()-[]{};:'"\,<>./?@#$%^&*_~'''

    # traverse the given string and if any punctuation
    # marks occur replace it with null
    string = string.replace("\n", "")
    for x in string.lower():
        if x in punctuations:
            string = string.replace(x, " ")
            
    string = string.strip()
    string = string.replace("  ", " ")
    
    return string


# In[ ]:


final_list = [Punctuation(ele.lower()) for ele in final_list]


# In[ ]:


final_list


# In[ ]:


final_list = ['water prevention and control of pollution act 1974 water act',
 'air prevention and control of pollution act 1981 air act',
 'environment protection act 1986 ep act',
 'e waste management rules 2016',
 'batteries management  handling rules 2001',
 'battery waste management rules 2020',
 'bio medical waste management rules 2016',
 'plastic waste management rules 2016',
 'solid waste management rules 2016',
 'construction and demolition waste management rules 2016',
 'hazardous and other waste management and transboundary movement rules 2016',
 'manufacture storage and import of hazardous chemicals rules 1989 msihc rules',
 'coastal regulation zone notification 2019 and related 2021 procedure for violation of the crz notification',
 'environment impact assessment notification 2006',
 'wild life protection act 1972',
 'forest conservation act 1980',

 'biological diversity act 2002',
 'national green tribunal act 2010',
 'section 91 of the civil procedure code',
 'the water prevention and control of pollution cess act 1977',
 'the forest conservation act 1980',
 'the air prevention and control of pollution act 1981',
 'the environment protection act 1986',
 'the public liability insurance act 1991',
 'the biological diversity act 2002',
 'the air prevention and control of pollution act 1981',

 'the environment protection act 1986',
 'the water prevention and control of pollution act 1974',
 'section 21 in the air prevention and control of pollution act 1981',
 'section 25 in the water prevention and control of pollution act 1974',

 'section 31 in the air prevention and control of pollution act 1981',
 'section 31a in the air prevention and control of pollution act 1981',
 'section 44 in the water prevention and control of pollution act 1974',
 'section 37 in the air prevention and control of pollution act 1981',
 'section 33a in the water prevention and control of pollution act 1974',
 'section 15 in the air prevention and control of pollution act 1981',
 'section 26 in the water prevention and control of pollution act 1974',
 'section 14 in the air prevention and control of pollution act 1981',
 'section 29 in the air prevention and control of pollution act 1981',
 'section 3 in the air prevention and control of pollution act 1981',
 'section 33 in the water prevention and control of pollution act 1974',
 'the national green tribunal act 2010',
 'section 25 in the air prevention and control of pollution act 1981',
 'section 5 in the environment protection act 1986',
 'section 47 in the water prevention and control of pollution act 1974',
 'section 43 in the water prevention and control of pollution act 1974',
 'section 28 in the water prevention and control of pollution act 1974',
 'section 3 in the environment protection act 1986',
 'section 6 in the air prevention and control of pollution act 1981',

 'section 15 in the environment protection act 1986',
 'm c mehta vs union of india  ors on 18 march 2004',
 'section 24 in the water prevention and control of pollution act 1974']


# In[ ]:


df_non_null["acts_cited"] = df_non_null["acts_cited"].apply(lambda x: ast.literal_eval(x))


# In[ ]:


from tqdm.notebook import tqdm
tqdm.pandas()


# In[ ]:


df_non_null["acts_cited"] = df_non_null["acts_cited"].progress_apply(lambda x: [Punctuation(ele.lower()) for ele in x])


# In[ ]:


df_non_null["acts_cited"]


# In[ ]:


def acts_matcher(list_green_acts, list_acts):
    
    #cache = 0
    list_matched_acts = []
    
    for act in list_acts:
        
        cache = 0
        flag = 0
        
        for green_act in list_green_acts:
            
            score = fuzz.token_set_ratio(act, green_act)
            
            if (score > 90 and score > cache):
                flag = 1
                cache = score
                matched_act = green_act
                
        if flag==1:
            
            list_matched_acts.append(matched_act)
            
        else:
            continue
            
    return list_matched_acts
                


# In[ ]:


df_non_null["matched_acts"] = df_non_null["acts_cited"].progress_apply(lambda x: acts_matcher(final_list, x))


# In[ ]:


df_non_null["matched_acts"].head()


# In[ ]:


df_non_null.to_csv(citations_data+"matched_acts.csv")


# In[ ]:


df_non_null["matched_acts"] = df_non_null["matched_acts"].apply(lambda x : str(x))


# In[ ]:


df_non_null_matched = df_non_null[df_non_null["matched_acts"]!="[]"]


# In[ ]:


len(df_non_null_matched)


# In[ ]:


df_non_null_matched["1981_dum"] = df_non_null_matched["matched_acts"].apply(lambda x: 1 if "1981" in x else 0)


# In[ ]:


df_non_null_matched["1981_dum"].describe()


# In[ ]:


df_non_null_matched.to_csv(citations_data+"possible_air_corpus.csv")


# In[20]:


import pandas as pd
pd.set_option('display.max_columns', None)
import numpy as np
from nltk import FreqDist
import seaborn as sns
sns.set(rc={'figure.figsize':(11.7,8.27)})
import matplotlib.pyplot as plt
sns.set_palette("pastel")
import ast
import networkx as nx
from bs4 import BeautifulSoup
import regex as re
import tqdm
import glob
import os
from fuzzywuzzy import fuzz

import multiprocessing
from multiprocessing import Process, Manager

import numexpr as ne


# In[21]:


citations_data = r"C:\Users\wb570559\Dropbox\AIR POLLUTION PROJECT\ANALYSIS\DATA\processed_data\citations_data_full\\"


# In[22]:


df_non_null_matched = pd.read_csv(citations_data+"possible_air_corpus.csv").drop(["Unnamed: 0"], axis=1)


# In[23]:


kanoon_metadata_path = r"C:\Users\wb570559\Dropbox\AIR POLLUTION PROJECT\INPUT\DATA\Law\cleaned_csv\cleaned_csv\\"


# In[24]:


df_citations = pd.read_csv(kanoon_metadata_path+"df_citations.csv").drop(["Unnamed: 0"], axis=1)


# In[25]:


df_cited_doc = pd.read_csv(kanoon_metadata_path+"df_cited_doc.csv").drop(["Unnamed: 0"], axis=1)


# In[26]:


df_judges = pd.read_csv(kanoon_metadata_path+"df_judges.csv").drop(["Unnamed: 0"], axis=1)


# In[27]:


df_meta =  pd.read_csv(kanoon_metadata_path+"df_meta.csv").drop(["Unnamed: 0"], axis=1)


# In[28]:


df_statutes = pd.read_csv(kanoon_metadata_path+"df_statutes.csv").drop(["Unnamed: 0"], axis=1)


# In[29]:


df_citations.head()


# In[30]:


df_cited_doc.head()


# In[31]:


df_judges.head()


# In[32]:


df_meta.head()


# In[33]:


df_statutes.head()


# In[34]:


df_non_null_matched.head()


# In[35]:


df_non_null_matched = pd.merge(df_non_null_matched, df_citations, on = "kanoon_id", how = "left")


# In[36]:


df_non_null_matched = pd.merge(df_non_null_matched, df_cited_doc, on = "kanoon_id", how = "left")


# In[37]:


df_non_null_matched = pd.merge(df_non_null_matched, df_judges, on = "kanoon_id", how = "left")


# In[38]:


df_non_null_matched = pd.merge(df_non_null_matched, df_meta, on = "kanoon_id", how = "left")


# In[39]:


df_non_null_matched.head()


# In[40]:


df_non_null_matched.to_csv(citations_data+"possible_air_corpus_with_meta.csv", index=False)


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




