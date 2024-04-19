
* Finalizing BC Computation

cd "$your_path_here/5-Final_data_processing_in_Stata/BC"
// mkdir "GIS_dta_files"
// mkdir "GIS_dta_files/1-Monthly_ID"
// mkdir "GIS_dta_files/2-Monthly_Districts"
// mkdir "GIS_dta_files/3-Appended"


* Ensure the global path is set
* Loop over years
forval i = 1981/2020 {
    * Display current year being processed
    display "Processing year `i'"

    * Change directory, check for errors
    capture cd "$your_path_here/5-Final_data_processing_in_Stata/BC/GIS_data/`i'"
    if _rc {
        display "Error: Unable to change directory to $your_path_here/5-Final_data_processing_in_Stata/BC/GIS_data/`i'"
        continue  // Skip to next iteration of the loop
    }

    * List all CSV files in the directory
    local myfilescsv : dir . files "*.csv"
    if `"`myfilescsv'"' == "" {
        display "No CSV files found for year `i'."
        continue  // Skip to next iteration of the loop
    }

    * Process each file found
    foreach fn of local myfilescsv {
        display "Processing file `fn'"

        * Import file, check for errors
        capture import delimited "`fn'", clear
        if _rc {
            display "Error: Failed to import `fn'"
            continue  // Skip to the next file
        }

        * Data cleaning
        capture keep id mean
        if _rc {
            display "Error: Required variables 'id' or 'mean' not found in `fn'"
            continue  // Skip to the next file
        }
        
        capture ren id ID
        capture ren mean bc
        if _rc {
            display "Error: Renaming variables in `fn'"
            continue  // Skip to the next file
        }

        gen year = `i'
        
        * Extract month from filename and generate month variable
        local j = substr("`fn'",12,2)
        gen month = "`j'"
        capture destring month, replace
        if _rc {
            display "Error: Destrining month in `fn'"
            continue  // Skip to the next file
        }

        * Save the processed file, check for errors
        capture save "$your_path_here/5-Final_data_processing_in_Stata/BC/GIS_dta_files/1-Monthly_ID/bc`i'`j'.dta", replace
        if _rc {
            display "Error: Unable to save `fn' as bc`i'`j'.dta"
        }
    }
}

* Check if directory exists and create it if it does not
cd "$your_path_here/5-Final_data_processing_in_Stata/BC/GIS_dta_files/1-Monthly_ID"
use "bc198101",clear



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
