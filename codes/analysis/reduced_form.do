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
global Tables "C:\Users\wb570559\github\india_air_pollution\results\tables"



********************************************************************************
* Prepare Data *
********************************************************************************

* Load Data
use "$Data/temp_data/tempdata_yearly_juris_pol.dta", clear



foreach var of varlist d2v* {
	replace `var' = 0 if `var' == .
}

replace CaseDummy 	= 0 if CaseDummy == .
replace GovtRespondent 		= 0 if GovtRespondent == .
replace Appeal 				= 0 if Appeal == .
replace Constitutional 		= 0 if Constitutional == .


foreach rv of varlist lnbc lndu lnoc14 lnoc16 lnoc18 lnpm14 lnpm16 lnpm18 lnso2 lnso4 lnss {
eststo clear

reghdfe `rv' d2v* GovtRespondent Appeal Constitutional CaseDummy, absorb(district_encoded year) cluster(cluster_sp)

estimates store modelAll_`rv'

}

estadd local fe "District, Year": modelAll_*
estadd local clust "Small Pond": modelAll_*
estadd local covar "Yes": modelAll_*
estadd local nocases "Dummied": modelAll_*

esttab modelAll_* using "$Tables/reduced_form.xlsx", ///
	replace label star(* 0.10 ** 0.05 *** 0.01) ///
	stats(nocases fe clust F N, labels("District-years with no cases" "Year and District FEs" "Clustering" "F" "N")) ///
	keep(d2v* GovtRespondent Appeal Constitutional CaseDummy) order(d2v* GovtRespondent Appeal Constitutional CaseDummy) ///
	sfmt(%9.2fc) title("") ///
	booktabs fragment ///	
	mtitles(pm14) ///
	collabels(none)
	
esttab modelAll_* using "$Tables/reduced_form.tex", ///
	replace label star(* 0.10 ** 0.05 *** 0.01) ///
	stats(nocases fe clust F N, labels("District-years with no cases" "Year and District FEs" "Clustering" "F" "N")) ///
	keep(d2v* GovtRespondent Appeal Constitutional CaseDummy) order(d2v* GovtRespondent Appeal Constitutional CaseDummy) ///
	sfmt(%9.2fc) title("") ///
	booktabs fragment ///	
	mtitles(ln(bc) ln(du) ln(oc14) ln(oc16) ln(oc18) ln(pm14) ln(pm16) ln(pm18) ln(so2) ln(so4) ln(ss)) ///
	collabels(none)
	
* Load Data
use "$Data/temp_data/tempdata_yearly_juris_pol.dta", clear



foreach var of varlist d2v* {
	replace `var' = 0 if `var' == .
}

replace CaseDummy 	= 0 if CaseDummy == .
replace GovtRespondent 		= 0 if GovtRespondent == .
replace Appeal 				= 0 if Appeal == .
replace Constitutional 		= 0 if Constitutional == .

loocv reghdfe most_freq_coded_vals d2v* if lnbc != . & TotCases > 0, ///
	absorb(district_encoded year) cluster(cluster_sp)
predict verdict_judges

foreach rv of varlist lnbc lndu lnoc14 lnoc16 lnoc18 lnpm14 lnpm16 lnpm18 lnso2 lnso4 lnss {
	
	qui binscatter2 `rv' verdict_judges if `rv' != . & TotCases > 0, ///
	controls(GovtRespondent Appeal Constitutional CaseDummy) ///
	absorb(district_encoded year) ///
	xtitle("Predicted Values by Judges (Judge Leniency)") ytitle("Pollution - `rv'") ///
	name(C_`rv', replace) ///
	graphregion(color(white)) ylabel(-0.5(0.5)1) xlabel(-0.5(0.5)1)

}

graph combine C_lnbc C_lndu C_lnoc14 C_lnoc16 C_lnoc18 C_lnpm14 C_lnpm16 C_lnpm18 C_lnso2 C_lnso4 C_lnss, col(1) iscale(1) graphregion(color(white))

graph export "$Graphs\Reduced_Form_Visual.png", replace













