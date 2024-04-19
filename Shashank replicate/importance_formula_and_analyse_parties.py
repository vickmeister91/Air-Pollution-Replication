#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import tqdm
import os

import logging
logging.basicConfig(format='%(asctime)s [%(levelname)s] %(message)s',
                    level=logging.INFO)

import nltk
from nltk import FreqDist

from fuzzywuzzy import fuzz
from bs4 import BeautifulSoup
import lxml
import re

pd.set_option('display.max_columns', None)


# In[2]:


path_to_text = r"C:\Users\wb570559\github\india_air_pollution\data\raw_data\Air Pollution text\Air Pollution text\\"


# In[3]:


# root_dir = r"C:\Users\wb570559\github\india_air_pollution\data\processed_data\\"


# In[4]:


import requests
from io import BytesIO

def download_excel_to_dataframe(url):
    response = requests.get(url)
    
    response.raise_for_status()
    
    data = BytesIO(response.content)
    df = pd.read_excel(data, engine='openpyxl') 
    
    return df

url = "https://www.dropbox.com/scl/fi/ecd6ir1rsrb8flgbs6vdt/Air-Pollution-Cases_updated-17.10.21.xlsx?rlkey=rsnrrb6i0l1hisw82t4r1lazk&e=1&dl=1"

df = download_excel_to_dataframe(url)




# In[5]:


k_ids = list(df["Kanoon_ID"].unique())


# In[6]:


list_loc_paths = []

for k in k_ids:
    
    list_loc_paths.append(path_to_text+"/"+str(int(k))+".html")


# In[7]:


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
    
    return string


# In[8]:


dict_html = {}
dict_text = {}
dict_titles_cited = {}

for k in tqdm.tqdm(k_ids):
    
    path = path_to_text+"/"+str(int(k))+".html"
    f = open(path, "r", encoding = "utf-8").read()
    soup = BeautifulSoup(f, 'lxml')
    text_ = soup.findAll("div", {"class": "judgments"})
    text = [ele.text for ele in text_]
    titles_ = soup.findAll("div", {"class": "cite_title"})
    titles = [Punctuation(str(ele.text).lower()) for ele in titles_]

    dict_html[k] = soup
    dict_text[k] = text
    dict_titles_cited[k] = titles


# In[9]:


#df["html"] = df["Kanoon_ID"].apply(lambda x : dict_html[x])
df["text"] = df["Kanoon_ID"].apply(lambda x : dict_text[x])
df["titles_cited"] = df["Kanoon_ID"].apply(lambda x : dict_titles_cited[x])


# In[10]:


df["titles_cited"][0]


# In[11]:


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


# In[12]:


preethikas_list = [Punctuation(ele.lower()) for ele in preethikas_list]


# In[13]:


df = df.drop_duplicates(["Kanoon_ID"], keep = "first")
list_all_acts = list(df["titles_cited"])


# In[14]:


list_all_acts_flat = [item for sublist in list_all_acts for item in sublist]


# In[15]:


from nltk import FreqDist


# In[16]:


freqlist = FreqDist(list_all_acts_flat).most_common(50)


# In[17]:


df_top50_cit = pd.DataFrame(data = freqlist, columns = ["cited_title", "frequency"])


# In[18]:


df_top50_cit["cited_title"][0]


# In[19]:


df_top50_cit["frequency"][0]


# In[20]:


df_top50_cit_temp = df_top50_cit[df_top50_cit["cited_title"]!="the air  prevention and control of pollution  act  1981"]


# In[21]:


import plotly.express as px
#data_canada = px.data.gapminder().query("country == 'Canada'")
fig = px.bar(df_top50_cit_temp, x='cited_title', y='frequency',width=1600, height=800)
fig.show()


# In[22]:


#Non pollution/ambiguous acts (I think) in the top 50 - 
# 'the air force act  1950'
# 'section 379 in the indian penal code'
# 'section 420 in the indian penal code'
# 'section 411 in the indian penal code'
# 'section 438 2  in the code of criminal procedure    1973'
# 'the code of criminal procedure    1973'
# 'the state of uttar pradesh vs mohammad nooh on 30 september  1957'
# 'the registration act  1908'
# 'section 482 in the code of criminal procedure    1973'
# 'the companies act    1956'
# 'section 34 in the indian penal code'
# 'the code of criminal procedure  amendment  act    2005'
# 'article 227 in the constitution of india   1949'
# 'article 14 in the constitution of india   1949'
# 'the industrial disputes act    1947'
# 'article 12 in the constitution of india   1949'
# 'the central excise act  1944'
# 'the factories act  1948'
# 'section 21 in the air force act  1950'


# In[23]:


vague_acts = ['the air force act  1950'
, 'section 379 in the indian penal code'
, 'section 420 in the indian penal code'
, 'section 411 in the indian penal code'
, 'section 438 2  in the code of criminal procedure    1973'
, 'the code of criminal procedure    1973'
, 'the state of uttar pradesh vs mohammad nooh on 30 september  1957'
, 'the registration act  1908'
, 'section 482 in the code of criminal procedure    1973'
, 'the companies act    1956'
, 'section 34 in the indian penal code'
, 'the code of criminal procedure  amendment  act    2005'
, 'article 227 in the constitution of india   1949'
, 'article 14 in the constitution of india   1949'
, 'the industrial disputes act    1947'
, 'article 12 in the constitution of india   1949'
, 'the central excise act  1944'
, 'the factories act  1948'
, 'section 21 in the air force act  1950']


# In[24]:


important_acts = [ele for ele in list(df_top50_cit["cited_title"]) if ele not in vague_acts]


# In[25]:


important_acts


# In[25]:


#important_acts_scores_dict = {}

df_top50_cit_important = df_top50_cit[df_top50_cit["cited_title"].isin(important_acts)]


# In[26]:


total_freq = df_top50_cit_important["frequency"].sum()


# In[27]:


# discount fot "the air  prevention and control of pollution  act  1981"
discount_frequency = df_top50_cit[df_top50_cit["cited_title"]=="the air  prevention and control of pollution  act  1981"].reset_index(drop=True)["frequency"][0]
total_freq = total_freq-discount_frequency


# In[28]:


df_top50_cit_important["scores"] = df_top50_cit_important["frequency"].apply(lambda x : x/total_freq)


# In[29]:


dict_important_cit = dict(zip(df_top50_cit_important["cited_title"],
                              df_top50_cit_important["scores"]))


# In[30]:


def importance_score(list_acts_cited):
    
    total = len(list_acts_cited)
    
    if total!=0:
    
        important_acts_cited = [ele for ele in list_acts_cited if ele in important_acts]

        vague_acts_cited = [ele for ele in list_acts_cited if ele in vague_acts]

        neg_score = -1*len(vague_acts_cited)

        pos_score = sum([dict_important_cit[ele] for ele in important_acts_cited])

        numerator = pos_score+neg_score

        final_score = numerator/total
        
    else:
        final_score = np.nan
    
    return final_score


# In[31]:


df["importance_score"] = df["titles_cited"].apply(lambda x : importance_score(x))


# In[32]:


df = df.sort_values(["importance_score"], ascending = False)


# In[33]:


print(df["importance_score"][2608])


# In[34]:


# very low ranking case, indeed unrelated to pollution
print(df["text"][2608][0])


# In[35]:


len(df)


# In[36]:


len(df[df["importance_score"]>0])


# In[37]:


len(df[df["importance_score"]>=0])


# In[38]:


# least scoring 100 cases
df = df.sort_values(["importance_score"], ascending = True)
df[:100]


# In[39]:


# let us check another one - 


# In[40]:


print(df["text"][2269][0])


# In[41]:


print(df["titles_cited"][2370])


# In[42]:


# max scoring 100 cases
df = df.sort_values(["importance_score"], ascending = False)
df["importance_score"][120]


# In[43]:


df


# In[44]:


df["importance_score"][1]


# In[45]:


print(df["text"][1][0])


# In[46]:


print(df["text"][2211][0])


# In[47]:


print(df["text"][2007][0])


# In[48]:


#len(df)


# In[49]:


root_dir = r"C:\Users\wb570559\github\india_air_pollution\data\processed_data\\"


# In[50]:


#df_cases = pd.read_csv(root_dir+"case_data_final.csv")
df_cases = df


# In[51]:


df_cases.head()


# In[52]:


# Function to remove punctuation
def Punctuation(string):

    # punctuation marks
    punctuations = '''!()-[]{};:'"\<>./?@#$%^&*_~'''

    # traverse the given string and if any punctuation
    # marks occur replace it with null
    string = string.replace("\n", "")
    for x in string.lower():
        if x in punctuations:
            string = string.replace(x, " ")

    string = string.replace("  ", " ")
    string = string.replace("smt", " ")
    string = string.replace("mr ", " ")

    string = string.replace("dr ", " ")

    string = string.replace("shri ", " ")

    string = string.replace("sri ", " ")
    string = string.replace(" sri ", " ")
    string = string.replace("srimati ", " ")
    string = string.replace("srimati", " ")
    string = string.replace("shrimati ", " ")
    string = string.replace("shrimati", " ")
    string = string.replace("ms ", " ")
    string = string.replace("mrs", " ")

    string = string.replace("chief", " ")
    string = string.replace("hon'", " ")
    string = string.replace("justice ", " ")
    string = string.replace("justice", " ")
    string = string.replace("judge ", " ")
    string = string.replace("judge", " ")
    string = string.replace("honourable", " ")
    string = string.replace("the hon ble", " ")
    string = string.replace("the ", " ")
    string = string.replace("hon ", " ")
    string = string.replace("ble", " ")
    string = string.replace(" j ", " ")
    string = string.replace("addl.", " ")
    string = string.replace("  ", " ")
    string = string.replace("  ", " ")
    string = string.replace("  ", " ")
    string = string.replace("  ", " ")

    string = string.strip()

    return string.lower()


# In[53]:


df_cases["Petitioners"] = df_cases["Petitioners"].apply(lambda x : Punctuation(str(x)))
df_cases["Respondents"] = df_cases["Respondents"].apply(lambda x : Punctuation(str(x)))


# In[54]:


df_cases["Petitioners"]


# In[55]:


from nltk import FreqDist


# In[56]:


FreqDist(df_cases["Petitioners"]).most_common()


# In[57]:


FreqDist(df_cases["Respondents"]).most_common()


# In[58]: Dummy varaibles to identify officers among the petitioners adn the respondents


df_cases["officer_petitioner"] = df_cases["Petitioners"].apply(lambda x : 1 if "officer" in x else 0)
df_cases["officer_respondent"] = df_cases["Respondents"].apply(lambda x : 1 if "officer" in x else 0)


# In[59]:


df_temp = df_cases[(df_cases["officer_respondent"]==0)&
        (df_cases["officer_petitioner"]==0)&
        (df_cases["importance_score"]>0)]


# In[60]:


len(df_temp)


# In[61]:


list(df_temp["Kanoon_ID"])


# In[62]:


df_temp


# In[ ]:





# In[ ]:





# In[63]:


df_cases[["officer_petitioner", "officer_respondent"]].describe()


# In[64]:


df_cases[df_cases["officer_respondent"]==1]


# In[65]:


df_officer_respondent_and_relevant = df_cases[(df_cases["officer_respondent"]==1) & (df_cases["importance_score"]>0)]


# In[66]:


print(df_officer_respondent_and_relevant[df_officer_respondent_and_relevant["Kanoon_ID"] == 113843692]["text"][1][0])


# In[67]:


print(df_officer_respondent_and_relevant[df_officer_respondent_and_relevant["Kanoon_ID"] == 107407377]["text"].reset_index(drop=True)[0][0])


# In[68]:


print(df_officer_respondent_and_relevant[df_officer_respondent_and_relevant["Kanoon_ID"] == 337598]["text"].reset_index(drop=True)[0][0])


# In[69]:


print(df_officer_respondent_and_relevant[df_officer_respondent_and_relevant["Kanoon_ID"] == 184254528]["text"].reset_index(drop=True)[0][0])


# In[70]:


print(df_officer_respondent_and_relevant[df_officer_respondent_and_relevant["Kanoon_ID"] == 184254528]["Respondents"].reset_index(drop=True)[0])


# In[71]:


df_officer_respondent_and_relevant["num_respondents"] = df_officer_respondent_and_relevant["Respondents"].apply(lambda x : len(x.split(",")))


# In[72]:


df_officer_respondent_and_relevant[df_officer_respondent_and_relevant["num_respondents"]==1]


# In[73]: series of checks to see if the variables are correctly generated


print(df_officer_respondent_and_relevant[df_officer_respondent_and_relevant["Kanoon_ID"] == 180238080]["text"].reset_index(drop=True)[0][0])


# In[74]:


print(df_officer_respondent_and_relevant[df_officer_respondent_and_relevant["Kanoon_ID"] == 81767104]["text"].reset_index(drop=True)[0][0])


# In[75]:


print(df_officer_respondent_and_relevant[df_officer_respondent_and_relevant["Kanoon_ID"] == 16342065]["text"].reset_index(drop=True)[0][0])


# In[76]:


## pro-green vis-a-vis type of case (govt involved? T test?)
## variable for size -- do this to filter cases, in addition to the formula -- 
## explore the number of judges, are those cases important?
## word count, citation count as quality variables
## regression within the case data -- correlation w coded values 

## appeal might be correlated w number of judges -- higher courts

## double check for law students coded


# In[77]:


df_cases.head()


# In[78]:


df_cases["num_titles_cited"] = df_cases["titles_cited"].apply(lambda x : len(x))


# In[79]:


# Function to remove punctuation
def Punctuation(string):

    # punctuation marks
    punctuations = '''!()-[]{};:'"\<>./?@#$%^&*_~'''

    # traverse the given string and if any punctuation
    # marks occur replace it with null
    string = string.replace("\n", "")
    for x in string.lower():
        if x in punctuations:
            string = string.replace(x, " ")

    string = string.strip()

    return string.lower()


# In[80]:


df_cases["length_of_case"] = df_cases["text"].apply(lambda x : len(Punctuation(x[0]).split()))


# In[81]:


df_cases.head()


# In[82]:


len(df_cases["Kanoon_ID"].unique())


# In[83]: Import the already cleaned case data to merge with the currently processed dataframe
from io import StringIO

def download_csv_to_dataframe(url):
    response = requests.get(url)
    response.raise_for_status()  # Ensure the download was successful
    data_string = StringIO(response.text)
    df = pd.read_csv(data_string)
    return df

url = "https://www.dropbox.com/scl/fo/bc2v5kd1e3vfu1lbksnb1/h/ANALYSIS/DATA/processed_data/case_data_final.csv?rlkey=4wmgcxy6ioswyjpijxmsehpfn&dl=1"
df_cases_cleaned_and_processed = download_csv_to_dataframe(url)



# df_cases_cleaned_and_processed = pd.read_csv(r"C:\Users\wb570559\github\india_air_pollution\data\processed_data\case_data_final.csv")


# In[84]:


len(df_cases_cleaned_and_processed["Kanoon_ID"].unique())


# In[85]:


df_cases = df_cases[["Kanoon_ID", "text", "titles_cited", "importance_score", "officer_petitioner",
                     "officer_respondent", "num_titles_cited", "length_of_case"]]


# In[86]:


df_cases = df_cases.drop_duplicates(["Kanoon_ID"], keep="first")


# In[87]:


df_cases_merged = pd.merge(df_cases_cleaned_and_processed,
                           df_cases,
                           left_on = "Kanoon_ID",
                           right_on = "Kanoon_ID",
                           how = "left")


# In[88]:


df_cases_merged


# In[89]:


df_cases_merged["num_judges"]


# In[90]:


df_cases_merged.to_csv(r"C:\Users\wb570559\github\india_air_pollution\data\processed_data\case_data_final_with_additional_variables.csv")


# In[92]:


list(df_cases_merged.columns)


# In[ ]:





# In[ ]:




