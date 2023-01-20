********************************************************************************
* Yearly Pollution *
********************************************************************************
global Data "C:\Users\wb570559\github\india_air_pollution\data"

clear all

** Import data set
import delimited "$Data/processed_data/yearly_air_len_heuristic.csv", varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 
sort district year

* This creates some empty / NA observations
drop if year == .


** Merge clusters to data
merge m:1 district_x year using $Data/processed_data/yearly_air_clusters.dta


* Create district variable
drop district
gen district = district_x
sort district year

* Create Variables
gen JudgeW 		= (gender_binary < 1 & gender_binary ~= .) 
gen JudgeW_len_heur = JudgeW/length_of_case

gen JudgeGrad 		= ((ed_llb >= 0.5 & ed_llb~=.) | (ed_ba >= 0.5 & ed_ba~=.) | (ed_bsc >= 0.5 & ed_bsc~=.) | (ed_bcom >= 0.5 & ed_bcom~=.))
gen JudgeGrad_len_heur = JudgeGrad/length_of_case

gen JudgePG	= ((ed_ma >= 0.5 & ed_ma~=.) |  (ed_msc >= 0.5 & ed_msc~=.) | (ed_mcom >= 0.5 & ed_mcom~=.) | (ed_llm >= 0.5 & ed_llm~=.) | (ed_doc >= 0.5 & ed_doc~=.))
gen JudgePG_len_heur = JudgePG/length_of_case

gen GovtPetitioner 	= (govt_petitioner == 1) 
gen GovtPetitioner_len_heur = GovtPetitioner/length_of_case

gen GovtResp 	= (govt_respondent == 1) 
gen GovtResp_len_heur = GovtResp/length_of_case

gen Appeal 			= (is_appeal == 1)
gen Appeal_len_heur = Appeal/length_of_case

gen Const 	= (is_constitutional == 1)
gen Const_len_heur = Const/length_of_case

* Environmental case
gen EnvCase 		= (kanoon_id ~= .)

* Problem: Some district years with kanoon cases have additional lines, with no case but pollution data, this falsifies our means when collapsing
by district year : egen TotCases = total(EnvCase)
drop if TotCases >= 1 & kanoon_id == .

* Green Cases based on Median
gen NotGreenCases	= (most_freq_coded_vals < 0 & most_freq_coded_vals ~= .)
gen GreenCases		= (most_freq_coded_vals > 0 & most_freq_coded_vals ~= .)


* Create Judge count with 0 instead of .
gen NumJudges 		= num_judges
replace NumJudges 	= 0 	if num_judges == .

gen NumJudges_len_heur		= NumJudges/length_of_case

* Generate Practice Area of judges
gen practice_area_civil = (pa_civil>0 & pa_civil~=.)
gen practice_area_service = (pa_service>0 & pa_service~=.)
gen practice_area_constitution = (pa_constitution>0 & pa_constitution~=.)
gen practice_area_criminal = (pa_criminal>0 & pa_criminal~=.)
gen practice_area_labour = (pa_labour>0 & pa_labour~=.)
gen practice_area_company = (pa_company>0 & pa_company~=.)
gen practice_area_tax = (pa_tax>0 & pa_tax~=.)
gen practice_area_commercial = (pa_commercial>0 & pa_commercial~=.)
gen practice_area_arbitration = (pa_arbitration>0 & pa_arbitration~=.)
gen practice_area_family = (pa_family>0 & pa_family~=.)
gen practice_area_admin = (pa_administrative>0 & pa_administrative~=.)



* For LSA textfeatures, replace . by 0
foreach var of varlist lsa* {
	replace `var' 		= 0 	if `var' == .
}

* For D2V textfeatures, replace . by 0
foreach var of varlist d2v* {
	replace `var' 		= 0 	if `var' == .
}

* Collapse by Year and District
collapse (firstnm) TotCases (sum) EnvCase GreenCases* NotGreenCases* (mean) most_freq_coded_vals* bc du oc14 oc16 oc18 pm14 pm16 pm18 so2 so4 ss NumJudges* JudgeW* JudgeGrad* JudgePG* practice_area_civil practice_area_service practice_area_constitution practice_area_criminal practice_area_labour practice_area_company practice_area_tax practice_area_admin practice_area_commercial practice_area_arbitration practice_area_family GovtPetitioner* GovtResp* Appeal* Const* lsa* d2v* cluster_bp cluster_sp delhi_dummy length_of_case, by(district year)


* New IV: multiplication
replace		JudgeW			= 0 	if EnvCase == 0
replace		JudgePG	 	= 0 	if EnvCase == 0

replace		JudgeW_len_heur			= 0 	if EnvCase == 0
replace		JudgePG_len_heur	 	= 0 	if EnvCase == 0

* Green Cases based on Median
gen FracGreenCases			= GreenCases / EnvCase

replace FracGreenCases 		= 0 	if FracGreenCases == .




* Create log values
gen lnbc 		= 	ln(bc)
gen lndu 		= 	ln(du)
gen lnoc14 	= 	ln(oc14)
gen lnoc16		= 	ln(oc16)
gen lnoc18		= 	ln(oc18)
gen lnpm14		= 	ln(pm14)
 
gen lnpm16 	= 	ln(pm16)
gen lnpm18	= 	ln(pm18)
gen lnso2 	= 	ln(so2)
gen lnso4 	= 	ln(so4)
gen lnss 	= 	ln(ss)





* Create Case Dummy
gen CaseDummy = (TotCases > 0)

* Labels
label var practice_area_civil "Majority Practice Area Civil"
label var practice_area_service "Majority Practice Area Service"
label var practice_area_constitution "Majority Practice Area Constitution"
label var practice_area_criminal "Majority Practice Area Criminal"
label var practice_area_labour "Majority Practice Area Labour"
label var practice_area_company "Majority Practice Area Company"
label var practice_area_tax "Majority Practice Area Tax"
label var practice_area_commercial "Majority Practice Area Commercial"
label var practice_area_arbitration "Majority Practice Area Arbitration"
label var practice_area_family "Majority Practice Area Family"
label var practice_area_admin "Majority Practice Area Administrative"

label var FracGreenCases "Fraction of Green Cases"
label var GreenCases "Total Green Cases"

label var TotCases "Total Cases"

label var NumJudges "Number of Judges"
label var Const "Const"
label var Appeal "Appeal"
label var GovtResp "Government is Resp"
label var GovtPetitioner "Government is Petitioner"
label var JudgePG "Majority Judges have a Post Graduate Degree (mean)"
label var JudgeGrad "Majority Judges have a Graduate Degree (mean)"
label var JudgeW "Presence of a Female Judge"

label var NumJudges_len_heur "Number of Judges (length heuristic weighted)"
label var Const_len_heur "Constitutional (length heuristic weighted)"
label var Appeal_len_heur "Appeal (length heuristic weighted)"
label var GovtResp_len_heur "Government is Respondent (length heuristic weighted)"
label var GovtPetitioner_len_heur "Government is Petitioner (length heuristic weighted)"
label var JudgePG_len_heur "Majority Judges have a Post Graduate Degree (mean) (length heuristic weighted)"
label var JudgeGrad_len_heur "Majority Judges have a Graduate Degree (mean) (length heuristic weighted)"
label var JudgeW_len_heur "Presence of a Female Judge (length heuristic weighted)"


label var CaseDummy "Dummy for Presence of a Case"

label var cluster_bp "Cluster by district-years with connected cases"
label var cluster_bp "Cluster by district-years with exactly same set of cases"

* Sort by district year
sort district year

forvalues p = 1/5{

	by district: gen GreenCases_lag_`p' = GreenCases[_n-`p'] 
	label var GreenCases_lag_`p' "Total Green Cases Lag `p'"
	
	by district: gen FracGreenCases_lag_`p' = FracGreenCases[_n-`p']
	label var FracGreenCases_lag_`p' "Fraction of Green Cases Lag `p'"
	
	by district: gen TotCases_lag_`p' = TotCases[_n-`p'] 
	label var TotCases_lag_`p' "Total Cases Lag `p'"
	
	by district: gen NumJudges_lag_`p' = NumJudges[_n-`p'] 
	label var NumJudges_lag_`p' "Number of Judges Lag `p'"
	
	by district: gen JudgeW_lag_`p' = JudgeW[_n-`p'] 
	label var JudgeW_lag_`p' "Presence of a Female Judge Lag `p'"
	
	by district: gen JudgePG_lag_`p' = JudgePG[_n-`p'] 
	label var JudgePG_lag_`p' "Majority Judges have a Post Graduate Degree (mean) Lag `p'"
	
	by district: gen GovtResp_lag_`p' = GovtResp[_n-`p'] 
	label var GovtResp_lag_`p' "Government is Resp Lag `p'"
	
	by district: gen Appeal_lag_`p' = Appeal[_n-`p'] 
	label var Appeal_lag_`p' "Appeal Lag `p'"
	
	by district: gen Const_lag_`p' = Const[_n-`p'] 
	label var Const_lag_`p' "Const Lag `p'"
	
	by district: gen CaseDummy_lag_`p' = CaseDummy[_n-`p']
	label var CaseDummy_lag_`p' "CaseDummy Lag `p'"
}

forvalues p = 1/5{
	
	by district: gen NumJudges_len_heur_lag_`p' = NumJudges_len_heur[_n-`p'] 
	label var NumJudges_len_heur_lag_`p' "Number of Judges Lag `p' (length heuristic weighted)"
	
	by district: gen JudgeW_len_heur_lag_`p' = JudgeW_len_heur[_n-`p'] 
	label var JudgeW_len_heur_lag_`p' "Presence of a Female Judge Lag `p' (length heuristic weighted)"
	
	by district: gen JudgePG_len_heur_lag_`p' = JudgePG_len_heur[_n-`p'] 
	label var JudgePG_len_heur_lag_`p' "Majority Judges have a Post Graduate Degree (mean) Lag `p' (length heuristic weighted)"
	
	by district: gen GovtResp_len_heur_lag_`p' = GovtResp_len_heur[_n-`p'] 
	label var GovtResp_len_heur_lag_`p' "Government is Respondent Lag `p' (length heuristic weighted)"
	
	by district: gen Appeal_len_heur_lag_`p' = Appeal_len_heur[_n-`p'] 
	label var Appeal_len_heur_lag_`p' "Appeal Lag `p' (length heuristic weighted)"
	
	by district: gen Const_len_heur_lag_`p' = Const_len_heur[_n-`p'] 
	label var Const_len_heur_lag_`p' "Constitutional Lag `p' (length heuristic weighted)"
	
}

forvalues p = 1/25{
	
	by district: gen d2v_vec`p'_lag_0 = d2v_vec`p'[_n-0] 
	by district: gen d2v_vec`p'_lag_1 = d2v_vec`p'[_n-1] 
	by district: gen d2v_vec`p'_lag_2 = d2v_vec`p'[_n-2] 
	by district: gen d2v_vec`p'_lag_3 = d2v_vec`p'[_n-3] 
	by district: gen d2v_vec`p'_lag_4 = d2v_vec`p'[_n-4] 
	by district: gen d2v_vec`p'_lag_5 = d2v_vec`p'[_n-5] 	
	
}

forvalues p = 1/25{
	
	by district: gen d2v_vec`p'_len_heur_lag_0 = d2v_vec`p'_len_heur[_n-0] 
	by district: gen d2v_vec`p'_len_heur_lag_1 = d2v_vec`p'_len_heur[_n-1] 
	by district: gen d2v_vec`p'_len_heur_lag_2 = d2v_vec`p'_len_heur[_n-2] 
	by district: gen d2v_vec`p'_len_heur_lag_3 = d2v_vec`p'_len_heur[_n-3] 
	by district: gen d2v_vec`p'_len_heur_lag_4 = d2v_vec`p'_len_heur[_n-4] 
	by district: gen d2v_vec`p'_len_heur_lag_5 = d2v_vec`p'_len_heur[_n-5] 	
	
}

* Encode districts
encode district, gen(district_encoded)


*** Compress dataset
compress


*** Save temporary dataset
save "$Data/temp_data/tempdata_yearly_juris_pol_with_len_heurs.dta", replace



