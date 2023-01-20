#!/usr/bin/env python
# coding: utf-8

# In[16]:


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
import random

import multiprocessing
from multiprocessing import Process, Manager

import numexpr as ne

import logging
logging.basicConfig(format='%(asctime)s [%(levelname)s] %(message)s',
                    level=logging.INFO)


# In[36]:


def make_data(store_path, chunk_of_files, process_number):
    
    dict_titles_cited = {}

    for path_to_text in chunk_of_files:

        path = path_to_text
        k = int(os.path.split(path)[-1].replace(".txt", ""))
        f = open(path, "r", encoding = "utf-8").read()
        try:
            soup = BeautifulSoup(f, 'lxml')
            text_ = soup.findAll("div", {"class": "judgments"})
            text = [ele.text for ele in text_]
            titles_ = soup.findAll("div", {"class": "cite_title"})
            acts = [ele.text for ele in titles_]
        except:
            acts = ["try-except error"]
            
        filename = r"\\"+str(k)+".csv"
        
        df = pd.DataFrame(columns = ["kanoon_id", "acts_cited"], data = [(k, str(acts))])
        #filename = r"\\"+str(process_number)+".csv"
        df.to_csv(store_path+filename)
    


# In[ ]:


if __name__ == "__main__":
    
    store_dir = ANALYSIS = r"C:\Users\wb570559\Dropbox\AIR POLLUTION PROJECT\ANALYSIS\DATA\processed_data\citations_data_full\\"
    
    if not os.path.exists(store_dir):
        
        os.mkdir(store_dir)
        
    KANOON = r"D:\indian_kanoon_raw\\"
    file_paths = glob.glob(KANOON+"**\**\**\*.txt")
    
    random.shuffle(file_paths)
    
    num_processes = 200
    len_chunk = int(len(file_paths)/num_processes)
    chunks = [file_paths[x:x+len_chunk] for x in range(0, len(file_paths), len_chunk)]
    effective_num_processes = len(chunks)
    
    
    list_processes = []

    for proc_num in range(len(chunks)):
        
        store_path_proc = os.path.join(store_dir, str(proc_num)+"_process")
        
        if not os.path.exists(store_path_proc):
            os.mkdir(store_path_proc)
            


        p = Process(target=make_data, args = (store_path_proc, chunks[proc_num], proc_num))
        #p = Process(target=make_csvs, args = (chunks[proc_num],df_main,df_citations,))

        list_processes.append(p)


    logging.info("Starting Processes")

    import tqdm

    for process_num in tqdm.trange(len(list_processes)):
        list_processes[process_num].start()

    logging.info("Joining Processes")

    for process_num in tqdm.trange(len(list_processes)):
        list_processes[process_num].join()

