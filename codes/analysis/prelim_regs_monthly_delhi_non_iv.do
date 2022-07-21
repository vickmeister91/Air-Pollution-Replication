********************************************************************************
*************     1.    Data Preprocessing        *********************
********************************************************************************

**************************

*JURISDICTION BASED *

**************************


********************************************************************************
* 1.1 Preprocess Yearly Pollution Data *
********************************************************************************

clear all



* Paths
global Tables /Users/shashanksingh/Desktop/github/india_air_pollution/results/tables_olexiy
global Data /Users/shashanksingh/Desktop/github/india_air_pollution/data

* Load Data
use "$Data/temp/tempdata_monthly_juris_pol.dta",clear 





********************************************************************************
****************** 2. Monthly Pollution Panel Regressions ***********************
********************************************************************************

******************************

** Delhi specific with lags **

******************************

label var FracGreenCases 	"Fraction of Green Cases"

estimates clear
eststo clear

foreach var of varlist lnbc lndu lnoc14 lnoc16 lnoc18 lnpm14 lnpm16 lnpm18 lnso2 lnso4 lnss {

reg `var' FracGreenCases JudgeWoman JudgePostGrad d2v_vec* CaseDummy GovtRespondent Appeal Constitutional i.year i.month if delhi_dummy==1

estimates store modelAll_`var'


}

** Add table local
estadd local fe "Yes": modelAll_*
estadd local met "OLS": modelAll_*


** Save table
esttab modelAll_* using "$Tables/Table05_Monthly_Pollution_Delhi_D2V_OLS.tex", se replace label star(* 0.10 ** 0.05 *** 0.01) stats(fe met N k, labels("Year and Month FEs" "Method" "N" "\midrule \midrule")) keep(FracGreenCases CaseDummy) order(FracGreenCases CaseDummy) sfmt(%9.2fc) title("") booktabs fragment mtitles(ln(bc) ln(du) ln(oc14) ln(oc16) ln(oc18) ln(pm14) ln(pm16) ln(pm18) ln(so2) ln(so4) ln(ss)) collabels(none) prehead("\textbf{Panel A: Delhi OLS} \\")


