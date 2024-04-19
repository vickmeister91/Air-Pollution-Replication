
* Finalizing DU Computation

cd "$your_path_here/5-Final_data_processing_in_Stata/DU"
mkdir "GIS_dta_files"
mkdir "GIS_dta_files/1-Monthly_ID"
mkdir "GIS_dta_files/2-Monthly_Districts"
mkdir "GIS_dta_files/3-Appended"

forval i = 1981/2020 {
cd "$your_path_here/5-Final_data_processing_in_Stata/DU/GIS_data/`i'"
local myfilescsv : dir . files "*.csv"
foreach fn of local myfilescsv {
	import delimited "`fn'", clear
	
	keep id mean
	ren id ID
	ren mean du
	gen year = `i'
		
	local j = substr("`fn'",12,2)
	*gen str month = "`j'"
	gen month = "`j'"
	destring month, replace
	
	save "$your_path_here/5-Final_data_processing_in_Stata/DU/GIS_dta_files/1-Monthly_ID/du`i'`j'", replace
}
}

cd "$your_path_here/5-Final_data_processing_in_Stata/DU"


forval i = 1981/2020 {
local zero = "0"

forval j = 1/9 {
use GIS_dta_files/1-Monthly_ID/du`i'`zero'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year du
save GIS_dta_files/2-Monthly_Districts/du`i'`j', replace
}
forval j = 10/12 {
use GIS_dta_files/1-Monthly_ID/du`i'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year du
save GIS_dta_files/2-Monthly_Districts/du`i'`j', replace
}
}

forval i = 1981/2020 {
use GIS_dta_files/2-Monthly_Districts/du`i'1, clear
forval j = 2/12 {
append using GIS_dta_files/2-Monthly_Districts/du`i'`j'
save GIS_dta_files/3-Appended/du`i', replace
}
}

use GIS_dta_files/3-Appended/du1981, clear
forval i = 1982/2020 {
append using GIS_dta_files/3-Appended/du`i'
sort district year month
save du_MERRA_long_districts, replace
}

count
* 288,000

*===============================================================================
