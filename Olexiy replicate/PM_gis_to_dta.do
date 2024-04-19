
* Finalizing PM Computation


* I. OC140

cd "$your_path_here/5-Final_data_processing_in_Stata/PM"
mkdir "GIS_dta_files"
mkdir "GIS_dta_files/1-Monthly_ID"
mkdir "GIS_dta_files/2-Monthly_Districts"
mkdir "GIS_dta_files/3-Appended"

forval i = 1981/2020 {
cd "$your_path_here/5-Final_data_processing_in_Stata/PM/GIS_data/OC140/`i'"
local myfilescsv : dir . files "*.csv"
foreach fn of local myfilescsv {
	import delimited "`fn'", clear
	
	keep id mean
	ren id ID
	ren mean pm14
	gen year = `i'
		
	local j = substr("`fn'",12,2)
	*gen str month = "`j'"
	gen month = "`j'"
	destring month, replace
	
	save "$your_path_here/5-Final_data_processing_in_Stata/PM/GIS_dta_files/1-Monthly_ID/OC140/pm14_`i'`j'", replace
}
}

cd "$your_path_here/5-Final_data_processing_in_Stata/PM"
forval i = 1981/2020 {
local zero = "0"

forval j = 1/9 {
use GIS_dta_files/1-Monthly_ID/OC140/pm14_`i'`zero'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year pm14
save GIS_dta_files/2-Monthly_Districts/OC140/pm14_`i'`j', replace
}
forval j = 10/12 {
use GIS_dta_files/1-Monthly_ID/OC140/pm14_`i'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year pm14
save GIS_dta_files/2-Monthly_Districts/OC140/pm14_`i'`j', replace
}
}

forval i = 1981/2020 {
use GIS_dta_files/2-Monthly_Districts/OC140/pm14_`i'1, clear
forval j = 2/12 {
append using GIS_dta_files/2-Monthly_Districts/OC140/pm14_`i'`j'
save GIS_dta_files/3-Appended/OC140/pm14_`i', replace
}
}

use GIS_dta_files/3-Appended/OC140/pm14_1981, clear
forval i = 1982/2020 {
append using GIS_dta_files/3-Appended/OC140/pm14_`i'
sort district year month
save pm14_MERRA_long_districts, replace
}

count
*  288,000

*===============================================================================


* II. OC160

cd "$your_path_here/5-Final_data_processing_in_Stata/PM"
forval i = 1981/2020 {
cd "$your_path_here/5-Final_data_processing_in_Stata/PM/GIS_data/OC160/`i'"
local myfilescsv : dir . files "*.csv"
foreach fn of local myfilescsv {
	import delimited "`fn'", clear
	
	keep id mean
	ren id ID
	ren mean pm16
	gen year = `i'
		
	local j = substr("`fn'",12,2)
	*gen str month = "`j'"
	gen month = "`j'"
	destring month, replace
	
	save "$your_path_here/5-Final_data_processing_in_Stata/PM/GIS_dta_files/1-Monthly_ID/OC160/pm16_`i'`j'", replace
}
}

cd "$your_path_here/5-Final_data_processing_in_Stata/PM"
forval i = 1981/2020 {
local zero = "0"

forval j = 1/9 {
use GIS_dta_files/1-Monthly_ID/OC160/pm16_`i'`zero'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year pm16
save GIS_dta_files/2-Monthly_Districts/OC160/pm16_`i'`j', replace
}
forval j = 10/12 {
use GIS_dta_files/1-Monthly_ID/OC160/pm16_`i'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year pm16
save GIS_dta_files/2-Monthly_Districts/OC160/pm16_`i'`j', replace
}
}

forval i = 1981/2020 {
use GIS_dta_files/2-Monthly_Districts/OC160/pm16_`i'1, clear
forval j = 2/12 {
append using GIS_dta_files/2-Monthly_Districts/OC160/pm16_`i'`j'
save GIS_dta_files/3-Appended/OC160/pm16_`i', replace
}
}

use GIS_dta_files/3-Appended/OC160/pm16_1981, clear
forval i = 1982/2020 {
append using GIS_dta_files/3-Appended/OC160/pm16_`i'
sort district year month
save pm16_MERRA_long_districts, replace
}

count
*  288,000

*===============================================================================


* III. OC180

cd "$your_path_here/5-Final_data_processing_in_Stata/PM"
forval i = 1981/2020 {
cd "$your_path_here/5-Final_data_processing_in_Stata/PM/GIS_data/OC180/`i'"
local myfilescsv : dir . files "*.csv"
foreach fn of local myfilescsv {
	import delimited "`fn'", clear
	
	keep id mean
	ren id ID
	ren mean pm18
	gen year = `i'
		
	local j = substr("`fn'",12,2)
	*gen str month = "`j'"
	gen month = "`j'"
	destring month, replace
	
	save "$your_path_here/5-Final_data_processing_in_Stata/PM/GIS_dta_files/1-Monthly_ID/OC180/pm18_`i'`j'", replace
}
}

cd "$your_path_here/5-Final_data_processing_in_Stata/PM"
forval i = 1981/2020 {
local zero = "0"

forval j = 1/9 {
use GIS_dta_files/1-Monthly_ID/OC180/pm18_`i'`zero'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year pm18
save GIS_dta_files/2-Monthly_Districts/OC180/pm18_`i'`j', replace
}
forval j = 10/12 {
use GIS_dta_files/1-Monthly_ID/OC180/pm18_`i'`j', clear
merge 1:1 ID using "$your_path_here/5-Final_data_processing_in_Stata/ID_Districts.dta"
drop ID _merge
ren District district
ren State state
order district state month year pm18
save GIS_dta_files/2-Monthly_Districts/OC180/pm18_`i'`j', replace
}
}

forval i = 1981/2020 {
use GIS_dta_files/2-Monthly_Districts/OC180/pm18_`i'1, clear
forval j = 2/12 {
append using GIS_dta_files/2-Monthly_Districts/OC180/pm18_`i'`j'
save GIS_dta_files/3-Appended/OC180/pm18_`i', replace
}
}

use GIS_dta_files/3-Appended/OC180/pm18_1981, clear
forval i = 1982/2020 {
append using GIS_dta_files/3-Appended/OC180/pm18_`i'
sort district year month
save pm18_MERRA_long_districts, replace
}

count
*  288,000

*===============================================================================



