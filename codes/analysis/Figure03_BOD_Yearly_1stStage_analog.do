********************************************************************************
********************************************************************************
* Graph: First stage visualisation 
********************************************************************************
********************************************************************************

/*
	Create 6 panels of binscatters:
	- 2 on case level
	- 2 on district-year level when bod != . & TotCases > 0
	- 2 on district-year level when bod != .
	For each category, it plots the prediction by judge vectors against the ///
	actual median coded value and against predicitons by only case ///
	characteristics (govt_respondent, is_appeal, is_constitutional)
	Last modified: May 10 2022
	Stata 17
*/


********************************************************************************
* Setup *
********************************************************************************


*ssc install loocv
*ssc install gtools
*net install binscatter2, from("https://raw.githubusercontent.com/mdroste/stata-binscatter2/master/")


clear all

* If needed: define globals
global Data "C:\Users\wb570559\github\india_air_pollution\data"
global Graphs "C:\Users\wb570559\github\india_air_pollution\results\graphs"



********************************************************************************
* Prepare Data *
********************************************************************************

import delim "$Data/processed_data/yearly_air.csv", varnames(1) case(lower) ///
	bindquote(strict) maxquotedrows(200) clear 



* Environmental case
gen EnvCase 		= (kanoon_id ~= .)

*keep if kanoon_id != .
drop district
gen district = district_x
drop district_x

sort district year


* Create Judge variables
gen JudgeWoman		= (gender_binary < 1 & gender_binary ~= .)
gen JudgeGrad		= ((ed_llb >= 0.5 & ed_llb ~= .) | ///
						(ed_ba >= 0.5 & ed_ba ~= .) | ///
						(ed_bsc >= 0.5 & ed_bsc ~= .)| ///
						(ed_bcom >= 0.5 & ed_bcom ~= .))
gen JudgePostGrad 	= ((ed_ma >= 0.5 & ed_ma ~= .) | ///
						(ed_msc >= 0.5 & ed_msc~= .) | ///
						(ed_mcom >= 0.5 & ed_mcom ~= .) | ///
						(ed_llm >= 0.5 & ed_llm ~= .) | ///
						(ed_doc >= 0.5 & ed_doc ~= .))
						
* Green Cases based on Median
gen GreenCase		= (most_freq_coded_vals > 0 & most_freq_coded_vals ~= .)

sort district year
by district year : egen TotGreenCases = total(GreenCase)
by district year : egen TotCases = total(EnvCase)

gen FracGreenCases 		= TotGreenCases / TotCases

* Create encoded district variables
encode district, generate(district_encoded)

* Compress data
compress

* Preserve Data
preserve



********************************************************************************
* Case Level Graphs *
********************************************************************************

* Collapse, keep first occurance
collapse (firstnm) lsa* d2v* mean_coded_vals most_freq_coded_vals ///
	JudgePostGrad govt_respondent is_appeal is_constitutional ///
	district_encoded delivery_year, by (kanoon_id)


* Predict most_freq_coded_vals by judge characteristics
loocv reghdfe most_freq_coded_vals d2v*, ///
	absorb(district_encoded delivery_year)
predict verdict_judges


* Predict most_freq_coded_vals by chase characteristics
loocv reghdfe most_freq_coded_vals govt_respondent is_appeal is_constitutional, ///
	absorb(district_encoded delivery_year)
predict verdict_case_chars


* Binscatter of Predicted Median Values by judges and Actual Median Coded Values
qui binscatter2 most_freq_coded_vals verdict_judges, ///
	absorb(district_encoded delivery_year) ///
	xtitle("Predicted Values by Judges") ytitle("Case Level") title("Median Coded Values") ///
	name(A, replace) ///
	graphregion(color(white)) ylabel(-0.5(0.5)1) xlabel(-0.5(0.5)1)
	

* 
qui binscatter2 verdict_case_chars verdict_judges, ///
	absorb(district_encoded delivery_year) ///
	mcolors(orange) lcolors(black) msymbols(triangle) ///
	xtitle("Predicted Values by Judges") title("Predicted Values by Control Variables") ytitle("") ///
	name(B, replace) ///
	graphregion(color(white)) ylabel(-0.5(0.5)1) xlabel(-0.5(0.5)1)



********************************************************************************
* District-Year Level Data *
********************************************************************************
restore

* finally collapsing on district-year
collapse (mean) pm14 lsa* d2v* mean_coded_vals most_freq_coded_vals ///
	FracGreenCases TotCases ///
	JudgeWoman JudgePostGrad govt_respondent is_appeal is_constitutional, ///
	by(district_encoded year)

foreach var of varlist d2v* {
	replace `var' = 0 if `var' == .
}

replace most_freq_coded_vals 	= 0 if most_freq_coded_vals == .
replace govt_respondent 		= 0 if govt_respondent == .
replace is_appeal 				= 0 if is_appeal == .
replace is_constitutional 		= 0 if is_constitutional == .



********************************************************************************
* District-Year Level if pm14 != . & TotCases > 0 *
********************************************************************************	

* Predict most_freq_coded_vals by judge characteristics
loocv reghdfe most_freq_coded_vals d2v* if pm14 != . & TotCases > 0, ///
	absorb(district_encoded year)
predict verdict_judges

* Predict most_freq_coded_vals by chase characteristics
loocv reghdfe most_freq_coded_vals govt_respondent is_appeal is_constitutional if pm14 != . & TotCases > 0, ///
	absorb(district_encoded year)
predict verdict_case_chars

* Binscatter of Predicted Median Values by judges and Actual Median Coded Values
qui binscatter2 most_freq_coded_vals verdict_judges if pm14 != . & TotCases > 0, ///
	absorb(district_encoded year) ///
	xtitle("Predicted Values by Judges") ytitle("District Year Level: With Cases") ///
	name(C, replace) ///
	graphregion(color(white)) ylabel(-0.5(0.5)1) xlabel(-0.5(0.5)1)

*
qui binscatter2 verdict_case_chars verdict_judges if pm14 != . & TotCases > 0, ///
	absorb(district_encoded year) ///
	mcolors(orange) lcolors(black) msymbols(triangle) ///
	xtitle("Predicted Values by Judges") ytitle("") ///
	name(D, replace) ///
	graphregion(color(white)) ylabel(-0.5(0.5)1) xlabel(-0.5(0.5)1) 
	


********************************************************************************
* Combine graphs together *
********************************************************************************

graph combine A B C D, ///
	cols(2) ysize(20) xsize(25) ///
	ycommon xcommon graphregion(color(white))

graph export "$Graphs\Figure03_Graphical_1stStage.png", replace

********************************************************************************
* Reduced Form Binscatter *
*******************************************************************************
qui binscatter2 pm14 d2v* if pm14 != . & TotCases > 0, ///
	absorb(district_encoded year) ///
	xtitle("Judges' D2V'") ytitle("PM 14") ///
	name(E, replace) ///
	graphregion(color(white)) ylabel(-0.5(0.5)1) xlabel(-0.5(0.5)1) ///
	savegraph("$Graphs\Figure03_ReducedForm.png")

