********************************************************************************
*************     1.    Data Preprocessing        *********************
********************************************************************************

********************************************************************************
* Table 4: Yearly regression, all pollutants *
********************************************************************************

clear all


* Paths
*global Tables D:\Dropbox\India_Pollution\04_Tables
*global Data D:\Dropbox\India_Pollution\Shashank\shashank_github_data\01_Data\Analysis

global Data /Users/shashanksingh/Desktop/github/india_air_pollution/data 
global Output /Users/shashanksingh/Desktop/github/india_air_pollution

* Load Data
use "$Data/temp/tempdata_monthly_juris_pol.dta",clear 

sort district year month


********************************************************************************
* Program to add AR CI to e-matrix *
********************************************************************************

** Define Extraction of upper and lower bound.
capture program drop fnsplitci
program define fnsplitci
		* Remove parenthesis
		local lp = strpos(arcset, "]") - 2      
		scalar arcset = substr(arcset, 2, `lp')

		* Extract upper and lower bound
		local pos = strpos(arcset, ",")
		scalar lb = substr(arcset, 1, `pos'-1)
		scalar ub = substr(arcset, `pos'+1, .)
		*scalar ub = strtrim(ub)

		* As numeric
		scalar lb = real(lb)
		scalar ub = real(ub)
end

** Add CI to stored results
capture program drop EMatrix2StepARCI
program define EMatrix2StepARCI, eclass
        * Create matrix
        matrix A = (lb, 0, 0, 0, 0 \ ub, 0, 0, 0, 0)
		matrix colnames A = "FracGreenCases a a a a"
        * Add matrix to e results
        ereturn matrix cilar2 = A
end

** Add CI to stored results
capture program drop EMatrix2StepARCI1
program define EMatrix2StepARCI1, eclass
        * Create matrix
        matrix A = (lb, 0, 0, 0, 0 \ ub, 0, 0, 0, 0)
		matrix colnames A = "FracGreenCases_lag_1 a a a a"
        * Add matrix to e results
        ereturn matrix cilar2 = A
end

** Add CI to stored results
capture program drop EMatrix2StepARCI2
program define EMatrix2StepARCI2, eclass
        * Create matrix
        matrix A = (lb, 0, 0, 0, 0 \ ub, 0, 0, 0, 0)
		matrix colnames A = "FracGreenCases_lag_2 a a a a"
        * Add matrix to e results
        ereturn matrix cilar2 = A
end

** Add CI to stored results
capture program drop EMatrix2StepARCI3
program define EMatrix2StepARCI3, eclass
        * Create matrix
        matrix A = (lb, 0, 0, 0, 0 \ ub, 0, 0, 0, 0)
		matrix colnames A = "FracGreenCases_lag_3 a a a a"
        * Add matrix to e results
        ereturn matrix cilar2 = A
end

** Add CI to stored results
capture program drop EMatrix2StepARCI4
program define EMatrix2StepARCI4, eclass
        * Create matrix
        matrix A = (lb, 0, 0, 0, 0 \ ub, 0, 0, 0, 0)
		matrix colnames A = "FracGreenCases_lag_4 a a a a"
        * Add matrix to e results
        ereturn matrix cilar2 = A
end

** Add CI to stored results
capture program drop EMatrix2StepARCI5
program define EMatrix2StepARCI5, eclass
        * Create matrix
        matrix A = (lb, 0, 0, 0, 0 \ ub, 0, 0, 0, 0)
		matrix colnames A = "FracGreenCases_lag_5 a a a a"
        * Add matrix to e results
        ereturn matrix cilar2 = A
end

** Add CI to stored results
capture program drop EMatrix2StepARCI6
program define EMatrix2StepARCI6, eclass
        * Create matrix
        matrix A = (lb, 0, 0, 0, 0 \ ub, 0, 0, 0, 0)
		matrix colnames A = "FracGreenCases_lag_6 a a a a"
        * Add matrix to e results
        ereturn matrix cilar2 = A
end




********************************************************************************
* Delhi - CI *
********************************************************************************

keep if delhi_dum == 1

forvalues p = 1/25{
	
	by district: gen lag_1_d2v_vec`p' = d2v_vec`p'[_n-1] 
	by district: gen lag_2_d2v_vec`p' = d2v_vec`p'[_n-2] 
	by district: gen lag_3_d2v_vec`p' = d2v_vec`p'[_n-3] 
	by district: gen lag_4_d2v_vec`p' = d2v_vec`p'[_n-4] 
	by district: gen lag_5_d2v_vec`p' = d2v_vec`p'[_n-5] 
}



forvalues p = 1/6{
	


** Estimates
estimates clear
eststo clear


* Loop over pollution outcomes
foreach rv of varlist lnbc lndu lnoc14 lnoc16 lnoc18 lnpm14 lnpm16 lnpm18 lnso2 lnso4 lnss {
	display "`rv'"

	quietly ivreg2 `rv' (FracGreenCases_lag_`p' = lag_`p'_d2v_vec* JudgePostGrad_lag_`p') CaseDummy_lag_`p' GovtRespondent_lag_`p' Appeal_lag_`p' Constitutional_lag_`p' i.year i.month, robust small partial(i.year i.month)

	* Store the estimates
	estimates store modelAll_`rv'
	
	scalar bcoeff = _b[FracGreenCases_lag_`p']

	* Check if underidentified
	display "Underidentified:" e(idp)
	
	* If idp == ., then no instruments used
	if e(idp) == . {
		scalar arcset = "[.,.]"
			
		* Extract upper and lower bound
		fnsplitci
		
		* Add CI to saved estimates
		EMatrix2StepARCI`p'

		* Restore final estimates
		estimates store modelAll_`rv'
		
		* Display raw CI
		display "Beta:" bcoeff
		display "CI:" arcset
	
		display "idp == . => continue"
		continue
	}
	
	* Add efficient First Stage F stat
	quietly weakivtest
	display "Efficienf F:" r(F_eff)
	estadd scalar fF = r(F_eff) : modelAll_`rv'

	scalar efff = r(F_eff)
	scalar fcrit = r(c_TSLS_5)
	display fcrit
	
	* Estimate CI sets
	quietly twostepweakiv 2sls `rv' CaseDummy_lag_`p' GovtRespondent_lag_`p' Appeal_lag_`p' Constitutional_lag_`p' i.year i.month (FracGreenCases_lag_`p' = lag_`p'_d2v_vec* JudgePostGrad_lag_`p'), robust small partial(i.year i.month) gridmult(10) gridpoints(1000)

	* Create scalar from AR CI set
	* If efficient first stage F-stat >= fcrit, use Wald, if not use LC-CI
	if efff >= fcrit {
		display "Strong IV"
		scalar arcset = e(wald_cset)
	}
	else {
		display "Weak IV"

		* Use K CI
		scalar arcset = e(k_2sls_cset)
		
		* Check if disjoint CI
		scalar disjoint = strpos(arcset, "U")
		if disjoint != 0 {
			scalar arcset = "[.,.]"
		}
	}
	
	* Display raw CI
	display "Beta:" bcoeff
	display "CI:" arcset

	* Extract upper and lower bound
	fnsplitci
	
	* Check if CI includes Point estimate
	if (bcoeff < lb | bcoeff > ub)  & arcset != "[.,.]" {
		display "not in CI"
		scalar arcset = "[.,.]"
		scalar lb = .
		scalar ub = .
	}

	* Reload estimates and Add AR Confidence Interval
	estimates restore modelAll_`rv'
	EMatrix2StepARCI`p'
	
	* Restore final estimates
	estimates store modelAll_`rv'
}


** Add table local
estadd local fe "Yes": modelAll_*
estadd local covar "Yes": modelAll_*
estadd local clust "NA": modelAll_*
estadd local nocases "Dummied": modelAll_*


** Save table
esttab modelAll_* using "$Tables/Table05_Monthly_Pollution_Delhi_D2V_AR_lag_`p'.tex", cell(b(fmt(a3)) cilar2[1](fmt(a3) par("[" ";")) & cilar2[2](fmt(a3) par("" "]"))) replace label star(* 0.10 ** 0.05 *** 0.01) stats(nocases fe covar clust fF N k, labels("Year-months with no cases" "Year and Month FEs" "Covariates" "Clustering" "Eff First Stage F" "N" "\midrule \midrule")) keep(FracGreenCases_lag_`p' CaseDummy_lag_`p') order(FracGreenCases_lag_`p' CaseDummy_lag_`p') sfmt(%9.2fc) title("") booktabs fragment mtitles(ln(bc) ln(du) ln(oc14) ln(oc16) ln(oc18) ln(pm14) ln(pm16) ln(pm18) ln(so2) ln(so4) ln(ss)) collabels(none) prehead("\textbf{Panel A: Delhi _lag_`p'} \\")

}


