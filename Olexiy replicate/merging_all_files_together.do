
* Merging polluter-wise dataset into one air pollution dataset

cd "$your_path_here/5-Final_data_processing_in_Stata"

use BC/bc_MERRA_long_districts.dta, clear
merge 1:1 district state month year using DU/du_MERRA_long_districts.dta
drop _merge
merge 1:1 district state month year using OC/oc14_MERRA_long_districts.dta
drop _merge
merge 1:1 district state month year using OC/oc16_MERRA_long_districts.dta
drop _merge
merge 1:1 district state month year using OC/oc18_MERRA_long_districts.dta
drop _merge
merge 1:1 district state month year using PM/pm14_MERRA_long_districts.dta
drop _merge
merge 1:1 district state month year using PM/pm16_MERRA_long_districts.dta
drop _merge
merge 1:1 district state month year using PM/pm18_MERRA_long_districts.dta
drop _merge
merge 1:1 district state month year using SO2/so2_MERRA_long_districts.dta
drop _merge
merge 1:1 district state month year using SO4/so4_MERRA_long_districts.dta
drop _merge
merge 1:1 district state month year using SS/ss_MERRA_long_districts.dta
drop _merge

save air_pollution_olexiy_combined.dta, replace
export delimited using air_pollution_olexiy_combined.csv", replace

cd "$your_path_here"
export delimited using air_pollution_olexiy_combined.csv", replace














