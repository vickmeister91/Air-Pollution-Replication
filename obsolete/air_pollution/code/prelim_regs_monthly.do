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
global Tables /Users/shashanksingh/Desktop/air_pollution/results/tables
global Data /Users/shashanksingh/Desktop/air_pollution/data/

* Load Data
import delimited "$Data/processed_data/monthly_air.csv",varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

drop district

gen district = district_x

* Create district variable
sort district year month


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
by district year month: egen TotCases = total(EnvCase)
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
collapse (sum) EnvCase NotGreenCaseMedian GreenCaseMedian NotGreenCaseMean GreenCaseMean (mean) mean_pm25 NumJudges JudgeWoman JudgeGrad JudgePostGrad GovtPetitioner GovtRespondent Appeal Constitutional lsa* Onelsa* d2v_vec*, by(district year month)


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
gen mean_pm25_ma 		= mean_pm25
by district: replace mean_pm25_ma = (mean_pm25_ma[_n-3] + mean_pm25_ma[_n-2] + mean_pm25_ma[_n-1]) / 3 if mean_pm25 == .



* Create log value of BOD and COD
gen ln_mean_pm25		= 	ln(mean_pm25)
gen ln_mean_pm25_ma		= 	ln(mean_pm25_ma)


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

label var mean_pm25 		"Mean PM 2.5"
label var mean_pm25_ma 		"Mean PM 2.5 Moving Average"
label var ln_mean_pm25 		"ln(Mean PM 2.5)"
label var ln_mean_pm25_ma 	"ln(Mean PM 2.5) Moving Average"


label var CaseDummy "Case Dummy"

drop if district == ""


sort district year month
encode district, gen(district_encoded)



********************************************************************************
****************** 2. Yearly Pollution Panel Regressions ***********************
********************************************************************************

********************************************************************************
* Look at different first stage regressions *
********************************************************************************


* Clear estimates
estimates clear
eststo clear

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad lsa*) CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year i.month, cluster(district_encoded) partial(i.district_encoded) first robust savefirst savefprefix(fs1)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs1*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWomanOne JudgePostGradOne Onelsa*) CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year i.month, cluster(district_encoded) partial(i.district_encoded) first robust savefirst savefprefix(fs2)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs2*

estadd local method "IV" : fs*
estadd local covar "Yes" : fs*
estadd local fe "Yes" : fs*
estadd local clust "District" : fs*
estadd local textiv "LSA" : fs*

esttab fs1* fs2* using "$Tables/Table_FS_monthly_Instruments_ZeroVsOne.tex", se replace label star(* 0.10 ** 0.05 *** 0.01) stats(method textiv fe covar clust fF N, labels("Method" "25 Text IVs" "Year and District FEs" "Covariates" "Clustering" "F" "N")) keep(JudgeWoman JudgePostGrad JudgeWomanOne JudgePostGradOne CaseDummy _cons) order(JudgeWoman JudgePostGrad JudgeWomanOne JudgePostGradOne CaseDummy _cons) sfmt(%9.2fc) title("Mean PM 2.5 Yearly (No Lag): Comparing First Stages with different Specifications") mtitles("Frac of Green Cases (Zero)" "Frac Green Cases (Zero)") booktabs fragment




********************************************************************************
* 1st stages, adding variables *
********************************************************************************

* Clear estimates
estimates clear
eststo clear

* Without 25 Text instruments
eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad) if FracGreenCasesMis != ., cluster(district_encoded) robust first savefirst savefprefix(fs1)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs1*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad) CaseDummy, cluster(district_encoded) robust first savefirst savefprefix(fs2)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs2*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad) CaseDummy i.district_encoded i.year  i.month, cluster(district_encoded) robust first savefirst savefprefix(fs3)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs3*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad) CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year  i.month, cluster(district_encoded) robust first savefirst savefprefix(fs4)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs4*

* With 25 LSA Text instruments
eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad lsa*) if FracGreenCasesMis != ., cluster(district_encoded) robust first savefirst savefprefix(fs1T)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs1T*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad lsa*) CaseDummy, cluster(district_encoded) robust first savefirst savefprefix(fs2T)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs2T*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad lsa*) CaseDummy i.district_encoded i.year  i.month, cluster(district_encoded) robust first savefirst savefprefix(fs3T)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs3T*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad lsa*) CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year  i.month, cluster(district_encoded) robust first savefirst savefprefix(fs4T)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs4T*

* With 25 D2V Text instruments
eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad d2v_vec*) if FracGreenCasesMis != ., cluster(district_encoded) robust first savefirst savefprefix(fs1d2v)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs1d2v*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad d2v_vec*) CaseDummy, cluster(district_encoded) robust first savefirst savefprefix(fs2d2v)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs2d2v*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad d2v_vec*) CaseDummy i.district_encoded i.year  i.month, cluster(district_encoded) robust first savefirst savefprefix(fs3d2v)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs3d2v*

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad d2v_vec*) CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year  i.month, cluster(district_encoded) robust first savefirst savefprefix(fs4d2v)
scalar ff = e(first)["F", "FracGreenCases"]
estadd scalar fF = ff : fs4d2v*

estadd local method "IV" : fs*
estadd local fe "Yes" : fs3* fs4*
estadd local covar "Yes" : fs4*
estadd local clust "District" : fs*
estadd local nocases "Dropped" : fs1*
estadd local nocases "Dummied" : fs2* fs3* fs4*
estadd local textiv "LSA" : fs1T* fs2T* fs3T* fs4T*
estadd local textiv "D2V" : fs1d2v* fs2d2v* fs3d2v* fs4d2v*

esttab fs* using "$Tables/Table_FS_monthly_Specifications_IV_TextIV_Specifications.tex", se replace label star(* 0.10 ** 0.05 *** 0.01) stats(method textiv nocases fe covar clust fF N, labels("Method" "25 Text IVs" "District-years with no cases" "Year and District FEs" "Covariates" "Clustering" "F" "N")) keep(JudgeWoman JudgePostGrad CaseDummy _cons) order(JudgeWoman JudgePostGrad CaseDummy _cons) sfmt(%9.2fc) title("Comparing First Stages with different Specifications in Yearly Pollution Regression (No Lag)") booktabs fragment mtitles("Frac of Green Cases" "Frac Green Cases" "Frac Green Cases" "Frac Green Cases" "Frac Green Cases" "Frac Green Cases" "Frac Green Cases" "Frac Green Cases" "Frac Green Cases" "Frac Green Cases" "Frac Green Cases" "Frac Green Cases")



********************************************************************************
* 2nd stage OLS / IV / Text IV, adding variables *
********************************************************************************

* Change labels
label var FracGreenCases 	"Fraction of Green Cases"

* Clear estimates
estimates clear
eststo clear

* Drop missing FracGreenCases
eststo: xi: ivreg2 mean_pm25 FracGreenCases if FracGreenCasesMis != ., cluster(district_encoded) robust
estadd local weak_f 	""
estadd local method 	"OLS"
estadd local fe 		""
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dropped"
estadd local textiv 	""

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad) if FracGreenCasesMis != ., cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		""
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dropped"
estadd local textiv 	""

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad lsa*) if FracGreenCasesMis != ., cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		""
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dropped"
estadd local textiv 	"LSA"

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad d2v_vec*) if FracGreenCasesMis != ., cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		""
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dropped"
estadd local textiv 	"D2V"

* Keep missing FracGreenCases as 0
eststo: xi: ivreg2 mean_pm25 FracGreenCases CaseDummy, cluster(district_encoded) robust
estadd local weak_f = 	""
estadd local method 	"OLS"
estadd local fe 		""
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	""

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad) CaseDummy, cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		""
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	""

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad lsa*) CaseDummy, cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		""
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	"LSA"

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad d2v_vec*) CaseDummy, cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		""
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	"D2V"

* Add District and Year FEs
eststo: xi: ivreg2 mean_pm25 FracGreenCases CaseDummy i.district_encoded i.year  i.month, cluster(district_encoded) robust
estadd local weak_f = 	""
estadd local method 	"OLS"
estadd local fe 		"Yes"
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	""

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad) CaseDummy i.district_encoded i.year  i.month, cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat) 
estadd local method 	"IV"
estadd local fe 		"Yes"
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	""

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad lsa*) CaseDummy i.district_encoded i.year  i.month, cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		"Yes"
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	"LSA"

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad d2v_vec*) CaseDummy i.district_encoded i.year  i.month, cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		"Yes"
estadd local covar 		""
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	"D2V"

* Add Covariates
eststo: xi: ivreg2 mean_pm25 FracGreenCases CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year  i.month, cluster(district_encoded) robust
estadd local weak_f = 	""
estadd local method 	"OLS"
estadd local fe 		"Yes"
estadd local covar 		"Yes"
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	""

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad) CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year  i.month, cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		"Yes"
estadd local covar 		"Yes"
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	""

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad lsa*) CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year  i.month, cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		"Yes"
estadd local covar 		"Yes"
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	"LSA"

eststo: xi: ivreg2 mean_pm25 (FracGreenCases = JudgeWoman JudgePostGrad d2v_vec*) CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year  i.month, cluster(district_encoded) robust
estadd scalar weak_f = 	e(widstat)
estadd local method 	"IV"
estadd local fe 		"Yes"
estadd local covar 		"Yes"
estadd local clust 		"District"
estadd local nocases 	"Dummied"
estadd local textiv 	"D2V"


esttab using "$Tables/Table_2ST_monthly_OLS_IV_TextIV_Specifications.tex", se replace label star(* 0.10 ** 0.05 *** 0.01) stats(method textiv nocases fe covar clust weak_f r2_a N, labels("Method" "25 Text IVs" "District-years with no cases" "Year and District FEs" "Covariates" "Clustering" "K-P First Stage F" "Adj. R2" "N")) keep(FracGreenCases CaseDummy _cons) order(FracGreenCases CaseDummy _cons) sfmt(%9.2fc) title("Mean PM 2.5 Yearly (No Lag), OLS, IV, IV with Text") mtitles("Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5" "Mean PM 2.5") booktabs fragment

