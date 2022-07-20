********************************************************************************
*************************   Master File for Analysis   *************************
********************************************************************************

********************************************************************************
* Air Pollution
* STATA VERSION: 16.0
* LAST MODIFIED: July 113 2022
* LAST MODIFIED BY: Shashank
********************************************************************************


*****************
* PROGRAM SETUP *
*****************
clear
clear matrix
clear mata
set more off
pause off
graph drop _all
version 16



********************************************************************************
* Define Paths *
********************************************************************************

* Change these Paths!
global Data /Users/shashanksingh/Desktop/github/india_air_pollution/data 
global Output /Users/shashanksingh/Desktop/github/india_air_pollution

* Codes
global Codes /Users/shashanksingh/Desktop/github/india_air_pollution/codes/analysis

* Tables
global Tables $Output/04_Tables

* Figures
global Graphs $Output/03_Graphs

* Figures
global Logs $Output/00_Logs



********************************************************************************
* Check if Folders Tables and Graphs exist, if not create them *
********************************************************************************

capture cd "$Tables/"
di _rc
if _rc!=0 {
	shell mkdir "$Tables/"
}

capture cd "$Graphs/"
di _rc
if _rc!=0 {
	shell mkdir "$Graphs/"
}

capture cd "$Logs/"
di _rc
if _rc!=0 {
	shell mkdir "$Logs/"
}

* Change working directory back to Codes
cd $Codes



********************************************************************************
* Creating Log File *
********************************************************************************

*Logs
local filename "Analysis"
capture log close `filename'
local date = td(`c(current_date)')
local start_time = tc(`c(current_time)')
local tstamp = string(month(`date'), "%02.0f") + string(day(`date'), "%02.0f") + string(year(`date')) + "_" + string(hh(`start_time'), "%02.0f") + string(mm(`start_time'), "%02.0f")
log using "$Logs/`filename'_`tstamp'.log", replace name(`filename')



********************************************************************************
* Install Necessary Packages *
********************************************************************************

ssc install loocv
ssc install gtools
net install binscatter2, from("https://raw.githubusercontent.com/mdroste/stata-binscatter2/master/")
ssc install twostepweakiv
ssc install weakivtest
ssc install coefplot
ssc install ivreg2
ssc install pdslasso
ssc install estout



********************************************************************************
* Data Perparation *
********************************************************************************

*cd $Codes

* Create Clusters
do clusters.do


* Create dta files with monthly/yearly pollution/mortality variables on district level
do preprocessing.do

********************************************************************************
* Delhi Regressions *
********************************************************************************

do prelim_regs_monthly_delhi_non_iv.do

*do prelim_regs_monthly_delhi.do













