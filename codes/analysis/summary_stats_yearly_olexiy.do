********************************************************************************
* 1. Monitor-Year Level *
********************************************************************************

* Load Data
import delimited "/Users/shashanksingh/Desktop/air_pollution/data/processed_data/air_pollution_olexiy_combined.csv", varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

collapse (mean) bc du oc14 oc16 oc18 pm14 pm16 pm18 so2 so4 ss, by(district year)

estpost tabstat bc du oc14 oc16 oc18 pm14 pm16 pm18 so2 so4 ss , c(stat) stat(n mean sd min max)

esttab using "/Users/shashanksingh/Desktop/air_pollution/results/tables_olexiy/Table1a_SummaryStats_yearly.tex", replace cells("count(fmt(0)) mean(fmt(%15.2fc %15.2fc %15.2fc %15.2fc %15.2fc %15.2fc %15.2fc %15.2fc %15.2fc %15.2fc %15.2fc)) sd min max") label booktabs f noobs nonumbers nomtitles collabels("N" "Mean" "SD" "Min" "Max", end(" \midrule \\ \multicolumn{5}{l}{\emph{Monitor-Year Level}} \\"))




********************************************************************************
*************     1.    Data Preprocessing        *********************
********************************************************************************



********************************************************************************
* 0. Paths * 
********************************************************************************

clear all

* Paths
global Tables /Users/shashanksingh/Desktop/air_pollution/results/tables_olexiy
global Data /Users/shashanksingh/Desktop/air_pollution/data/raw_data



  
  
  
********************************************************************************
* 2.1 Case Level * Pollution
******************************************************************************** 

* number of judges
* govt_respondent
* govt_petitioner
* is_appeal
* is_constitutional
* year?
* green cases


* Load Data
import delimited "/Users/shashanksingh/Desktop/air_pollution/data/processed_data/yearly_air.csv", varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

* Only keep unique Kanoon IDs
sort kanoon_id
by kanoon_id: drop if _n > 1

* maybe other dataset?


* Labels
label var most_freq_coded_vals	"Environmental Impact (Median Coding)"
label var num_judges 			"Number of Judges"
label var delivery_year			"Decision Year"
label var is_constitutional 	"Constitutional"
label var is_appeal				"Appeal"
label var govt_respondent 		"Government is Respondent"
label var govt_petitioner 		"Government is Petitioner"


estpost tabstat is_appeal is_constitutional govt_respondent govt_petitioner delivery_year num_judges most_freq_coded_vals , c(stat) stat(n mean sd min max)

esttab using "/Users/shashanksingh/Desktop/air_pollution/results/tables_olexiy/Table1b_SummaryStats_yearly.tex", replace cells("count(fmt(0)) mean(fmt(%15.2fc %15.2fc %15.2fc %15.2fc %15.2fc 0 %15.2fc)) sd min max") label booktabs f noobs nomtitles nonumbers collabels(none) mgroups("\emph{Case Level Data - Pollution}", pattern(1 0 0 0 0) prefix( \\ \multicolumn{@span}{l}{) suffix(}) span)
  



*******************************************************************************
* 3.1 Judge Level * Pollution 
******************************************************************************** 


* gender_binary_judge_1
* age
* education ?


* Load Data
import delimited "/Users/shashanksingh/Desktop/air_pollution/data/processed_data/yearly_air.csv", varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

* Only keep unique Kanoon IDs
sort kanoon_id
by kanoon_id: drop if _n > 1

keep kanoon_id name_matched_* dateofbirth_judge_* gender_binary_* judge_age_judge_* ed_llb_judge_* ed_ba_judge_* ed_bsc_judge_* ed_bcom_judge_* ed_ma_judge_* ed_msc_judge_* ed_mcom_judge_* ed_llm_judge_* ed_doc_judge_*

reshape long name_matched_ dateofbirth_judge_ judge_age_judge_ gender_binary_judge_ ed_llb_judge_ ed_ba_judge_ ed_bsc_judge_ ed_bcom_judge_ ed_ma_judge_ ed_msc_judge_ ed_mcom_judge_ ed_llm_judge_ ed_doc_judge_ , i(kanoon_id) j(judgenr)


* Create a variable CasesPerJudge
sort name_matched_ dateofbirth_judge_
by name_matched_ dateofbirth_judge_: gen CasesPerJudge = _N

* keep only unique judges
by name_matched_ dateofbirth_judge_: drop if _n > 1

* Delete the one empty row
drop if name_matched_ == ""

* Create Dummies for Graduation and PostGraduation education
gen JudgeGrad 		= ((ed_llb_judge_ >= 0.5 & ed_llb_judge_ ~= .) | (ed_ba_judge_ >= 0.5 & ed_ba_judge_ ~= .) | (ed_bsc_judge_ >= 0.5 & ed_bsc_judge_ ~= .) | (ed_bcom_judge_ >= 0.5 & ed_bcom_judge_ ~= .))
					
gen JudgePostGrad	= ((ed_ma_judge_ >= 0.5 & ed_ma_judge_ ~= .) | (ed_msc_judge_ >= 0.5 & ed_msc_judge_ ~= .) | (ed_mcom_judge_ >= 0.5 & ed_mcom_judge_ ~= .) | (ed_llm_judge_ >= 0.5 & ed_llm_judge_ ~= .) | (ed_doc_judge_ >= 0.5 & ed_doc_judge_ ~= .))
						
label var JudgeGrad "Graduate Level Education"
label var JudgePostGrad "Post-Graduate Level Education"
label var gender_binary_judge_ "Male"
label var CasesPerJudge "Cases Per Judge"

estpost tabstat gender_binary_judge_ JudgeGrad JudgePostGrad CasesPerJudge, c(stat) stat(n mean sd min max)

esttab using "/Users/shashanksingh/Desktop/air_pollution/results/tables_olexiy/Table1b_SummaryStats_yearly.tex", append cells("count(fmt(0)) mean(fmt(%15.2fc %15.2fc %15.2fc %15.2fc 2)) sd min max") label booktabs f noobs nomtitles nonumbers collabels(none) mgroups("\emph{Judge Level Data (Pollution Sample)}", pattern(1 0 0 0 0) prefix( \\ \multicolumn{@span}{l}{) suffix(}) span) 
  
