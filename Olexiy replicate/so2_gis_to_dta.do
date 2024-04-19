
* Finalizing SO2 Computation


cd "$your_path_here/5-Final_data_processing_in_Stata/SO2"

mkdir "GIS_dta_files"
mkdir "GIS_dta_files/1-Monthly_ID"
mkdir "GIS_dta_files/2-Monthly_Districts"
mkdir "GIS_dta_files/3-Appended"

forval i = 1981/2020 {
cd "$your_path_here/5-Final_data_processing_in_Stata/SO2/GIS_data/`i'"
local myfilescsv : dir . files "*.csv"
foreach fn of local myfilescsv {
	import delimited "`fn'", clear
	
	keep id mean
	ren id ID
	ren mean so2
	gen year = `i'
		
	local j = substr("`fn'",12,2)
	*gen str month = "`j'"
	gen month = "`j'"
	destring month, replace
	
	save "$your_path_here/5-Final_data_processing_in_Stata/SO2/GIS_dta_files/1-Monthly_ID/so2`i'`j'", replace
}
}

cd "$your_path_here/5-Final_data_processing_in_Stata/SO2"


forval i = 1981/2020 {
local zero = "0"

forval j = 1/9 {
use GIS_dta_files/1-Monthly_ID/so2`i'`zero'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year so2
save GIS_dta_files/2-Monthly_Districts/so2`i'`j', replace
}
forval j = 10/12 {
use GIS_dta_files/1-Monthly_ID/so2`i'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year so2
save GIS_dta_files/2-Monthly_Districts/so2`i'`j', replace
}
}

forval i = 1981/2020 {
use GIS_dta_files/2-Monthly_Districts/so2`i'1, clear
forval j = 2/12 {
append using GIS_dta_files/2-Monthly_Districts/so2`i'`j'
save GIS_dta_files/3-Appended/so2`i', replace
}
}

use GIS_dta_files/3-Appended/so21981, clear
forval i = 1982/2020 {
append using GIS_dta_files/3-Appended/so2`i'
sort district year month
save so2_MERRA_long_districts, replace
}

count
* 288,000

*===============================================================================





