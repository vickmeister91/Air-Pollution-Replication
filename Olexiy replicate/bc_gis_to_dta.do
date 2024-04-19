
* Finalizing BC Computation

cd "$your_path_here/5-Final_data_processing_in_Stata/BC"
mkdir "GIS_dta_files"
mkdir "GIS_dta_files/1-Monthly_ID"
mkdir "GIS_dta_files/2-Monthly_Districts"
mkdir "GIS_dta_files/3-Appended"

forval i = 1981/2020 {
cd "$your_path_here/5-Final_data_processing_in_Stata/BC/GIS_data/`i'"
local myfilescsv : dir . files "*.csv"
foreach fn of local myfilescsv {
	import delimited "`fn'", clear
	
	keep id mean
	ren id ID
	ren mean bc
	gen year = `i'
		
	local j = substr("`fn'",12,2)
	*gen str month = "`j'"
	gen month = "`j'"
	destring month, replace
	
	save "$your_path_here/5-Final_data_processing_in_Stata/BC/GIS_dta_files/1-Monthly_ID/bc`i'`j'.dta", replace
}
}

cd "$your_path_here/5-Final_data_processing_in_Stata/BC"
forval i = 1981/2020 {
local zero = "0"

forval j = 1/9 {
use GIS_dta_files/1-Monthly_ID/bc`i'`zero'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year bc
save GIS_dta_files/2-Monthly_Districts/bc`i'`j', replace
}
forval j = 10/12 {
use GIS_dta_files/1-Monthly_ID/bc`i'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year bc
save GIS_dta_files/2-Monthly_Districts/bc`i'`j', replace
}
}

forval i = 1981/2020 {
use GIS_dta_files/2-Monthly_Districts/bc`i'1, clear
forval j = 2/12 {
append using GIS_dta_files/2-Monthly_Districts/bc`i'`j'
save GIS_dta_files/3-Appended/bc`i', replace
}
}

use GIS_dta_files/3-Appended/bc1981, clear
forval i = 1982/2020 {
append using GIS_dta_files/3-Appended/bc`i'
sort district year month
save bc_MERRA_long_districts, replace
}

count
* 288,000

*===============================================================================
