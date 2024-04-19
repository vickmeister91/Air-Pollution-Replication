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
use "$Data/temp/tempdata_yearly_juris_pol.dta"







********************************************************************************
* All India - CI *
********************************************************************************

forvalues p = 1/25{
	
	by district: gen lag_1_d2v_vec`p' = d2v_vec`p'[_n-1] 
	by district: gen lag_2_d2v_vec`p' = d2v_vec`p'[_n-2] 
	by district: gen lag_3_d2v_vec`p' = d2v_vec`p'[_n-3] 
	by district: gen lag_4_d2v_vec`p' = d2v_vec`p'[_n-4] 
	by district: gen lag_5_d2v_vec`p' = d2v_vec`p'[_n-5] 
}

** Add clusteres
forvalues p = 1/5 {
	by district: gen cluster_sp_lead_`p' = cluster_sp[_n+`p']
}
forvalues p = 0/5 {
	by district: gen cluster_sp_lag_`p' = cluster_sp[_n-`p']
}


* Loop over pollution outcomes
foreach rv of varlist lnbc lndu lnoc14 lnoc16 lnoc18 lnpm14 lnpm16 lnpm18 lnso2 lnso4 lnss {
	display "`rv'"

	quietly reg `rv' FracGreenCases d2v_vec* JudgePostGrad CaseDummy GovtRespondent Appeal Constitutional i.district_encoded i.year, cluster(cluster_sp) 
	
	estimates table, keep(FracGreenCases CaseDummy) b(%9.3fc) se(%9.2fc) p(%9.2fc)

}

forvalues p = 1/3{


* Loop over pollution outcomes
foreach rv of varlist lnbc lndu lnoc14 lnoc16 lnoc18 lnpm14 lnpm16 lnpm18 lnso2 lnso4 lnss {
	display "`rv'"

	reg `rv' FracGreenCases_lag_`p' lag_`p'_d2v_vec* JudgePostGrad_lag_`p' CaseDummy_lag_`p' GovtRespondent_lag_`p' Appeal_lag_`p' Constitutional_lag_`p' i.district_encoded i.year, cluster(cluster_sp_lag_`p') 



}
}
