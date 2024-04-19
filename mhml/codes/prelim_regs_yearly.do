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
global Tables C:\Users\wb570559\mlss_replication\air_pollution\results\tables
global Data C:\Users\wb570559\github\india_air_pollution\data

* Load Data
import delimited "$Data\processed_data\yearly_juris_air_olexiy_jidentity_standardised.csv",varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

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
collapse (sum) EnvCase NotGreenCaseMedian GreenCaseMedian NotGreenCaseMean GreenCaseMean (mean) bc du oc14 oc16 oc18 pm14 pm16 pm18 so2 so4 ss NumJudges JudgeWoman JudgeGrad JudgePostGrad GovtPetitioner GovtRespondent Appeal Constitutional lsa* Onelsa* d2v_vec* jidentity_*, by(district year)


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


* Create 3 year MA of mean_pm25
* bc du oc14 oc16 oc18 pm14 pm16 pm18 so2 so4 ss
gen bc_ma 		= bc
by district: replace bc_ma = (bc[_n-3] + bc[_n-2] + bc[_n-1]) / 3 if bc == .

gen du_ma 		= du
by district: replace du_ma = (du[_n-3] + du[_n-2] + du[_n-1]) / 3 if du == .

gen oc14_ma 		= oc14
by district: replace oc14_ma = (oc14[_n-3] + oc14[_n-2] + oc14[_n-1]) / 3 if oc14 == .

gen oc16_ma 		= oc16
by district: replace oc16_ma = (oc16[_n-3] + oc16[_n-2] + oc16[_n-1]) / 3 if oc16 == .

gen oc18_ma 		= oc18
by district: replace oc18_ma = (oc18[_n-3] + oc18[_n-2] + oc18[_n-1]) / 3 if oc18 == .

gen pm14_ma 		= pm14
by district: replace pm14_ma = (pm14[_n-3] + pm14[_n-2] + pm14[_n-1]) / 3 if pm14 == .

gen pm16_ma 		= pm16
by district: replace pm16_ma = (pm16[_n-3] + pm16[_n-2] + pm16[_n-1]) / 3 if pm16 == .

gen pm18_ma 		= pm18
by district: replace pm18_ma = (pm18[_n-3] + pm18[_n-2] + pm18[_n-1]) / 3 if pm18 == .

gen so2_ma 		= so2
by district: replace so2_ma = (so2[_n-3] + so2[_n-2] + so2[_n-1]) / 3 if so2 == .

gen so4_ma 		= so4
by district: replace so4_ma = (so4[_n-3] + so4[_n-2] + so4[_n-1]) / 3 if so4 == .

gen ss_ma 		= ss
by district: replace ss_ma = (ss[_n-3] + ss[_n-2] + ss[_n-1]) / 3 if ss == .



* Create log value of BOD and COD
* gen ln_mean_pm25		= 	ln(mean_pm25)
* gen ln_mean_pm25_ma		= 	ln(mean_pm25_ma)


* Create Case Dummy
gen CaseDummy 	= (EnvCase > 0)

* Labels
label var FracGreenCases 		"Fraction of Green Cases (Mean)"
label var FracGreenCasesMedian 	"Fraction of Green Cases (Median)"

label var FracGreenCasesOne 	"Fraction of Green Cases, Missing = 1"
label var FracGreenCasesMis 	"Fraction of Green Cases, Missing = ."

label var GreenCaseMedian 		"Total Green Cases (Median)"
label var GreenCaseMean 		"Total Green Cases (Mean)"
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

*label var mean_pm25 		"Mean PM 2.5"
*label var mean_pm25_ma 		"Mean PM 2.5 Moving Average"
*label var ln_mean_pm25 		"ln(Mean PM 2.5)"
*label var ln_mean_pm25_ma 	"ln(Mean PM 2.5) Moving Average"


label var CaseDummy "Case Dummy"

drop if district == ""


sort district year
encode district, gen(district_encoded)

save "$Data\temp_data\tempdata_yearly_air_olexiy_mhml.csv", replace


