
* Finalizing OC Computation


* I. OC14

cd "$your_path_here/5-Final_data_processing_in_Stata/OC"
mkdir "GIS_dta_files"
mkdir "GIS_dta_files/1-Monthly_ID"
mkdir "GIS_dta_files/2-Monthly_Districts"
mkdir "GIS_dta_files/3-Appended"

forval i = 1981/2020 {
cd "$your_path_here/5-Final_data_processing_in_Stata/OC/GIS_data/`i'"
local myfilescsv : dir . files "*.csv"
foreach fn of local myfilescsv {
	import delimited "`fn'", clear
	
	keep id mean
	ren id ID
	local a = substr("`fn'",3,2)
	ren mean oc`a'
	gen year = `i'
		
	local j = substr("`fn'",12,2)
	gen month = "`j'"
	destring month, replace
	
	save "$your_path_here/5-Final_data_processing_in_Stata/OC/GIS_dta_files/1-Monthly_ID/oc`a'_`i'`j'.dta", replace
}
}


cd "$your_path_here/5-Final_data_processing_in_Stata/OC"
forval i = 1981/2020 {
local zero = "0"

forval j = 1/9 {
use GIS_dta_files/1-Monthly_ID/oc14_`i'`zero'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year oc14
save GIS_dta_files/2-Monthly_Districts/oc14_`i'`j', replace
}
forval j = 10/12 {
use GIS_dta_files/1-Monthly_ID/oc14_`i'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year oc14
save GIS_dta_files/2-Monthly_Districts/oc14_`i'`j', replace
}
}

forval i = 1981/2020 {
use GIS_dta_files/2-Monthly_Districts/oc14_`i'1, clear
forval j = 2/12 {
append using GIS_dta_files/2-Monthly_Districts/oc14_`i'`j'
save GIS_dta_files/3-Appended/oc14_`i', replace
}
}

use GIS_dta_files/3-Appended/oc14_1981, clear
forval i = 1982/2020 {
append using GIS_dta_files/3-Appended/oc14_`i'
sort district year month
save oc14_MERRA_long_districts, replace
}

count
* 288,000

*===============================================================================


* II. OC16


cd "$your_path_here/5-Final_data_processing_in_Stata/OC"
forval i = 1981/2020 {
local zero = "0"

forval j = 1/9 {
use GIS_dta_files/1-Monthly_ID/oc16_`i'`zero'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year oc16
save GIS_dta_files/2-Monthly_Districts/oc16_`i'`j', replace
}
forval j = 10/12 {
use GIS_dta_files/1-Monthly_ID/oc16_`i'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year oc16
save GIS_dta_files/2-Monthly_Districts/oc16_`i'`j', replace
}
}

forval i = 1981/2020 {
use GIS_dta_files/2-Monthly_Districts/oc16_`i'1, clear
forval j = 2/12 {
append using GIS_dta_files/2-Monthly_Districts/oc16_`i'`j'
save GIS_dta_files/3-Appended/oc16_`i', replace
}
}

use GIS_dta_files/3-Appended/oc16_1981, clear
forval i = 1982/2020 {
append using GIS_dta_files/3-Appended/oc16_`i'
sort district year month
save oc16_MERRA_long_districts, replace
}

count
* 288,000

*===============================================================================


* III. OC18


cd "$your_path_here/5-Final_data_processing_in_Stata/OC"
forval i = 1981/2020 {
local zero = "0"

forval j = 1/9 {
use GIS_dta_files/1-Monthly_ID/oc18_`i'`zero'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year oc18
save GIS_dta_files/2-Monthly_Districts/oc18_`i'`j', replace
}
forval j = 10/12 {
use GIS_dta_files/1-Monthly_ID/oc18_`i'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year oc18
save GIS_dta_files/2-Monthly_Districts/oc18_`i'`j', replace
}
}

forval i = 1981/2020 {
use GIS_dta_files/2-Monthly_Districts/oc18_`i'1, clear
forval j = 2/12 {
append using GIS_dta_files/2-Monthly_Districts/oc18_`i'`j'
save GIS_dta_files/3-Appended/oc18_`i', replace
}
}

use GIS_dta_files/3-Appended/oc18_1981, clear
forval i = 1982/2020 {
append using GIS_dta_files/3-Appended/oc18_`i'
sort district year month
save oc18_MERRA_long_districts, replace
}

count
* 288,000

*===============================================================================



