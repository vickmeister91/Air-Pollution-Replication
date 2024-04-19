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

class preprocessor():

    """
    Inputs:
    path_to_raw_data_dir -> path to raw_data dir
    path_to_target_dir -> path where you want to store the cleaned data
    path_to_text -> Path to text files
    
    Outputs -
    1. Cleaned Judges Data
    2. Cleaned Cases Data
 
    
    """
    def __init__(self,path_to_raw_data_dir,path_to_target_dir,path_to_text):
        
        self.root_raw_data = path_to_raw_data_dir
        
        self.root_res_data = path_to_target_dir
        
        self.path_to_text_files = path_to_text
        #def load_datasets(self):
        
        self.judge_df = pd.read_excel(self.root_raw_data + "/Akhilesh_Judges_Edit.xls")
        
        self.case_df = pd.read_excel(self.root_raw_data + "/Air Pollution Cases_updated 17.10.21.xlsx")
        
        
        
    
    def judge_data_preprocess(self):
        
        df_judges = self.judge_df
        df_judges = df_judges.reset_index(drop = True)
        
        
        df_judges["name_cleaned"] = df_judges["Name"].apply(lambda x : str(x).lower())
        
        # Function to remove punctuation
        def Punctuation(string):
          
            # punctuation marks
            punctuations = '''!()-[]{};:'"\,<>./?@#$%^&*_~'''
          
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

            return string
            
            
        df_judges["name_cleaned"] = df_judges["name_cleaned"].apply(lambda x : Punctuation(x))
        #df = df.sample(frac = 1)
        df_judges = df_judges.reset_index(drop = True)
        
        #df_judges = df_judges[["Name","name_cleaned", "Gender", "Education","practice_area","State","DateofBirth","JoiningattheState"]]
        
        df_nonan = df_judges[df_judges['Name'].notnull()]
        df_nonan = df_nonan[df_nonan["name_cleaned"] != '']
        df_nonan = df_nonan.sort_values(["name_cleaned", "Gender", "Education","practice_area"])
        df_nonan = df_nonan.reset_index(drop=True)
        
        df_nonan.to_csv(self.root_res_data + "/judge_data.csv", index=False)
        
        self.df_nonan = df_nonan
        
        return self.df_nonan
        
        
    def case_data_preprocess_stage1(self):
    
        df_nonan = self.judge_data_preprocess()
        #coded Kanoon Cases -
        df_main = self.case_df

        # Function to remove punctuation
        def Punctuation(string):
          
            # punctuation marks
            punctuations = '''!()-[]{};:'"\,<>./?@#$%^&*_~'''
          
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

            return string
            
            
        df_main["name_cleaned_1"] = df_main["Judge 1"].apply(lambda x : str(x).lower().strip())
        df_main["name_cleaned_2"] = df_main["Judge 2"].apply(lambda x : str(x).lower().strip())
        df_main["name_cleaned_3"] = df_main["Judge 3"].apply(lambda x : str(x).lower().strip())

        df_main["name_cleaned_1"] = df_main["name_cleaned_1"].apply(lambda x : Punctuation(x))
        df_main["name_cleaned_2"] = df_main["name_cleaned_2"].apply(lambda x : Punctuation(x))
        df_main["name_cleaned_3"] = df_main["name_cleaned_3"].apply(lambda x : Punctuation(x))

        df_main["name_cleaned_1"] = df_main["name_cleaned_1"].apply(lambda x : Punctuation(x))
        df_main["name_cleaned_2"] = df_main["name_cleaned_2"].apply(lambda x : Punctuation(x))
        df_main["name_cleaned_3"] = df_main["name_cleaned_3"].apply(lambda x : Punctuation(x))
        
        unique_names_list = list(df_nonan["name_cleaned"].unique())
        list_1 = []
        list_1_count = []
        list_2 = []
        list_2_count = []
        list_3 = []
        list_3_count = []
        
        #fuzzy string matching to match judges
        for index in tqdm.trange(len(df_main)):
            temp_list_1 = []
            temp_list_2 = []
            temp_list_3 = []
            judge_1 = str(df_main["name_cleaned_1"][index])
            ratio_1 = 0
            judge_2 = str(df_main["name_cleaned_2"][index])
            ratio_2 = 0
            judge_3 = str(df_main["name_cleaned_3"][index])
            ratio_3 = 0
            
            if(judge_1 == "nan" or judge_1 == ''):
                list_1.append(None)
                list_1_count.append(None)
                
            else:
                temp_j_fin = None
                for k in range(len(unique_names_list)):
                    temp_j = str(unique_names_list[k])
                    ratio = fuzz.token_set_ratio(temp_j, judge_1)
                    #temp_j_fin = None
                    if(ratio>80):
                        if(ratio>ratio_1):
                            ratio_1 = ratio
                            temp_j_fin = temp_j

                list_1.append(temp_j_fin)
                #list_1_count.append(len(temp_list_1))
                        
                
            if(judge_2 == "nan" or judge_2 == ''):
                list_2.append(None)
                list_2_count.append(None)
                
            else:
                temp_j_fin = None
                for k in range(len(unique_names_list)):
                    temp_j = str(unique_names_list[k])
                    ratio = fuzz.token_set_ratio(temp_j, judge_2)
                    #temp_j_fin = None
                    if(ratio>80):
                        if(ratio>ratio_2):
                            ratio_2 = ratio
                            temp_j_fin = temp_j

                list_2.append(temp_j_fin)
                
            if(judge_3 == "nan" or judge_3 == ''):
                list_3.append(None)
                list_3_count.append(None)
                
            else:
                temp_j_fin = None
                for k in range(len(unique_names_list)):
                    temp_j = str(unique_names_list[k])
                    ratio = fuzz.token_set_ratio(temp_j, judge_3)
                    #temp_j_fin = None
                    if(ratio>80):
                        if(ratio>ratio_3):
                            ratio_3 = ratio
                            temp_j_fin = temp_j

                list_3.append(temp_j_fin)

        df_main["name_matched_1"] = list_1
        df_main["name_matched_2"] = list_2
        df_main["name_matched_3"] = list_3

        df_main_j1 = df_main[df_main["name_matched_1"].notnull()]
        df_main_j1 = df_main_j1.reset_index(drop = True)

        df_main_j2 = df_main[df_main["name_matched_2"].notnull()]
        df_main_j2 = df_main_j2.reset_index(drop = True)

        df_main_j3 = df_main[df_main["name_matched_3"].notnull()]
        df_main_j3 = df_main_j3.reset_index(drop = True)
        
        df_main_j1 = df_main_j1.sort_values(["name_matched_1"])
        df_main_j1 = df_main_j1.reset_index(drop = True)
        df_main_j2 = df_main_j2.sort_values(["name_matched_2"])
        df_main_j2 = df_main_j2.reset_index(drop = True)
        df_main_j3 = df_main_j3.sort_values(["name_matched_3"])
        df_main_j3 = df_main_j3.reset_index(drop = True)
        
        df_main_j1_merged = pd.merge(df_main_j1, df_nonan,how = "left", left_on = "name_matched_1", right_on = "name_cleaned")

        df_main_j2_merged = pd.merge(df_main_j2, df_nonan,how = "left", left_on = "name_matched_2", right_on = "name_cleaned")

        df_main_j3_merged = pd.merge(df_main_j3, df_nonan,how = "left", left_on = "name_matched_3", right_on = "name_cleaned")
        
        case_cols = ['Sl_No', 'participant_label', 'Kanoon_ID', 'Judge 1', 'Judge 2',
        'Judge 3', 'Petitioners', 'On Behalf', 'Respondents',
        'Petitioner Advocate', 'Respondent Advocate', 'Company',
        'District','State', 'Govt Role', 'Is Appeal', 'Is Constitutional',
        'River-Waterbody', 'Social Impact', 'name_cleaned_1', 'name_cleaned_2',
        'name_cleaned_3', 'name_matched_1', 'name_matched_2', 'name_matched_3']
    
        judge_cols = ['Year',
        'Data_Source',
        'Raw_biodata2017Handbooks',
        'Raw_biodata2014Handbooks',
        'Raw_biowebsite',
        'State_y',
        'Gender',
        'Name_Raw',
        'Title',
        'Name',
        'DateofBirth',
        'JoiningattheState',
        'Education',
        'advocate',
        'practice_court',
        'practice_area',
        'specialization',
        'appoint',
        'add_j_raw',
        'add_j_1_loc',
        'add_j_1_date',
        'add_j_2_loc',
        'add_j_2_date',
        'per_j_raw',
        'per_j_1_loc',
        'per_j_1_date',
        'cj_3_date',
        'cj_4_loc',
        'cj_4_date',
        'sc_judge',
        'member',
        'previous_jobs',
        'Addl_judge',
        'Source',
        'ApptDate_Addl',
        'ApptDate_Perm',
        'Retire',
        'Term_Expiry',
        'Remarks',
              'name_cleaned', 'judge1_matched_bool', 'judge2_matched_bool',
              'judge3_matched_bool']
              
        list_1 = []
        list_2 = []
        list_3 = []
                      
        # separate datasets for each judge
        for index in range(len(judge_cols)):
            col = judge_cols[index]
            if col not in ['judge1_matched_bool', 'judge2_matched_bool','judge3_matched_bool']:
                col = judge_cols[index]
            
                col_j1 = col + "_" + "judge_1"
                list_1.append(col_j1)
                col_j2 = col + "_" + "judge_2"
                list_2.append(col_j2)
                col_j3 = col + "_" + "judge_3"
                list_3.append(col_j3)
            
                df_main_j1_merged[col_j1] = df_main_j1_merged[col]
                df_main_j1_merged = df_main_j1_merged.drop([col], axis = 1)
                df_main_j2_merged[col_j2] = df_main_j2_merged[col]
                df_main_j2_merged = df_main_j2_merged.drop([col], axis = 1)
                df_main_j3_merged[col_j3] = df_main_j3_merged[col]
                df_main_j3_merged = df_main_j3_merged.drop([col], axis = 1)

        df_main_j1_merged = df_main_j1_merged[["Kanoon_ID", "participant_label"] + list_1]
        df_main_j2_merged = df_main_j2_merged[["Kanoon_ID", "participant_label"] + list_2]
        df_main_j3_merged = df_main_j3_merged[["Kanoon_ID", "participant_label"] + list_3]
        
        df_main_j1_merged = df_main_j1_merged.sort_values(["Kanoon_ID", "participant_label"])
        df_main_j1_merged = df_main_j1_merged.reset_index(drop = True)

        df_main_j2_merged = df_main_j2_merged.sort_values(["Kanoon_ID", "participant_label"])
        df_main_j2_merged = df_main_j2_merged.reset_index(drop = True)

        df_main_j3_merged = df_main_j3_merged.sort_values(["Kanoon_ID", "participant_label"])
        df_main_j3_merged = df_main_j3_merged.reset_index(drop = True)

        df_0 = pd.merge(df_main, df_main_j1_merged, left_on = ["Kanoon_ID", "participant_label"],right_on = ["Kanoon_ID", "participant_label"], how = "left")

        df_0 = df_0.sort_values(["Kanoon_ID", "participant_label"])
        df_0 = df_0.reset_index(drop = True)

        df_1 = pd.merge(df_0,df_main_j2_merged, left_on = ["Kanoon_ID", "participant_label"],right_on = ["Kanoon_ID", "participant_label"], how = "left")

        df_1 = df_1.sort_values(["Kanoon_ID", "participant_label"])
        df_1 = df_1.reset_index(drop = True)

        df_2 = pd.merge(df_1,df_main_j3_merged, left_on = ["Kanoon_ID", "participant_label"],right_on = ["Kanoon_ID", "participant_label"], how = "left")

        df_2 = df_2.sort_values(["Kanoon_ID", "participant_label"])
        df_2 = df_2.reset_index(drop = True)
        
        df_cases = df_2
        
        self.df_cases = df_cases
        
        return self.df_cases
        
    def case_data_preprocess_stage2(self):
        
        df_cases = self.case_data_preprocess_stage1()
        
        def cleaner_fn(string_var):
            string_var = str(string_var)
            if (string_var == 'nan'):
                return np.nan
            else:
                punc = '''!-[]{};:'"\<>./?@#$%^&*_~'''  # no , or ()
                for ele in string_var:
                    if ele in punc:
                        string_var = string_var.replace(ele, "")
                return string_var

        # standardising education
        df_cases["education_standardised_judge_1"] = df_cases["Education_judge_1"].apply(lambda x : str(cleaner_fn(x)).lower().strip())
        df_cases["education_standardised_judge_2"] = df_cases["Education_judge_2"].apply(lambda x : str(cleaner_fn(x)).lower().strip())
        df_cases["education_standardised_judge_3"] = df_cases["Education_judge_3"].apply(lambda x : str(cleaner_fn(x)).lower().strip())
        
        
        # llb, llm, bsc, msc, ba, ma, bcom, mcom - degrees

        df_cases["ed_ba_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if "ba" in str(x) else 0)
        df_cases["ed_ba_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if "ba" in str(x) else 0)
        df_cases["ed_ba_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if "ba" in str(x) else 0)

        df_cases["ed_ma_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if "ma" in str(x) else 0)
        df_cases["ed_ma_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if "ma" in str(x) else 0)
        df_cases["ed_ma_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if "ma" in str(x) else 0)

        df_cases["ed_bsc_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if "bsc" in str(x) else 0)
        df_cases["ed_bsc_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if "bsc" in str(x) else 0)
        df_cases["ed_bsc_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if "bsc" in str(x) else 0)

        df_cases["ed_msc_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if "msc" in str(x) else 0)
        df_cases["ed_msc_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if "msc" in str(x) else 0)
        df_cases["ed_msc_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if "msc" in str(x) else 0)

        df_cases["ed_bcom_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if "bcom" in str(x) else 0)
        df_cases["ed_bcom_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if "bcom" in str(x) else 0)
        df_cases["ed_bcom_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if "bcom" in str(x) else 0)

        df_cases["ed_mcom_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if "mcom" in str(x) else 0)
        df_cases["ed_mcom_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if "mcom" in str(x) else 0)
        df_cases["ed_mcom_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if "mcom" in str(x) else 0)

        df_cases["ed_llb_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if ("llb" in str(x) or "bl" in str(x)) else 0)
        df_cases["ed_llb_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if ("llb" in str(x) or "bl" in str(x)) else 0)
        df_cases["ed_llb_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if ("llb" in str(x) or "bl" in str(x)) else 0)

        df_cases["ed_llm_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if "llm" in str(x) else 0)
        df_cases["ed_llm_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if "llm" in str(x) else 0)
        df_cases["ed_llm_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if "llm" in str(x) else 0)
        
        df_cases["ed_ics_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if "ics" in str(x) else 0)
        df_cases["ed_ics_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if "ics" in str(x) else 0)
        df_cases["ed_ics_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if "ics" in str(x) else 0)
    
        df_cases["ed_aca_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if "aca" in str(x) else 0)
        df_cases["ed_aca_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if "aca" in str(x) else 0)
        df_cases["ed_aca_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if "aca" in str(x) else 0)
                    

        df_cases["ed_doc_judge_1"] = df_cases["education_standardised_judge_1"].apply(lambda x : 1 if ("phd" in str(x) or "lld" in str(x) or "dll" in str(x)) else 0)
        df_cases["ed_doc_judge_2"] = df_cases["education_standardised_judge_2"].apply(lambda x : 1 if ("phd" in str(x) or "lld" in str(x) or "dll" in str(x)) else 0)
        df_cases["ed_doc_judge_3"] = df_cases["education_standardised_judge_3"].apply(lambda x : 1 if ("phd" in str(x) or "lld" in str(x) or "dll" in str(x)) else 0)


        df_cases["gender_binary_judge_1"] = df_cases["Gender_judge_1"].apply(lambda x : 1 if x == 'Male' else (0 if x == 'Female' else None))
        df_cases["gender_binary_judge_2"] = df_cases["Gender_judge_2"].apply(lambda x : 1 if x == 'Male' else (0 if x == 'Female' else None))
        df_cases["gender_binary_judge_3"] = df_cases["Gender_judge_3"].apply(lambda x : 1 if x == 'Male' else (0 if x == 'Female' else None))
        
        def birth_year_assigner(stringvar):
        
            if("." in stringvar):
                try:
                    birth_year = int(str(stringvar.split(".")[-1]).strip())
                    return birth_year
                except:
                    return np.nan
                    
                
            elif("/" in stringvar):
                try:
                    birth_year = int(str(stringvar.split("/")[-1]).strip())
                    return birth_year
                except:
                    return np.nan
                
            elif("-" in stringvar):
                try:
                    birth_year_1 = int(str(stringvar.split("-")[0]).strip())
                    birth_year_2 = int(str(stringvar.split("-")[1]).strip())
                    birth_year = (birth_year_1 + birth_year_2)/2
                    return birth_year
                except:
                    return np.nan
                    
            else:
                return np.nan
                                
        
        df_cases["birth_year_judge_1"] = df_cases["DateofBirth_judge_1"].apply(lambda x : x.split('.')[-1] if type(x) == str else None)
        df_cases["birth_year_judge_2"] = df_cases["DateofBirth_judge_2"].apply(lambda x : x.split('.')[-1] if type(x) == str else None)
        df_cases["birth_year_judge_3"] = df_cases["DateofBirth_judge_3"].apply(lambda x : x.split('.')[-1] if type(x) == str else None)
        
        
        # cleaning districts

        def district_extractor(string_var):
            if("-" in string_var):
                split_list = string_var.split("-")
                if(len(split_list) > 0):
                    district = split_list[0].lower()
                    return str(cleaner_fn(district)).lower().strip()
                else:
                    return str(cleaner_fn(string_var)).lower().strip()
            else:
                split_list = string_var.split(",")
                if(len(split_list) > 0):
                    district = split_list[0].lower()
                    return str(cleaner_fn(district)).lower().strip()
                else:
                    return str(cleaner_fn(string_var)).lower().strip()

        df_cases["district"] = df_cases["District"].apply(lambda x : str(cleaner_fn(str(x))).lower().strip())
        df_cases["state"] = df_cases["State"].apply(lambda x : str(cleaner_fn(str(x))).lower().strip())
        df_cases["Social Impact"] = df_cases["Social Impact"].apply(lambda x : str(x).lower())
        df_cases["Govt Role"] = df_cases["Govt Role"].apply(lambda x : str(x).lower())
        df_cases["Is Appeal"] = df_cases["Is Appeal"].apply(lambda x : str(x).lower())
        df_cases["Is Constitutional"] = df_cases["Is Constitutional"].apply(lambda x : str(x).lower())
        #df_cases["Social Impact"] = df_cases["Social Impact"].apply(lambda x : str(x).lower())

        def impact_val(string_var):
            if (string_var == "no"):
                num = 0
            elif (string_var == "yes"):
                num = 1
                
            return num

        df_cases["impact_coded"] = df_cases["Social Impact"].apply(lambda x : impact_val(x))

        df_cases["govt_respondent"] = df_cases["Govt Role"].apply(lambda x : 1 if (str(x) == 'respondent' or str(x) == 'both') else 0)

        df_cases["govt_petitioner"] = df_cases["Govt Role"].apply(lambda x : 1 if (str(x) == 'petitioner' or str(x) == 'both') else 0)

        df_cases["is_appeal"] = df_cases["Is Appeal"].apply(lambda x : 1 if str(x) == 'yes' else 0)

        df_cases["is_constitutional"] = df_cases["Is Constitutional"].apply(lambda x : 1 if str(x) == 'yes' else 0)
        
        
        # de duplication now
        # will take the mean in case multiple codings are there as the first measure
        # as the second measure, will take up the most frequently assigned value, mark the case in event of a draw

        list_ids = list(df_cases["Kanoon_ID"].unique())
        dict_vals = {}
        for kanoon_id in list_ids:
            df_temp = df_cases[df_cases["Kanoon_ID"] == kanoon_id]
            
            new_code = df_temp["impact_coded"].sum()/len(df_temp)
            dict_vals[kanoon_id] = new_code

        list_new_coded_vals = []
        for index in range(len(df_cases)):
            kanoon_id = int(df_cases["Kanoon_ID"][index])
            new_coded_vals = dict_vals[kanoon_id]
            
            list_new_coded_vals.append(new_coded_vals)

        df_cases["mean_coded_vals"] = list_new_coded_vals # mean measure
        

        # most frequently coded values -
        dict_vals = {}
        for kanoon_id in list_ids:
            df_temp = df_cases[df_cases["Kanoon_ID"] == kanoon_id]
            list_codes = list(df_temp["impact_coded"])
            
            freq_tup = FreqDist(list_codes).most_common()
            
            if(len(freq_tup)>1):
                if(freq_tup[0][1] == freq_tup[1][1]): # case of a draw
                    dict_vals[kanoon_id] = (freq_tup[0][0] + freq_tup[1][0])/2
                
                if(freq_tup[0][1] > freq_tup[1][1]): # case of a draw
                    dict_vals[kanoon_id] = freq_tup[0][0]
            else:
                dict_vals[kanoon_id] = freq_tup[0][0]

        list_new_coded_vals = []
        for index in range(len(df_cases)):
            kanoon_id = int(df_cases["Kanoon_ID"][index])
            new_coded_vals = dict_vals[kanoon_id]
            
            list_new_coded_vals.append(new_coded_vals)

        df_cases["most_freq_coded_vals"] = list_new_coded_vals
        
        
        #extracting delivery year from text
        #root_dir = "/Users/shashanksingh/Desktop/IND_PROJ/water_pollution/Kanoon_html_new"
        root_dir = self.path_to_text_files
        title_list = []
        year_list = []

        for index in tqdm.trange(len(df_cases)):
            kanoon_id = int(df_cases["Kanoon_ID"][index])
            
            path = root_dir + "/" + str(kanoon_id) + ".html"      
            
            try:
                f = open(path, "r").read()
                soup = BeautifulSoup(f, 'lxml')
                title_div = soup.findAll("div", {"class": "doc_title"})
            
                if len(title_div)>0:
                    title_div_str = title_div[-1].text
                    year_l = re.findall('\d\d\d\d', title_div_str)
                    if(len(year_l)>0):
                        year = float(year_l[-1])
                    else:
                        year = None
                
                else:
                    title_div_str = None
                    year = None
                
                title_list.append(title_div_str)
                year_list.append(year)
                
            except:
                
                title_list.append(None)
                year_list.append(None)
                
        df_cases["case_title"] = title_list
        df_cases["delivery_year"] = year_list


        # making the judge age column now, since we have delivery year
        
        def judge_age_calculator(dataframe):

            if(birth_year != None and yod != None):
                age = yod - birth_year
            else:
                age = None
            return age
            

        age_list_judge_1 = []
        age_list_judge_2 = []
        age_list_judge_3 = []
     
        for index in tqdm.trange(len(df_cases)):
            birth_year1 = df_cases["birth_year_judge_1"][index]
            birth_year2 = df_cases["birth_year_judge_2"][index]
            birth_year3 = df_cases["birth_year_judge_3"][index]
            yod = df_cases["delivery_year"][index]
            
            if(birth_year1 != None and yod != None):
                try:
                    age1 = float(yod) - float(birth_year1)
                except:
                    age1 = None
            else:
                age1 = None
               
            age_list_judge_1.append(age1)
            
            if(birth_year2 != None and yod != None):
                try:
                    age2 = float(yod) - float(birth_year2)
                except:
                    age2 = None
            else:
                age2 = None
               
            age_list_judge_2.append(age2)
            
            if(birth_year3 != None and yod != None):
                try:
                    age3 = float(yod) - float(birth_year3)
                except:
                    age3 = None
            else:
                age3 = None
               
            age_list_judge_3.append(age3)
            
            
        df_cases["judge_age_judge_1"] = age_list_judge_1
        df_cases["judge_age_judge_2"] = age_list_judge_2
        df_cases["judge_age_judge_3"] = age_list_judge_3

        # making num_judges column
        num_j_list = []
        for index in range(len(df_cases)):
            judge_1 = str(df_cases["Judge 1"][index]).lower()
            if judge_1 == "nan":
                num_1 = 0
            else:
                num_1 = 1
                
            judge_2 = str(df_cases["Judge 2"][index]).lower()
            if judge_2 == "nan":
                num_2 = 0
            else:
                num_2 = 1
                
            judge_3 = str(df_cases["Judge 3"][index]).lower()
            if judge_3 == "nan":
                num_3 = 0
            else:
                num_3 = 1
            
            tot_num = num_1 + num_2 + num_3
            num_j_list.append(tot_num)
            
            
            
        df_cases["num_judges"] = num_j_list
        #df_cases = df_cases[df_cases["district"].notnull()]
        #df_cases = df_cases[df_cases["district"] != "nan"]
        #df_cases = df_cases[df_cases["district"] != "na"]
        #df_cases = df_cases[df_cases["district"] != "none"]
        #df_cases = df_cases[df_cases["district"] != ""]
        
        df_cases = df_cases.reset_index(drop = True)
        
        self.df_cases = df_cases
        
        return self.df_cases
        
    def case_data_preprocess_stage3(self):
    
        df_cases = self.case_data_preprocess_stage2()

        list_ba = []
        list_ma = []
        list_bsc = []
        list_msc = []
        list_bcom = []
        list_mcom = []
        list_llb = []
        list_llm = []
        list_ics = []
        list_aca = []
        list_doc = []

        list_gender = []

        for index in tqdm.trange(len(df_cases)):
            
            judge_1_ed = str(df_cases["education_standardised_judge_1"][index]).lower()
            judge_2_ed = str(df_cases["education_standardised_judge_2"][index]).lower()
            judge_3_ed = str(df_cases["education_standardised_judge_3"][index]).lower()
            
            num_judges = df_cases["num_judges"][index]
            
            ed_ba_judge_1 = df_cases["ed_ba_judge_1"][index]
            ed_ba_judge_2 = df_cases["ed_ba_judge_2"][index]
            ed_ba_judge_3 = df_cases["ed_ba_judge_3"][index]
            
            ed_ma_judge_1 = df_cases["ed_ma_judge_1"][index]
            ed_ma_judge_2 = df_cases["ed_ma_judge_2"][index]
            ed_ma_judge_3 = df_cases["ed_ma_judge_3"][index]
            
            ed_bsc_judge_1 = df_cases["ed_bsc_judge_1"][index]
            ed_bsc_judge_2 = df_cases["ed_bsc_judge_2"][index]
            ed_bsc_judge_3 = df_cases["ed_bsc_judge_3"][index]
            
            ed_msc_judge_1 = df_cases["ed_msc_judge_1"][index]
            ed_msc_judge_2 = df_cases["ed_msc_judge_2"][index]
            ed_msc_judge_3 = df_cases["ed_msc_judge_3"][index]
            
            ed_bcom_judge_1 = df_cases["ed_bcom_judge_1"][index]
            ed_bcom_judge_2 = df_cases["ed_bcom_judge_2"][index]
            ed_bcom_judge_3 = df_cases["ed_bcom_judge_3"][index]
            
            ed_mcom_judge_1 = df_cases["ed_mcom_judge_1"][index]
            ed_mcom_judge_2 = df_cases["ed_mcom_judge_2"][index]
            ed_mcom_judge_3 = df_cases["ed_mcom_judge_3"][index]
            
            ed_llb_judge_1 = df_cases["ed_llb_judge_1"][index]
            ed_llb_judge_2 = df_cases["ed_llb_judge_2"][index]
            ed_llb_judge_3 = df_cases["ed_llb_judge_3"][index]
            
            ed_llm_judge_1 = df_cases["ed_llm_judge_1"][index]
            ed_llm_judge_2 = df_cases["ed_llm_judge_2"][index]
            ed_llm_judge_3 = df_cases["ed_llm_judge_3"][index]
            
            ed_ics_judge_1 = df_cases["ed_ics_judge_1"][index]
            ed_ics_judge_2 = df_cases["ed_ics_judge_2"][index]
            ed_ics_judge_3 = df_cases["ed_ics_judge_3"][index]
            
            ed_aca_judge_1 = df_cases["ed_aca_judge_1"][index]
            ed_aca_judge_2 = df_cases["ed_aca_judge_2"][index]
            ed_aca_judge_3 = df_cases["ed_aca_judge_3"][index]
            
            ed_doc_judge_1 = df_cases["ed_doc_judge_1"][index]
            ed_doc_judge_2 = df_cases["ed_doc_judge_2"][index]
            ed_doc_judge_3 = df_cases["ed_doc_judge_3"][index]
            
            gender_binary_judge_1 = df_cases["gender_binary_judge_1"][index]
            gender_binary_judge_2 = df_cases["gender_binary_judge_2"][index]
            gender_binary_judge_3 = df_cases["gender_binary_judge_3"][index]
            
            gender_bool_1 = 1
            gender_bool_2 = 1
            gender_bool_3 = 1
            
            if str(gender_binary_judge_1) == "nan":
                gender_bool_1 = 0
            if str(gender_binary_judge_2) == "nan":
                gender_bool_2 = 0
            if str(gender_binary_judge_3) == "nan":
                gender_bool_3 = 0
                
            l_bool = [gender_bool_1, gender_bool_2, gender_bool_3]
            
            if(l_bool == [1,1,1]):
                gender_binary = (float(gender_binary_judge_1) + float(gender_binary_judge_2) + float(gender_binary_judge_3))/3
            if(l_bool == [1,0,0]):
                gender_binary = float(gender_binary_judge_1)
            if(l_bool == [0,1,0]):
                gender_binary = float(gender_binary_judge_2)
            if(l_bool == [0,0,1]):
                gender_binary = float(gender_binary_judge_3)
            if(l_bool == [0,1,1]):
                gender_binary = (float(gender_binary_judge_2) + float(gender_binary_judge_3))/2
            if(l_bool == [1,0,1]):
                gender_binary = (float(gender_binary_judge_1) + float(gender_binary_judge_3))/2
            if(l_bool == [1,1,0]):
                gender_binary = (float(gender_binary_judge_1) + float(gender_binary_judge_2))/2
            if(l_bool == [0,0,0]):
                gender_binary = np.nan

            
            bool_1 = 1
            bool_2 = 1
            bool_3 = 1
            
            if(judge_1_ed == "nan" or judge_1_ed == ""):
                bool_1 = 0
            if(judge_2_ed == "nan" or judge_2_ed == ""):
                bool_2 = 0
            if(judge_3_ed == "nan" or judge_3_ed == ""):
                bool_3 = 0
                
            tot_judges = bool_1 + bool_2 + bool_3
            
            if(tot_judges != 0):
                ed_ba_mean = (ed_ba_judge_1 + ed_ba_judge_2 + ed_ba_judge_3)/tot_judges
                ed_ma_mean = (ed_ma_judge_1 + ed_ma_judge_2 + ed_ma_judge_3)/tot_judges
                ed_bsc_mean = (ed_bsc_judge_1 + ed_bsc_judge_2 + ed_bsc_judge_3)/tot_judges
                ed_msc_mean = (ed_msc_judge_1 + ed_msc_judge_2 + ed_msc_judge_3)/tot_judges
                ed_bcom_mean = (ed_bcom_judge_1 + ed_bcom_judge_2 + ed_bcom_judge_3)/tot_judges
                ed_mcom_mean = (ed_mcom_judge_1 + ed_mcom_judge_2 + ed_mcom_judge_3)/tot_judges
                ed_llb_mean = (ed_llb_judge_1 + ed_llb_judge_2 + ed_llb_judge_3)/tot_judges
                ed_llm_mean = (ed_llm_judge_1 + ed_llm_judge_2 + ed_llm_judge_3)/tot_judges
                ed_ics_mean = (ed_ics_judge_1 + ed_ics_judge_2 + ed_ics_judge_3)/tot_judges
                ed_aca_mean = (ed_aca_judge_1 + ed_aca_judge_2 + ed_aca_judge_3)/tot_judges
                ed_doc_mean = (ed_doc_judge_1 + ed_doc_judge_2 + ed_doc_judge_3)/tot_judges
            else:
                ed_ba_mean = 0
                ed_ma_mean = 0
                ed_bsc_mean = 0
                ed_msc_mean = 0
                ed_bcom_mean = 0
                ed_mcom_mean = 0
                ed_llb_mean = 0
                ed_llm_mean = 0
                ed_ics_mean = 0
                ed_aca_mean = 0
                ed_doc_mean = 0
                
            
            
            list_ba.append(ed_ba_mean)
            list_ma.append(ed_ma_mean)
            list_bsc.append(ed_bsc_mean)
            list_msc.append(ed_msc_mean)
            list_bcom.append(ed_bcom_mean)
            list_mcom.append(ed_mcom_mean)
            list_llb.append(ed_llb_mean)
            list_llm.append(ed_llm_mean)
            list_ics.append(ed_ics_mean)
            list_aca.append(ed_aca_mean)
            list_doc.append(ed_doc_mean)

            list_gender.append(gender_binary)
                
           

        df_cases["ed_ba"] = list_ba
        df_cases["ed_ma"] = list_ma
        df_cases["ed_bsc"] = list_bsc
        df_cases["ed_msc"] = list_msc
        df_cases["ed_bcom"] = list_bcom
        df_cases["ed_mcom"] = list_mcom
        df_cases["ed_llb"] = list_llb
        df_cases["ed_llm"] = list_llm
        df_cases["ed_ics"] = list_ics
        df_cases["ed_aca"] = list_aca
        df_cases["ed_doc"] = list_doc

        df_cases["gender_binary"] = list_gender


        df_cases = df_cases.drop_duplicates(["Kanoon_ID"], keep = "first")

        df_cases = df_cases.reset_index(drop=True)
        
        root_dir = self.path_to_text_files
        #title_list = []
        dict_month = {}
        list_kanoon_ids_int = list(df_cases["Kanoon_ID"].astype(int))
        list_kanoon_ids = [str(ele) for ele in list_kanoon_ids_int]
        list_months = ["january", "february", "march", "april", "may", "june", "july","august",
                      "september", "october", "november", "december"]

        for index in tqdm.trange(len(list_kanoon_ids)):
            kanoon_id = str(list_kanoon_ids[index])
            
            path = root_dir + "/" + str(kanoon_id) + ".html"
            
            try:
                f = open(path, "r").read()
                soup = BeautifulSoup(f, 'lxml')
                title_div = soup.findAll("div", {"class": "doc_title"})
            
                month_temp_list = []
            
                if len(title_div)>0:
                    title_div_str = str(title_div[-1].text).lower()
                    for month in list_months:
                        if(month in title_div_str):
                            month_temp_list.append(month)
                    if(len(month_temp_list)>0):
                        month_final = month_temp_list[-1]
                    else:
                        month_final = None
                
                else:
                    month_final = None
                
                dict_month[kanoon_id] = month_final
                
            except:
                dict_month[kanoon_id] = None
                
        dict_num_month = {
                        "january" : 1.0,
                        "february" : 2.0,
                        "march" : 3.0,
                        "april" : 4.0,
                        "may" : 5.0,
                        "june" : 6.0,
                        "july" : 7.0,
                        "august" : 8.0,
                        "september" : 9.0,
                        "october" : 10.0,
                        "november" : 11.0,
                        "december" : 12.0}
                
        keys = list(dict_month.keys())

        def delivery_month(var):
            var = str(var).lower()
            if(var == "nan" or var == "none"):
                return None
            else:
                var = str(int(float(var)))
                if var in keys:
                    if(dict_month[var] != None):
                        return dict_num_month[dict_month[var]]
                    else:
                        return None
                else:
                    return None
                
        df_cases['delivery_month'] = df_cases["Kanoon_ID"].apply(lambda x : delivery_month(x))
        
        self.df_cases = df_cases
        
        return self.df_cases
        
    def case_data_preprocess_stage4(self):
    
        df_cases = self.case_data_preprocess_stage3()
        df_cases = df_cases.reset_index(drop=True)
        
        def cleaner_fn(string_var):
            string_var = str(string_var)
            if (string_var == 'nan'):
                return np.nan
            else:
                punc = '''!-[]{};:'"\<>./?@#$%^&*_~'''  # no , or ()
                for ele in string_var:
                    if ele in punc:
                        string_var = string_var.replace(ele, "")
                return string_var
        
        # standardising education
        df_cases["pa_standardised_judge_1"] = df_cases["practice_area_judge_1"].apply(lambda x : str(cleaner_fn(x)).lower().strip())
        df_cases["pa_standardised_judge_2"] = df_cases["practice_area_judge_2"].apply(lambda x : str(cleaner_fn(x)).lower().strip())
        df_cases["pa_standardised_judge_3"] = df_cases["practice_area_judge_3"].apply(lambda x : str(cleaner_fn(x)).lower().strip())
    
    
        #civil,service,constitution,criminal,labour,company,tax,administrative,commercial,arbitration,family - practice areas

        df_cases["pa_civil_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if "civil" in str(x) else 0)
        df_cases["pa_civil_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if "civil" in str(x) else 0)
        df_cases["pa_civil_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if "civil" in str(x) else 0)

        df_cases["pa_service_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if "service" in str(x) else 0)
        df_cases["pa_service_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if "service" in str(x) else 0)
        df_cases["pa_service_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if "service" in str(x) else 0)

        df_cases["pa_constitution_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if "constitution" in str(x) else 0)
        df_cases["pa_constitution_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if "constitution" in str(x) else 0)
        df_cases["pa_constitution_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if "constitution" in str(x) else 0)

        df_cases["pa_criminal_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if "criminal" in str(x) else 0)
        df_cases["pa_criminal_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if "criminal" in str(x) else 0)
        df_cases["pa_criminal_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if "criminal" in str(x) else 0)

        df_cases["pa_labour_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if "labour" in str(x) else 0)
        df_cases["pa_labour_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if "labour" in str(x) else 0)
        df_cases["pa_labour_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if "labour" in str(x) else 0)

        df_cases["pa_company_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if "company" in str(x) else 0)
        df_cases["pa_company_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if "company" in str(x) else 0)
        df_cases["pa_company_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if "company" in str(x) else 0)

        df_cases["pa_tax_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if ("tax" in str(x)) else 0)
        df_cases["pa_tax_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if ("tax" in str(x)) else 0)
        df_cases["pa_tax_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if ("tax" in str(x)) else 0)

        df_cases["pa_administrative_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if "administrative" in str(x) else 0)
        df_cases["pa_administrative_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if "administrative" in str(x) else 0)
        df_cases["pa_administrative_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if "administrative" in str(x) else 0)
    
        df_cases["pa_commercial_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if "commercial" in str(x) else 0)
        df_cases["pa_commercial_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if "commercial" in str(x) else 0)
        df_cases["pa_commercial_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if "commercial" in str(x) else 0)

        df_cases["pa_arbitration_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if "arbitration" in str(x) else 0)
        df_cases["pa_arbitration_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if "arbitration" in str(x) else 0)
        df_cases["pa_arbitration_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if "arbitration" in str(x) else 0)
                    

        df_cases["pa_family_judge_1"] = df_cases["pa_standardised_judge_1"].apply(lambda x : 1 if ("family" in str(x)) else 0)
        df_cases["pa_family_judge_2"] = df_cases["pa_standardised_judge_2"].apply(lambda x : 1 if ("family" in str(x)) else 0)
        df_cases["pa_family_judge_3"] = df_cases["pa_standardised_judge_3"].apply(lambda x : 1 if ("family" in str(x)) else 0)
        
        #civil,service,constitution,criminal,labour,company,tax,administrative,commercial,arbitration,family - practice areas
        list_civil = []
        list_service = []
        list_constitution = []
        list_criminal = []
        list_labour = []
        list_company = []
        list_tax = []
        list_administrative = []
        list_commercial = []
        list_arbitration = []
        list_family = []


        for index in tqdm.trange(len(df_cases)):
            
            judge_1_pa = str(df_cases["education_standardised_judge_1"][index]).lower()
            judge_2_pa = str(df_cases["education_standardised_judge_2"][index]).lower()
            judge_3_pa = str(df_cases["education_standardised_judge_3"][index]).lower()
            
            num_judges = df_cases["num_judges"][index]
            
            pa_civil_judge_1 = df_cases["pa_civil_judge_1"][index]
            pa_civil_judge_2 = df_cases["pa_civil_judge_2"][index]
            pa_civil_judge_3 = df_cases["pa_civil_judge_3"][index]
            
            pa_service_judge_1 = df_cases["pa_service_judge_1"][index]
            pa_service_judge_2 = df_cases["pa_service_judge_2"][index]
            pa_service_judge_3 = df_cases["pa_service_judge_3"][index]
            
            pa_constitution_judge_1 = df_cases["pa_constitution_judge_1"][index]
            pa_constitution_judge_2 = df_cases["pa_constitution_judge_2"][index]
            pa_constitution_judge_3 = df_cases["pa_constitution_judge_3"][index]
            
            pa_criminal_judge_1 = df_cases["pa_criminal_judge_1"][index]
            pa_criminal_judge_2 = df_cases["pa_criminal_judge_2"][index]
            pa_criminal_judge_3 = df_cases["pa_criminal_judge_3"][index]
            
            pa_labour_judge_1 = df_cases["pa_labour_judge_1"][index]
            pa_labour_judge_2 = df_cases["pa_labour_judge_2"][index]
            pa_labour_judge_3 = df_cases["pa_labour_judge_3"][index]
            
            pa_company_judge_1 = df_cases["pa_company_judge_1"][index]
            pa_company_judge_2 = df_cases["pa_company_judge_2"][index]
            pa_company_judge_3 = df_cases["pa_company_judge_3"][index]
            
            pa_tax_judge_1 = df_cases["pa_tax_judge_1"][index]
            pa_tax_judge_2 = df_cases["pa_tax_judge_2"][index]
            pa_tax_judge_3 = df_cases["pa_tax_judge_3"][index]
            
            pa_administrative_judge_1 = df_cases["pa_administrative_judge_1"][index]
            pa_administrative_judge_2 = df_cases["pa_administrative_judge_2"][index]
            pa_administrative_judge_3 = df_cases["pa_administrative_judge_3"][index]
            
            pa_commercial_judge_1 = df_cases["pa_commercial_judge_1"][index]
            pa_commercial_judge_2 = df_cases["pa_commercial_judge_2"][index]
            pa_commercial_judge_3 = df_cases["pa_commercial_judge_3"][index]
            
            pa_arbitration_judge_1 = df_cases["pa_arbitration_judge_1"][index]
            pa_arbitration_judge_2 = df_cases["pa_arbitration_judge_2"][index]
            pa_arbitration_judge_3 = df_cases["pa_arbitration_judge_3"][index]
            
            pa_family_judge_1 = df_cases["pa_family_judge_1"][index]
            pa_family_judge_2 = df_cases["pa_family_judge_2"][index]
            pa_family_judge_3 = df_cases["pa_family_judge_3"][index]
            
            
            bool_1 = 1
            bool_2 = 1
            bool_3 = 1
            
            if(judge_1_pa == "nan" or judge_1_pa == ""):
                bool_1 = 0
            if(judge_2_pa == "nan" or judge_2_pa == ""):
                bool_2 = 0
            if(judge_3_pa == "nan" or judge_3_pa == ""):
                bool_3 = 0
                
            tot_judges = bool_1 + bool_2 + bool_3
            
            #civil,service,constitution,criminal,labour,company,tax,administrative,commercial,arbitration,family - practice areas
            
            if(tot_judges != 0):
                pa_civil_mean = (pa_civil_judge_1 + pa_civil_judge_2 + pa_civil_judge_3)/tot_judges
                pa_service_mean = (pa_service_judge_1 + pa_service_judge_2 + pa_service_judge_3)/tot_judges
                pa_constitution_mean = (pa_constitution_judge_1 + pa_constitution_judge_2 + pa_constitution_judge_3)/tot_judges
                pa_criminal_mean = (pa_criminal_judge_1 + pa_criminal_judge_2 + pa_criminal_judge_3)/tot_judges
                pa_labour_mean = (pa_labour_judge_1 + pa_labour_judge_2 + pa_labour_judge_3)/tot_judges
                pa_company_mean = (pa_company_judge_1 + pa_company_judge_2 + pa_company_judge_3)/tot_judges
                pa_tax_mean = (pa_tax_judge_1 + pa_tax_judge_2 + pa_tax_judge_3)/tot_judges
                pa_administrative_mean = (pa_administrative_judge_1 + pa_administrative_judge_2 + pa_administrative_judge_3)/tot_judges
                pa_commercial_mean = (pa_commercial_judge_1 + pa_commercial_judge_2 + pa_commercial_judge_3)/tot_judges
                pa_arbitration_mean = (pa_arbitration_judge_1 + pa_arbitration_judge_2 + pa_arbitration_judge_3)/tot_judges
                pa_family_mean = (pa_family_judge_1 + pa_family_judge_2 + pa_family_judge_3)/tot_judges
            else:
                pa_civil_mean = 0
                pa_service_mean = 0
                pa_constitution_mean = 0
                pa_criminal_mean = 0
                pa_labour_mean = 0
                pa_company_mean = 0
                pa_tax_mean = 0
                pa_administrative_mean = 0
                pa_commercial_mean = 0
                pa_arbitration_mean = 0
                pa_family_mean = 0
                
            

            list_civil.append(pa_civil_mean)
            list_service.append(pa_service_mean)
            list_constitution.append(pa_constitution_mean)
            list_criminal.append(pa_criminal_mean)
            list_labour.append(pa_labour_mean)
            list_company.append(pa_company_mean)
            list_tax.append(pa_tax_mean)
            list_administrative.append(pa_administrative_mean)
            list_commercial.append(pa_commercial_mean)
            list_arbitration.append(pa_arbitration_mean)
            list_family.append(pa_family_mean)
            
            
        df_cases["pa_civil"] = list_civil
        df_cases["pa_service"] = list_service
        df_cases["pa_constitution"] = list_constitution
        df_cases["pa_criminal"] = list_criminal
        df_cases["pa_labour"] = list_labour
        df_cases["pa_company"] = list_company
        df_cases["pa_tax"] = list_tax
        df_cases["pa_administrative"] = list_administrative
        df_cases["pa_commercial"] = list_commercial
        df_cases["pa_arbitration"] = list_arbitration
        df_cases["pa_family"] = list_family
        
        df_cases.to_csv(self.root_res_data + "/case_data_final.csv", index=False)
        
        self.df_cases = df_cases
        
        
        return self.df_cases
    
    
    def merge_function(self):
    
    
        def pol_district(string_var,list_districts_pollution):
            cache = 0
            flag = 0

            for map_district in list_districts_pollution:
                score = fuzz.token_set_ratio(string_var, map_district)

                if (score > 80 and score > cache):
                    flag = 1
                    cache = score
                    final_district = map_district
                    final_district = final_district.strip()

            string_var = string_var.strip()

            if flag == 1:
                return final_district
            else:
                return string_var # returning the same district in case of no match
            
            
        casedata_path = self.root_res_data + "/case_data_finaljsnjsn.csv"
        
        if not os.path.exists(casedata_path):
            df_cases = self.case_data_preprocess_stage4()
        else:
            logging.info("Case data found!")
            df_cases = pd.read_csv(self.root_res_data + "/case_data_final.csv")
        
        #df_air_pollution = pd.read_csv(self.root_raw_data+"/air_pollution_001_district_panel.csv")
        
        #df_air_pollution["district"] = df_air_pollution["adm2_name"]
        #df_air_pollution["state"] = df_air_pollution["adm1_name"]
        #df_air_pollution = df_air_pollution[["district", "state", "mean_pm25", "month", "year"]]
        
        df_bc = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/BC"+"/bc_MERRA_long_WB_districts.dta")
        
        df_du = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/DU"+"/du_MERRA_long_WB_districts.dta")
        
        df_oc14 = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/OC"+"/oc14_MERRA_long_WB_districts.dta")
        df_oc16 = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/OC"+"/oc16_MERRA_long_WB_districts.dta")
        df_oc18 = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/OC"+"/oc18_MERRA_long_WB_districts.dta")
        
        df_pm14 = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/PM"+"/pm14_MERRA_long_WB_districts.dta")
        df_pm16 = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/PM"+"/pm16_MERRA_long_WB_districts.dta")
        df_pm18 = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/PM"+"/pm18_MERRA_long_WB_districts.dta")
        
        df_so2 = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/SO2"+"/so2_MERRA_long_WB_districts.dta")
        
        df_so4 = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/SO4"+"/so4_MERRA_long_WB_districts.dta")
        
        df_ss = pd.read_stata(self.root_raw_data+"/MERRA_Air_Pollution_06282022"+"/SS"+"/ss_MERRA_long_WB_districts.dta")
        
        df_air_pollution = pd.concat([df_bc,
                              df_du,
                              df_oc14,
                              df_oc16,
                              df_oc18,
                              df_pm14,
                              df_pm16,
                              df_pm18,
                              df_so2,
                              df_so4,
                              df_ss], axis=1)
                              
        df_air_pollution = df_air_pollution.loc[:,~df_air_pollution.columns.duplicated()].copy()


        df_air_pollution["district"] = df_air_pollution["district"].apply(lambda x : x.lower())
        df_air_pollution["state"] = df_air_pollution["state"].apply(lambda x : x.lower())
        
        df_air_pollution.to_csv(self.root_res_data+r"/air_pollution_olexiy_combined.csv", index = False)
        
        df_air_pollution_gpby_district_year = df_air_pollution.groupby(["state","district", "year"]).agg("mean")
        df_air_pollution_gpby_district_year = df_air_pollution_gpby_district_year.reset_index()



        
        list_districts_pollution = list(df_air_pollution["district"].unique())
        list_states_pollution = list(df_air_pollution["state"].unique())
        
        #df_cases["district"] = df_cases["district"].apply(lambda x : faulty_dist_dict[x] if x in list(faulty_dist_dict.keys()) else x)


        df_vecs = pd.read_csv(self.root_res_data + "/air_pollution_cases_mapped_to_judge_vecs_with_clustered_judge_names_including_manual.csv").drop(["Unnamed: 0"], axis=1)
        
        df_cases = pd.merge(df_cases, df_vecs, 
                            left_on = ["Kanoon_ID"], 
                            right_on = ["kanoon_id"], 
                            how = "left")
        
        df_cases["pollution_district"] = df_cases["district"].apply(lambda x : pol_district(str(x),list_districts_pollution))
        df_cases["pollution_state"] = df_cases["state"].apply(lambda x : pol_district(str(x),list_states_pollution))
        
        df_cases_orig = df_cases
        df_cases = df_cases[df_cases["district"].notnull()]
        df_cases = df_cases[df_cases["district"] != "nan"]
        df_cases = df_cases[df_cases["district"] != "na"]
        df_cases = df_cases[df_cases["district"] != "none"]
        df_cases = df_cases[df_cases["district"] != ""]
        
        df_cases["pollution_district"] = df_cases["district"].apply(lambda x : pol_district(str(x),list_districts_pollution))
            
        df_monthly_merge = pd.merge(df_air_pollution, 
                                    df_cases, 
                                    left_on = ["district", "year", "month"], 
                                    right_on = ["pollution_district", "delivery_year", "delivery_month"], 
                                    how = "left")
        
        df_yearly_merge = pd.merge(df_air_pollution_gpby_district_year, 
                                    df_cases, 
                                    left_on = ["district", "year"], 
                                    right_on = ["pollution_district", "delivery_year"], 
                                    how = "left")
        
        df_monthly_merge = df_monthly_merge.reset_index(drop=True)
        
        df_yearly_merge = df_yearly_merge.reset_index(drop=True)
        

        df_cases0 = df_cases_orig[df_cases_orig["district"].isnull()]
        df_cases1 = df_cases_orig[df_cases_orig["district"] == "nan"]
        df_cases2 = df_cases_orig[df_cases_orig["district"] == "na"]
        df_cases3 = df_cases_orig[df_cases_orig["district"] == "none"]
        df_cases4 = df_cases_orig[df_cases_orig["district"] == ""]
        
        df_cases_null_district = pd.concat([df_cases0,df_cases1,df_cases2,df_cases3,df_cases4], axis=0)
        df_cases_null_district = df_cases_null_district.reset_index(drop=True)
        
        df_cases_null_district = df_cases_null_district[df_cases_null_district["state"].notnull()]
        
        df_monthly_merge2 = pd.merge(df_air_pollution, 
                            df_cases_null_district, 
                            left_on = ["state", "year", "month"], 
                            right_on = ["pollution_state", "delivery_year", "delivery_month"], 
                            how = "left")

        df_yearly_merge2 = pd.merge(df_air_pollution_gpby_district_year, 
                            df_cases_null_district, 
                            left_on = ["state", "year"], 
                            right_on = ["pollution_state", "delivery_year"], 
                            how = "left")
           
        # dummies for presence of a district, because we take state otherwise
        df_monthly_merge["district_present"] = 1
        df_yearly_merge["district_present"] = 1
        
        df_monthly_merge2["district_present"] = 1
        df_yearly_merge2["district_present"] = 1
        
        df_monthly_merge_combined = pd.concat([df_monthly_merge,df_monthly_merge2], axis=0)
        df_yearly_merge_combined = pd.concat([df_yearly_merge,df_yearly_merge2], axis=0)
        
        df_monthly_merge_combined = df_monthly_merge_combined.reset_index(drop=True)
        df_yearly_merge_combined = df_yearly_merge_combined.reset_index(drop=True)
        
        df_monthly_merge_combined["delhi_district_dummy"] = df_monthly_merge_combined["district_x"].apply(lambda x : 1 if "delhi" in str(x).lower() else 0)
        df_monthly_merge_combined["delhi_state_dummy"] = df_monthly_merge_combined["state_x"].apply(lambda x : 1 if "delhi" in str(x).lower() else 0)
        df_monthly_merge_combined["delhi_dummy"] = df_monthly_merge_combined["delhi_district_dummy"]+df_monthly_merge_combined["delhi_state_dummy"]
        df_monthly_merge_combined["delhi_dummy"] = df_monthly_merge_combined["delhi_dummy"].apply(lambda x : 1 if x>0 else 0)
        df_monthly_merge_combined = df_monthly_merge_combined.drop(["delhi_district_dummy","delhi_state_dummy"], axis=1)
        
        df_yearly_merge_combined["delhi_district_dummy"] = df_yearly_merge_combined["district_x"].apply(lambda x : 1 if "delhi" in str(x).lower() else 0)
        df_yearly_merge_combined["delhi_state_dummy"] = df_yearly_merge_combined["state_x"].apply(lambda x : 1 if "delhi" in str(x).lower() else 0)
        df_yearly_merge_combined["delhi_dummy"] = df_yearly_merge_combined["delhi_district_dummy"]+df_yearly_merge_combined["delhi_state_dummy"]
        df_yearly_merge_combined["delhi_dummy"] = df_yearly_merge_combined["delhi_dummy"].apply(lambda x : 1 if x>0 else 0)
        df_yearly_merge_combined = df_yearly_merge_combined.drop(["delhi_district_dummy","delhi_state_dummy"], axis=1)
        
        df_monthly_merge_combined.to_csv(self.root_res_data+"/monthly_air.csv", index = "False")
        
        df_yearly_merge_combined.to_csv(self.root_res_data+"/yearly_air.csv", index = "False")
        
        
if __name__ == '__main__':
    a = "/Users/shashanksingh/Desktop/github/india_air_pollution/data/raw_data"
    b = "/Users/shashanksingh/Desktop/github/india_air_pollution/data/processed_data"
    c = "/Users/shashanksingh/Desktop/IND_PROJ/water_pollution/Kanoon_html_new_with_air"
    s = preprocessor(a,b,c)
    
    s.merge_function()


                
                
            
                

