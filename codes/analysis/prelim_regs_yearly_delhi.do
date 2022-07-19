********************************************************************************
*************     1.    Data Preprocessing        *********************
********************************************************************************

**************************

* NOT JURISDICTION BASED *

**************************


********************************************************************************
* 1.1 Preprocess Yearly Pollution Data *
********************************************************************************

clear all



* Paths
global Tables /Users/shashanksingh/Desktop/github/india_air_pollution/results/tables_olexiy
global Data /Users/shashanksingh/Desktop/github/india_air_pollution/data

* Load Data
import delimited "$Data/processed_data/yearly_air.csv",varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

drop district

gen district = district_x

* Create district variable
sort district year


* Create Variables
* gender_binary indicates the share of judges on a case which are women
gen JudgeWoman 		= (gender_binary < 1 & gender_binary ~= .) 

gen JudgeGrad 		= ((ed_llb >= 0.5 & ed_llb~=.) | (ed_ba >= 0.5 & ed_ba~=.) | (ed_bsc >= 0.5 & ed_bsc~=.) | (ed_bcom >= 0.5 & ed_bcom~=.))

gen JudgePostGrad	= ((ed_ma >= 0.5 & ed_ma~=.) |  (ed_msc >= 0.5 & ed_msc~=.) | (ed_mcom >= 0.5 & ed_mcom~=.) | (ed_llm >= 0.5 & ed_llm~=.) | (ed_doc >= 0.5 & ed_doc~=.))

gen GovtPetitioner 	= (govt_petitioner == 1)
gen GovtRespondent 	= (govt_respondent == 1)
gen Appeal 			= (is_appeal == 1)
gen Constitutional 	= (is_constitutional == 1)

* Environmental case
gen EnvCase 		= (kanoon_id ~= .)

* Problem: Some district years with kanoon cases have additional lines, with no case but pollution data, this falsifies our means when collapsing
by district year : egen TotCases = total(EnvCase)
drop if TotCases >= 1 & kanoon_id == .


* Green Cases based on impact_coded
*gen NotGreenCase	= (impact_coded < 0 & impact_coded ~= .)
*gen GreenCase 		= (impact_coded > 0 & impact_coded ~= .)

* Green Cases based on Median
gen NotGreenCaseMedian 		= (most_freq_coded_vals < 0 & most_freq_coded_vals ~= .)
gen GreenCaseMedian 		= (most_freq_coded_vals > 0 & most_freq_coded_vals ~= .)

* Green Cases based on Mean
gen NotGreenCaseMean 	= (mean_coded_vals < 0 & mean_coded_vals ~= .)
gen GreenCaseMean 		= (mean_coded_vals > 0 & mean_coded_vals ~= .)


* Create Judge count with 0 instead of .
gen NumJudges 		= num_judges
replace NumJudges 	= 0 	if num_judges == .



* Create textfeatures with 1 if missing
foreach var of varlist lsa* {
	gen One`var'		= `var'
	replace One`var' 	= 1 	if `var' == .
}

* For original textfeatures, replace . by 0
foreach var of varlist lsa* {
	replace `var' 		= 0 	if `var' == .
}

* For D2V textfeatures, replace . by 0
foreach var of varlist d2v_vec* {
	replace `var' 		= 0 	if `var' == .
}


* Collapse by Year and District
collapse (sum) EnvCase NotGreenCaseMedian GreenCaseMedian NotGreenCaseMean GreenCaseMean TotCases (mean) bc du oc14 oc16 oc18 pm14 pm16 pm18 so2 so4 ss NumJudges JudgeWoman JudgeGrad JudgePostGrad GovtPetitioner GovtRespondent Appeal Constitutional lsa* Onelsa* d2v_vec* delhi_dummy, by(district year)


* Collapse by Year and District
*collapse (sum) EnvCase NotGreenCase GreenCase NotGreenCaseMF GreenCaseMF NotGreenCaseMean GreenCaseMean JudgeWoman ///
*	(mean) bod cod NumJudges JudgeGrad JudgePostGrad ///
*	GovtPetitioner GovtRespondent Appeal Constitutional lsa*, by(district year)


* New IV: multiplication
replace	 JudgeWoman = 0 if EnvCase == 0

gen  JudgeWomanOne = JudgeWoman
replace	 JudgeWomanOne = 1 if EnvCase == 0

replace	 JudgePostGrad = 0 if EnvCase == 0

gen	 JudgePostGradOne = JudgePostGrad
replace	 JudgePostGradOne = 1 if EnvCase == 0


* Green Cases based on Median
gen FracGreenCases			= GreenCaseMean / EnvCase
replace FracGreenCases 		= 0 	if FracGreenCases == .

* Create an alternative measure where FracGreenCases = 1 if missing
gen FracGreenCasesOne 		= GreenCaseMean / EnvCase
replace FracGreenCasesOne 	= 1 	if FracGreenCasesOne == .

* Create an alternative measure where FracGreenCases = . if missing
gen FracGreenCasesMis 		= GreenCaseMean / EnvCase

* Green Cases based on Mean
gen FracGreenCasesMedian 	= GreenCaseMedian / EnvCase
replace FracGreenCasesMedian = 0 	if FracGreenCasesMedian == .



* Take out "neutral" cases


foreach var of varlist bc du oc14 oc16 oc18 pm14 pm16 pm18 so2 so4 ss {

* Create 3 year MA 
gen `var'_ma 		= `var'
by district: replace `var'_ma = (`var'_ma[_n-3] + `var'_ma[_n-2] + `var'_ma[_n-1]) / 3 if `var' == .



* Create log value of BOD and COD
gen ln_`var'		= 	ln(`var')
gen ln_`var'_ma		= 	ln(`var'_ma)

}


* Create Case Dummy
gen CaseDummy 	= (EnvCase > 0)

* Labels
label var FracGreenCases 		"Fraction of Green Cases (Mean)"
label var FracGreenCasesMedian 	"Fraction of Green Cases (Median)"

label var FracGreenCasesOne 	"Fraction of Green Cases, Missing = 1"
label var FracGreenCasesMis 	"Fraction of Green Cases, Missing = ."

label var GreenCaseMedian 		"Total Green Cases (Median)"
label var GreenCaseMean		"Total Green Cases (Mean)"
label var EnvCase 			"Total Cases"
label var NumJudges 		"Number of Judges"
label var Constitutional 	"Constitutional"
label var Appeal 			"Appeal"
label var GovtRespondent 	"Government is Respondent"
label var GovtPetitioner 	"Government is Petitioner"

label var JudgePostGrad 	"Majority Judges have a Post Graduate Degree (mean)"
label var JudgeGrad 		"Majority Judges have a Graduate Degree (mean)"
label var JudgeWoman 		"Majority Judges are Female"

label var JudgeWomanOne		"Majority Judges are Female, Missing = 1"
label var JudgePostGradOne 	"Majority Judges have a Post Graduate Degree, Missing = 1"




label var CaseDummy "Case Dummy"

drop if district == ""


sort district year
encode district, gen(district_encoded)

forvalues p = 1/5{

	by district: gen GreenCaseMean_lag_`p' = GreenCaseMean[_n-`p'] 
	label var GreenCaseMean_lag_`p' "Total Green Cases Lag `p'"
	
	by district: gen FracGreenCases_lag_`p' = FracGreenCases[_n-`p']
	label var FracGreenCases_lag_`p' "Fraction of Green Cases Lag `p'"
	
	*by district: gen TotCases_lag_`p' = TotCases[_n-`p'] 
	*label var TotCases_lag_`p' "Total Cases Lag `p'"
	
	by district: gen NumJudges_lag_`p' = NumJudges[_n-`p'] 
	label var NumJudges_lag_`p' "Number of Judges Lag `p'"
	
	by district: gen JudgeWoman_lag_`p' = JudgeWoman[_n-`p'] 
	label var JudgeWoman_lag_`p' "Presence of a Female Judge Lag `p'"
	
	by district: gen JudgePostGrad_lag_`p' = JudgePostGrad[_n-`p'] 
	label var JudgePostGrad_lag_`p' "Majority Judges have a Post Graduate Degree (mean) Lag `p'"
	
	by district: gen GovtRespondent_lag_`p' = GovtRespondent[_n-`p'] 
	label var GovtRespondent_lag_`p' "Government is Respondent Lag `p'"
	
	by district: gen Appeal_lag_`p' = Appeal[_n-`p'] 
	label var Appeal_lag_`p' "Appeal Lag `p'"
	
	by district: gen Constitutional_lag_`p' = Constitutional[_n-`p'] 
	label var Constitutional_lag_`p' "Constitutional Lag `p'"
	
	by district: gen CaseDummy_lag_`p' = CaseDummy[_n-`p']
	label var CaseDummy_lag_`p' "CaseDummy Lag `p'"
}


forvalues p = 1/25{
	
	by district: gen d2v_vec`p'_lag_0 = d2v_vec`p'[_n-0] 
	by district: gen d2v_vec`p'_lag_1 = d2v_vec`p'[_n-1] 
	by district: gen d2v_vec`p'_lag_2 = d2v_vec`p'[_n-2] 
	by district: gen d2v_vec`p'_lag_3 = d2v_vec`p'[_n-3] 
	by district: gen d2v_vec`p'_lag_4 = d2v_vec`p'[_n-4] 
	by district: gen d2v_vec`p'_lag_5 = d2v_vec`p'[_n-5] 	
	
}



********************************************************************************
****************** 2. Yearly Pollution Panel Regressions ***********************
********************************************************************************

******************************

** Delhi specific with lags **

******************************

label var FracGreenCases 	"Fraction of Green Cases"

foreach var of varlist bc du oc14 oc16 oc18 pm14 pm16 pm18 so2 so4 ss {

reg `var' FracGreenCases JudgeWoman JudgePostGrad d2v_vec* CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year if delhi_dummy==1
}

