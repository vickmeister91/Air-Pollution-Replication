require(tidyverse)
# require(httr)
# setwd("C:\\Users\\vickm\\Documents\\The Library\\Air Pollution")
options(StringsasFactor=FALSE)

# response_case<-GET("https://www.dropbox.com/scl/fi/p194j3qj15xb58t4q5g7l/case_data_final_with_additional_variables.csv?rlkey=qa4i5y8yjr5qiupmdq8v2ua1q&dl=1")
# case<-content(response_case,as="text")
# case<-read.csv(text=case)
# drop(response_case)
# 
# response_corp<-GET("https://www.dropbox.com/scl/fi/u326qjxh83gm6nuroztc3/possible_air_corpus_with_meta_and_text.csv?rlkey=4ubqfyt1praw5k8cr5zsyni3d&dl=1")
# air_corp<-content(response_corp,as="text")
# air_corp<-read.csv(text=air_corp)

# Input files from Andy and Shashank
# 'case' refers to human coded data; "air_corp" refers to metadata for the pollution corpus;
# 'Andy' is the chatgpt data output from Andy

case<-read.csv("case_data_final_with_additional_variables.csv")
air_corp<-read.csv("possible_air_corpus_with_meta_and_text.csv")
andy<-read.csv("main_df.csv")%>%filter(!is.na(kanoon_id))
# test<-case%>%filter(trimws(name_matched_1)=="")


case$Kanoon_ID<-as.character(case$Kanoon_ID,na.rm=TRUE)
air_corp$kanoon_id<-as.character(air_corp$kanoon_id,na.rm=TRUE)

air_corp<-air_corp%>%mutate(case_date = as.Date(doc_date,format="%Y-%m-%d"),
                            case_yr = as.numeric(year(case_date),na.rm=TRUE),
                            case_mon = as.numeric(month(case_date),na.rm=TRUE))

# Create a  base template from the metadata and human coded data to append them while dropping duplicates
# This is because the human coders filled in some gaps where metdata was missing

air_base<-air_corp%>%distinct(kanoon_id, case_date, case_yr, case_mon, matched_acts, 
                               kanoon_ids_cited, judge_court, petitioner, respondent,text, doc_date,acts_cited,title)


air_base<-air_base%>%mutate(matched_acts = gsub("\\[(.*)\\]","\\1",matched_acts),
                            matched_acts = gsub("\\'","",matched_acts),
                            kanoon_ids_cited = gsub("\\[(.*)\\]","\\1",kanoon_ids_cited),
                            num_titles_cited = lengths(gregexpr(",",kanoon_ids_cited))+1,
                            num_acts = lengths(gregexpr(",",matched_acts))+1,
                            judge_court = gsub("\\[(.*)\\]","\\1",judge_court),
                            judge_court = gsub("\\(|\\)|\\'","",judge_court),
                            length_of_case = lengths(strsplit(text, "\\W+")))
# %>%select(-text)

# test<-air_base%>%filter(kanoon_id==107410576)%>%select(length_of_case, length_of_case2)
# test<-air_corp%>%filter(kanoon_id==107410576)%>%select(text)

air_base[,17:21]<-str_split_fixed(air_base$matched_acts,",",5)
air_base[,22:27]<-str_split_fixed(air_base$judge_court,",",6)

air_base<-air_base%>%rename(act_1=V17,
                              act_2=V18,
                              act_3=V19,
                              act_4=V20,
                              act_5=V21,
                              judge_1=V22,
                              court_1=V23,
                              judge_2=V24,
                              court_2=V25,
                              judge_3=V26,
                              court_3=V27)
air_base2<-air_base%>%select(kanoon_id,
                              case_date,
                              case_yr,
                              case_mon,
                              petitioner,
                              respondent,
                              judge_1,
                              judge_2,
                              judge_3,
                              court_1,
                              court_2,
                              court_3,
                              num_titles_cited,
                             length_of_case,
                              act_1,act_2,
                              act_3,act_4,act_5,
                             doc_date,kanoon_ids_cited,acts_cited,title,text)%>%
  mutate(in_air_corpus = 1)

case_base<-case%>%mutate(case_date = NA_Date_,
                          act_1=NA_character_,
                          act_2=NA_character_,
                          act_3=NA_character_,
                          act_4=NA_character_,
                          act_5=NA_character_,
                         doc_date=NA_character_,
                         kanoon_ids_cited=NA_character_,
                         acts_cited=NA_character_,
                         title=NA_character_,
                         text=NA_character_,
                         in_air_corpus=0,
                         judge_1 = if_else(!is.na(name_matched_1),name_matched_1,name_cleaned_1),
                         judge_2 = if_else(!is.na(name_matched_2),name_matched_2,name_cleaned_2),
                         judge_3 = if_else(!is.na(name_matched_3),name_matched_3,name_cleaned_3))%>%
  select(Kanoon_ID,
         case_date,
         delivery_year,
         delivery_month,
         Petitioners,
         Respondents,
         judge_1,
         judge_2,
         judge_3,
         practice_court_judge_1,
         practice_court_judge_2,
         practice_court_judge_3,
         num_titles_cited,
         length_of_case,
         act_1,act_2,
         act_3,act_4,act_5,
         doc_date,kanoon_ids_cited,acts_cited,title,text,
         in_air_corpus)%>%
  rename(kanoon_id=Kanoon_ID,
         case_yr = delivery_year,
         case_mon = delivery_month,
         petitioner = Petitioners,
         respondent = Respondents,
         court_1 = practice_court_judge_1,
         court_2 = practice_court_judge_2,
         court_3 = practice_court_judge_3)

# obtain the required/relevant variables from chatgpt and human coded data and will be merged with the base temlpate later
# andy's dataset has duplicates but some valuable veriables like location, so dedup while retaining these
# also need some string cleaning/processing to get binary outputs from yes/no answers and scores given by chatgpt

andy_cols<-as_tibble(colnames(andy))
df_ord <- andy%>%select(c(2:14))%>%filter(trimws(q1_response)!="")
df_loc<-andy%>%select(c(2,15:39))%>%filter(trimws(gptoutput)!="")
df_base<-andy%>%distinct(kanoon_id)%>%filter(!is.na(kanoon_id))
df_andy<-df_base%>%left_join(df_ord,by=c("kanoon_id"))%>%left_join(df_loc,by=c("kanoon_id"))

andy_vars<-df_andy%>%
  mutate(pcb_action = gsub("(\\w+),?\\:?.*","\\1",q2_response),
         pcb_action = case_when(
           tolower(pcb_action) == "yes" ~ 1,
           tolower(pcb_action) == "no" ~ 0,
           TRUE ~ NA_integer_
         ),
         follow = gsub("(\\w+),?\\:?.*","\\1",q3_response),
         follow = case_when(
           tolower(follow) == "tweak" ~ 0,
           tolower(follow) == "follow" ~ 1,
           tolower(follow) == "tweaked" ~ 0,
           tolower(follow) == "answer" ~ 0,
           TRUE ~ NA_integer_
         ),
         regulator_action = tolower(gsub("(\\w+),?\\:?\\.?.*","\\1",q4_response)),
         regulator_action = case_when(
           regulator_action=="yes" ~ 1,
           regulator_action=="no" ~ 0,
           regulator_action=="binary" ~ 1,
           TRUE ~ NA_integer_
         ),
         env_relevance = as.numeric(gsub(".*?(\\d+).*","\\1",q5_response),na.rm=T),
         env_relevance = case_when(
           env_relevance > 100 ~ NA_integer_,
           env_relevance == 1 ~ as.numeric(gsub(".*(\\d)?:\\s(\\d+).*","\\2",q5_response),na.rm=T),
           env_relevance == 4 ~ 95,
           env_relevance == 13 ~ 50,
           env_relevance == 18 ~ 20,
           env_relevance <= 100 ~ env_relevance,
           TRUE ~ NA_integer_
         ),
         q1_green=as.numeric(str_extract(q1_response,"\\d+"),na.rm=TRUE),
         green_verdict = if_else(q1_green > 50, 1,
                                 if_else(q1_green <= 50,0,NA_integer_)),
         state = case_when(grepl("^Punjab(.*)Haryana.*",trimws(state)) ~ gsub("^Punjab(.*)Haryana.*","Punjab and Haryana",trimws(state)),
                           grepl("^(\\w+\\s?\\w*),.*",trimws(state)) ~ gsub("(\\w+\\s?\\w*),.*","\\1",trimws(state)),
                           trimws(state)=="Cha" ~ "Chhattisgarh",
                           trimws(state)=="H" ~ "Haryana",
                           trimws(state)=="J" ~ "Jharkhand",
                           trimws(state)=="Mad" ~ "Madhya Pradesh",
                           trimws(state)=="Tamil" ~ "Tamil Nadu",
                           trimws(state)=="Tel" ~ "Telangana",
                           state=="NCT of Delhi" ~ "New Delhi",
                           state=="Bombay" ~ "Maharashtra",
                           grepl("^(Orissa),?.*",state) ~ gsub("^(Orissa),?.*","Odisha",state),
                           trimws(state)=="" ~ NA_character_,
                           TRUE ~ state),
         district = case_when(trimws(district)=="" ~ NA_character_,
                              TRUE ~ district),
         city = case_when(trimws(city)=="" ~ NA_character_,
                              TRUE ~ city))

### stata has encoding and bindquote issues reading long texts, so dropping them in the compact version

andy_vars_compact<-andy_vars%>%select(kanoon_id,state,district,city,pcb_action:green_verdict)

# test<-andy_vars%>%count(state)
# test2<-andy_vars%>%filter(env_relevance == 85)%>%select(q5_response)


### human dataset variables to be merged with the base

case_vars<-case%>%select(c(3,15,16,18))%>%rename(kanoon_id=Kanoon_ID,
                                                         state=State, district=District)%>%
  mutate(state = case_when(trimws(state)=="n.a" ~ NA_character_,
                           trimws(state)=="<not given>" ~ NA_character_,
                           trimws(state)=="-" ~ NA_character_,
                           trimws(state)=="" ~ NA_character_,
                           TRUE ~ state),
         district = case_when(trimws(district)=="n.a" ~ NA_character_,
                              trimws(district)=="<not given>" ~ NA_character_,
                              trimws(district)=="-" ~ NA_character_,
                              trimws(district)=="" ~ NA_character_,
                              TRUE ~ district),
         city=NA_character_,
         green_verdict = if_else(trimws(Social.Impact) == "yes",1,
                                 if_else(trimws(Social.Impact)=="no",0,NA_integer_)))%>%
  select(-Social.Impact)

# merging the human+chatgpt variables to base template

base_all<-as.data.frame(rbind(air_base2,case_base))%>%distinct(kanoon_id,.keep_all = TRUE)

merged_dataset<-base_all%>%left_join(andy_vars, by=c("kanoon_id"))%>%
  left_join(case_vars,by=c("kanoon_id"),suffix=c("_gpt","_human"))


final_dataset<-merged_dataset%>%mutate(
  state = case_when(
    !is.na(state_human) ~ state_human,
    is.na(state_human) & !is.na(state_gpt) ~ state_gpt,
    TRUE ~ NA_character_
  ),
  district = case_when(
    !is.na(district_human) ~ district_human,
    is.na(district_human) & !is.na(district_gpt) ~ district_gpt,
    TRUE ~ NA_character_
  ),
  city = city_gpt,
  green_verdict = case_when(
    !is.na(green_verdict_human) ~ green_verdict_human,
    is.na(green_verdict_human) & !is.na(green_verdict_gpt) ~ green_verdict_gpt,
    TRUE ~ NA_integer_
  )
)
# %>%select(!contains(c("state_","district_","city_")))

final_dataset<-final_dataset%>%mutate(
  state = tolower(state),
  state = case_when(
    state == "ch" ~ "chhattisgarh",
    state == "cha" ~ "chhattisgarh",
    state == "ch" ~ "chhattisgarh",
    state == "chhatisgarh" ~ "chhattisgarh",
    state == "delhi" ~ "new delhi",
    state=="nct.*" ~ "new dehi",
    grepl("^punjab(.*)haryana.*",trimws(state)) ~ gsub("^punjab(.*)haryana.*","punjab and haryana",trimws(state)),
    grepl("^(orissa),?.*",state) ~ gsub("^(orissa),?.*","odisha",state),
    state == "tami" ~ "tamil nadu",
    state == "tamilnadu" ~ "tamil nadu",
    state == "pondicherry" ~ "puducherry",
    grepl("^(\\w+\\s?\\w*),.*",state) ~ gsub("(\\w+\\s?\\w*),.*","\\1",state),
    state == "nil" ~ NA_character_,
    TRUE ~ state
  )
)
final_dataset$state[final_dataset$state == "telangana state"]<-"telangana"
final_dataset$state[final_dataset$state == "nct"]<-"new delhi"
final_dataset$state[final_dataset$state == "nct of delhi"]<-"new delhi"
final_dataset$state[final_dataset$state == "na"]<-NA_character_
final_dataset$state[final_dataset$state == "gujrat"]<-"gujarat"

final_dataset<-final_dataset%>%mutate(word_count_bin = case_when(
  is.na(length_of_case) ~ NA_character_,
  length_of_case >= 0 & length_of_case <= 300 ~ "0 to 300",
  length_of_case > 300 & length_of_case <= 500 ~ "300 to 500",
  length_of_case > 500 & length_of_case <= 1000 ~ "500 to 1000",
  length_of_case > 1000 & length_of_case <= 1500 ~ "1000 to 1500",
  length_of_case > 1500 & length_of_case <= 2000 ~ "1500 to 2000",
  length_of_case > 2000 & length_of_case <= 2500 ~ "2000 to 2500",
  length_of_case > 2500 & length_of_case <= 3000 ~ "2500 to 3000",
  length_of_case > 3000 & length_of_case <= 3500 ~ "3000 to 3500",
  length_of_case > 3500 & length_of_case <= 4000 ~ "3500 to 4000",
  length_of_case > 4000 & length_of_case <= 4500 ~ "4000 to 4500",
  length_of_case > 4500 & length_of_case <= 5000 ~ "4500 to 5000",
  length_of_case > 5000  ~ "over 5000",
  TRUE ~ "undefined"
  
),
bin_citations = case_when(
  num_titles_cited <= 10 ~ as.character(num_titles_cited,na.rm=T),
  num_titles_cited > 10  ~ "over 10 titles",
  TRUE ~ NA_character_
))

### We also need to flag water pollution cases that were mixed in

# airpol<-read.csv("air_pollution_olexiy_combined.csv")
water<-read.csv("case_data_final_water_pollution.csv")
water2<-water%>%select(Kanoon_ID, impact_coded, Social.Impact)%>%
  rename(kanoon_id = Kanoon_ID,
         impact_coded_water = impact_coded,
         social_impact_water = Social.Impact)
water2$kanoon_id<-as.character(water2$kanoon_id)
final_dataset<-final_dataset%>%left_join(water2,by=c("kanoon_id"))%>%
  mutate(water_cases = if_else(!is.na(social_impact_water),1,0))

write.csv(final_dataset,"final_merged_air_pollution_cases.csv")


### Compact merge for further processing in STATA #################################################################

merged_compact<-base_all%>%select(-text)%>%left_join(andy_vars_compact, by=c("kanoon_id"))%>%
  left_join(case_vars,by=c("kanoon_id"),suffix=c("_gpt","_human"))


final_dataset2<-merged_compact%>%mutate(
  state = case_when(
    !is.na(state_human) ~ state_human,
    is.na(state_human) & !is.na(state_gpt) ~ state_gpt,
    TRUE ~ NA_character_
  ),
  district = case_when(
    !is.na(district_human) ~ district_human,
    is.na(district_human) & !is.na(district_gpt) ~ district_gpt,
    TRUE ~ NA_character_
  ),
  city = city_gpt,
  green_verdict = case_when(
    !is.na(green_verdict_human) ~ green_verdict_human,
    is.na(green_verdict_human) & !is.na(green_verdict_gpt) ~ green_verdict_gpt,
    TRUE ~ NA_integer_
  )
)%>%select(!contains(c("state_","district_","city_")))

final_dataset2<-final_dataset2%>%mutate(
  state = tolower(state),
  state = case_when(
    state == "ch" ~ "chhattisgarh",
    state == "cha" ~ "chhattisgarh",
    state == "ch" ~ "chhattisgarh",
    state == "chhatisgarh" ~ "chhattisgarh",
    state == "delhi" ~ "new delhi",
    state=="nct.*" ~ "new dehi",
    grepl("^punjab(.*)haryana.*",trimws(state)) ~ gsub("^punjab(.*)haryana.*","punjab and haryana",trimws(state)),
    grepl("^(orissa),?.*",state) ~ gsub("^(orissa),?.*","odisha",state),
    state == "tami" ~ "tamil nadu",
    state == "tamilnadu" ~ "tamil nadu",
    state == "pondicherry" ~ "puducherry",
    grepl("^(\\w+\\s?\\w*),.*",state) ~ gsub("(\\w+\\s?\\w*),.*","\\1",state),
    state == "nil" ~ NA_character_,
    TRUE ~ state
  )
)
final_dataset2$state[final_dataset2$state == "telangana state"]<-"telangana"
final_dataset2$state[final_dataset2$state == "nct"]<-"new delhi"
final_dataset2$state[final_dataset2$state == "nct of delhi"]<-"new delhi"
final_dataset2$state[final_dataset2$state == "na"]<-NA_character_
final_dataset2$state[final_dataset2$state == "gujrat"]<-"gujarat"

final_dataset2<-final_dataset2%>%mutate(word_count_bin = case_when(
  is.na(length_of_case) ~ NA_character_,
  length_of_case >= 0 & length_of_case <= 300 ~ "0 to 300",
  length_of_case > 300 & length_of_case <= 500 ~ "300 to 500",
  length_of_case > 500 & length_of_case <= 1000 ~ "500 to 1000",
  length_of_case > 1000 & length_of_case <= 1500 ~ "1000 to 1500",
  length_of_case > 1500 & length_of_case <= 2000 ~ "1500 to 2000",
  length_of_case > 2000 & length_of_case <= 2500 ~ "2000 to 2500",
  length_of_case > 2500 & length_of_case <= 3000 ~ "2500 to 3000",
  length_of_case > 3000 & length_of_case <= 3500 ~ "3000 to 3500",
  length_of_case > 3500 & length_of_case <= 4000 ~ "3500 to 4000",
  length_of_case > 4000 & length_of_case <= 4500 ~ "4000 to 4500",
  length_of_case > 4500 & length_of_case <= 5000 ~ "4500 to 5000",
  length_of_case > 5000  ~ "over 5000",
  TRUE ~ "undefined"
  
),
bin_citations = case_when(
  num_titles_cited <= 10 ~ as.character(num_titles_cited,na.rm=T),
  num_titles_cited > 10  ~ "over 10 titles",
  TRUE ~ NA_character_
))

# airpol<-read.csv("air_pollution_olexiy_combined.csv")
water<-read.csv("case_data_final_water_pollution.csv")
water2<-water%>%select(Kanoon_ID, impact_coded, Social.Impact)%>%
  rename(kanoon_id = Kanoon_ID,
         impact_coded_water = impact_coded,
         social_impact_water = Social.Impact)
water2$kanoon_id<-as.character(water2$kanoon_id)
final_dataset2<-final_dataset2%>%left_join(water2,by=c("kanoon_id"))%>%
  mutate(water_cases = if_else(!is.na(social_impact_water),1,0))

write.csv(final_dataset2,"final_merged_air_pollution_cases_compact.csv")

#### end: below this is toy code for quality checks so ignore #######################


# test1<-water%>%select(Kanoon_ID, Social.Impact, impact_coded)%>%
#   mutate(Kanoon_ID=as.character(Kanoon_ID,na.rm=T))
# test2<-case%>%select(Kanoon_ID, Social.Impact, impact_coded)
# test3<-test1%>%left_join(test2,by=c("Kanoon_ID"),suffix=c("_water","_air"))%>%filter(!is.na(Social.Impact_air))
# 
# # test<-final_dataset%>%filter(is.na(state) | is.na(district)| is.na(city))
# # test<-final_dataset%>%filter(is.na(city) & (is.na(district)))
# test<-final_dataset%>%mutate(state= tolower(state))%>%count(district)
# test2<-final_dataset%>%filter(tolower(state)=="ch")%>%select(district)
# test<-final_dataset%>%filter(!is.na(green_verdict_gpt) & !(is.na(green_verdict_human)))
# # test<-df_andy%>%count(state)
# # 
# # test2<-andy_vars%>%filter(env_relevance == "1")%>%select(q5_response)
# 
# # rm(df_andy,df_base,df_loc,df_ord)
# # rm(air_base,air_base2,andy_cols)
# 
# 
# 
# 
# test<-air_corp%>%filter(kanoon_id==1026316)%>%select(text)
# test<-final_dataset%>%mutate(word_count_bin = case_when(
#   is.na(length_of_case) ~ NA_character_,
#   length_of_case >= 0 & length_of_case <= 300 ~ "0 to 300",
#   length_of_case > 300 & length_of_case <= 500 ~ "300 to 500",
#   length_of_case > 500 & length_of_case <= 1000 ~ "500 to 1000",
#   length_of_case > 1000 & length_of_case <= 1500 ~ "1000 to 1500",
#   length_of_case > 1500 & length_of_case <= 2000 ~ "1500 to 2000",
#   length_of_case > 2000 & length_of_case <= 2500 ~ "2000 to 2500",
#   length_of_case > 2500 & length_of_case <= 3000 ~ "2500 to 3000",
#   length_of_case > 3000 & length_of_case <= 3500 ~ "3000 to 3500",
#   length_of_case > 3500 & length_of_case <= 4000 ~ "3500 to 4000",
#   length_of_case > 4000 & length_of_case <= 4500 ~ "4000 to 4500",
#   length_of_case > 4500 & length_of_case <= 5000 ~ "4500 to 5000",
#   length_of_case > 5000  ~ "over 5000",
#   TRUE ~ "undefined"
#   
# ))%>%count(word_count_bin)
# 
#   
# test2<-final_dataset%>%mutate(word_count_bin = case_when(
#   is.na(length_of_case) ~ NA_character_,
#   length_of_case >= 0 & length_of_case <= 300 ~ "0 to 300",
#   length_of_case > 300 & length_of_case <= 500 ~ "300 to 500",
#   length_of_case > 500 & length_of_case <= 1000 ~ "500 to 1000",
#   length_of_case > 1000 & length_of_case <= 1500 ~ "1000 to 1500",
#   length_of_case > 1500 & length_of_case <= 2000 ~ "1500 to 2000",
#   length_of_case > 2000 & length_of_case <= 2500 ~ "2000 to 2500",
#   length_of_case > 2500 & length_of_case <= 3000 ~ "2500 to 3000",
#   length_of_case > 3000 & length_of_case <= 3500 ~ "3000 to 3500",
#   length_of_case > 3500 & length_of_case <= 4000 ~ "3500 to 4000",
#   length_of_case > 4000 & length_of_case <= 4500 ~ "4000 to 4500",
#   length_of_case > 4500 & length_of_case <= 5000 ~ "4500 to 5000",
#   length_of_case > 5000  ~ "over 5000",
#   TRUE ~ "undefined"
#   
# ))
# 
# test3<-test%>%left_join(test2,by=c("word_count_bin"))%>%rename(all_cases = n.x, green_cases = n.y)
# total_cases = sum(test3$all_cases)  
# total_green = sum(test3$green_cases)
# test3<-test3%>%mutate(freq_all = all_cases/total_cases,
#                       freq_green = green_cases/total_green)
# write.csv(test3,"word_counts.csv")
# 
# test<-final_dataset%>%mutate(bin_citations = case_when(
#   num_titles_cited <= 10 ~ as.character(num_titles_cited,na.rm=T),
#   num_titles_cited > 10  ~ "over 10 titles",
#   TRUE ~ NA_character_
# ))%>%count(bin_citations)
# 
# test2<-final_dataset%>%mutate(bin_citations = case_when(
#   num_titles_cited <= 10 ~ as.character(num_titles_cited,na.rm=T),
#   num_titles_cited > 10  ~ "over 10 titles",
#   TRUE ~ NA_character_
# ))%>%filter(green_verdict==1)%>%count(bin_citations)
# test3<-test%>%left_join(test2,by=c("bin_citations"))%>%rename(all_cases = n.x, green_cases = n.y)
# test3<-test3%>%mutate(freq_all = all_cases/total_cases,
#                       freq_green = green_cases/total_green)
# 
# write.csv(test3,"citations.csv")
# 
# 
# test<-final_dataset%>%filter(green_verdict_human != green_verdict_gpt)
# test_gpt<-test[sample(nrow(test),size=20),]%>%select(kanoon_id,green_verdict,green_verdict_gpt,green_verdict_human)
# test_hum<-case%>%filter(Kanoon_ID %in%test_gpt$kanoon_id)
# 
# write.csv(test_gpt,"test.csv")
# 
# 
# ########## Dataset for Olexiy on locations prediction #############
# 
# master<-read.csv("final_merged_air_pollution_cases.csv")
# colss<-as_tibble(colnames(master))
# master2<-master%>%mutate(junk_1 = case_when(
#   length_of_case <= 300 ~ 1,
#   length_of_case > 300 ~ 0,
#   TRUE ~ NA_integer_
# ),
# junk_2 = case_when(
#   env_relevance <= 50 ~ 1,
#   env_relevance > 50 ~ 0,
#   TRUE ~ NA_integer_
# ),
# human_case = if_else(!is.na(green_verdict_human),1,0),
# chatgpt_case = if_else(!is.na(green_verdict_gpt),1,0),
# common_case = if_else(!is.na(green_verdict_gpt) & !is.na(green_verdict_human),1,0))
# 
# master2%>%filter(human_case==1)%>%nrow() #1910
# master2%>%filter(chatgpt_case==1)%>%nrow() #9449
# master2%>%filter(common_case==1)%>%nrow() #1836
# 
# master3<-master2%>%filter(common_case==1)%>%
#   select(kanoon_id,title,text,in_air_corpus, case_date, case_yr,case_mon, 
#                           contains("_human"),contains("_gpt"),contains("state"),contains("district"))
# 
# write.csv(master3,"Locations_analysis_for_Olexiy.csv")
# master3%>%fi(lter(is.na(text))%>%nrow()

# case<-read.csv("case_data_final_with_additional_variables.csv")
# colss<-as_tibble(colnames(case))
# judge_name_list<-list("Judge.1","Judge.2","Judge.3","name_matched_1","name_matched_2","name_matched_3","name_cleaned_1",
#                    "name_cleaned_2","name_cleaned_3", "Name_judge_1","Name_judge_2","Name_judge_3")
# for (i in judge_name_list) {
#   counts<-case%>%filter((trimws(get(i))!="") & (!is.na(get(i))))%>%nrow()
#   print(counts)
# }
# judge_names1<-case%>%distinct(Judge.1)%>%rename(Judge=Judge.1)
# judge_names2<-case%>%distinct(Judge.2)%>%rename(Judge=Judge.2)
# judge_names3<-case%>%distinct(Judge.3)%>%rename(Judge=Judge.3)
# judge_names<-rbind(judge_names3,judge_names2,judge_names1)%>%distinct()
# 
# judge_names1<-case%>%distinct(name_cleaned_1)%>%rename(Judge=name_cleaned_1)
# judge_names2<-case%>%distinct(name_cleaned_2)%>%rename(Judge=name_cleaned_2)
# judge_names3<-case%>%distinct(name_cleaned_3)%>%rename(Judge=name_cleaned_3)
# judge_names<-rbind(judge_names3,judge_names2,judge_names1)%>%distinct()
# 
# case%>%filter(name_cleaned_3 == "g k pandey and r c trivedi")%>%select(name_matched_3)
# case%>%filter(name_cleaned_3 == "g k pandey and r c trivedi")%>%select(Judge.3)
# 
# 
# judge_names1<-case%>%distinct(name_matched_1)%>%rename(Judge=name_matched_1)
# judge_names2<-case%>%distinct(name_matched_2)%>%rename(Judge=name_matched_2)
# judge_names3<-case%>%distinct(name_matched_3)%>%rename(Judge=name_matched_3)
# judge_names<-rbind(judge_names3,judge_names2,judge_names1)%>%distinct()
# 
# check<-case%>%filter(trimws(name_cleaned_1)!="" & trimws(name_matched_1)=="")%>%select(Judge.1,name_cleaned_1,name_matched_1)
# case%>%filter((trimws(name_matched_1)==""))%>%nrow()
# 
# case<-read.csv("final_merged_air_pollution_cases_compact.csv")
# judge_names1<-case%>%filter(!is.na(green_verdict_human))%>%distinct(judge_1)%>%rename(Judge=judge_1)
# judge_names2<-case%>%filter(!is.na(green_verdict_human))%>%distinct(judge_2)%>%rename(Judge=judge_2)
# judge_names3<-case%>%filter(!is.na(green_verdict_human))%>%distinct(judge_3)%>%rename(Judge=judge_3)
# judge_names<-rbind(judge_names3,judge_names2,judge_names1)%>%distinct()
# 
# case<-read.csv("possible_air_corpus_with_meta_and_text.csv")
