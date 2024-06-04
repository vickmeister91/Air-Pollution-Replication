*************************************************************************************************************************
***************************** Code for Case Level Loocv plots (first stage visualisation) *******************************
*************************************************************************************************************************

** most_freq_coded_vals + d2v

* Case Level Data - 


clear



import delim "/Users/shashanksingh/Desktop/air_pollution/data/processed_data/case_data_final.csv", varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

keep if kanoon_id !=.

drop if district == ""
drop if district == "."
drop if district == " "
drop if district == "n.a"
drop if district == "-"
drop if district == "na"

sort district delivery_year


drop if delivery_year<1980

drop if delivery_year>2020

drop if delivery_year ==.

gen JudgeWoman=(gender_binary<1 & gender_binary ~= .)

gen JudgeGrad=((ed_llb>=0.5 & ed_llb~=.) | (ed_ba>=0.5 & ed_ba~=.) | (ed_bsc>=0.5 & ed_bsc~=.)| (ed_bcom>=0.5 & ed_bcom~=.))

gen JudgePostGrad=((ed_ma>=0.5 & ed_ma~=.) |  (ed_msc>=0.5 & ed_msc~=.) |  (ed_mcom>=0.5 & ed_mcom~=.) |  (ed_llm>=0.5 & ed_llm~=.)|  (ed_doc>=0.5 & ed_doc~=.))

encode district, generate(district_encoded)

collapse (firstnm)   mean_coded_vals most_freq_coded_vals JudgeWoman JudgePostGrad delivery_year govt_respondent is_appeal is_constitutional, by (kanoon_id district_encoded)


loocv reghdfe most_freq_coded_vals JudgeWoman JudgePostGrad , absorb(district_encoded delivery_year)

predict verdict_judges

loocv reghdfe most_freq_coded_vals govt_respondent is_appeal is_constitutional , absorb(district_encoded delivery_year)

predict verdict_case_chars

qui binscatter2 most_freq_coded_vals verdict_judges, absorb(district_encoded delivery_year) mcolors(red) lcolors(blue) xtitle("Predicted Values by Judges") ytitle("Median Coded Values") title("Case Level") savegraph(g1.gph) replace

qui binscatter2 verdict_case_chars verdict_judges, absorb(district_encoded delivery_year) mcolors(orange) lcolors(green) msymbols(triangle) xtitle("Predicted Values by Judges") ytitle("Predicted Values by Case Characteristics") title("Case Level") yscale(range(0.2 0.8)) ylabel(0.2 0.4 0.6 0.8) savegraph(g2.gph) replace 




***************************
* District-Year Level Data*
***************************

clear

import delim "/Users/shashanksingh/Desktop/air_pollution/data/processed_data/case_data_final.csv", varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

keep if kanoon_id !=.

drop if district == ""
drop if district == "."
drop if district == " "
drop if district == "n.a"
drop if district == "-"
drop if district == "na"


sort district delivery_year

drop if delivery_year<1980

drop if delivery_year>2020

drop if delivery_year ==.

gen JudgeWoman=(gender_binary<1 & gender_binary ~= .)

gen JudgeGrad=((ed_llb>=0.5 & ed_llb~=.) | (ed_ba>=0.5 & ed_ba~=.) | (ed_bsc>=0.5 & ed_bsc~=.)| (ed_bcom>=0.5 & ed_bcom~=.))

gen JudgePostGrad=((ed_ma>=0.5 & ed_ma~=.) |  (ed_msc>=0.5 & ed_msc~=.) |  (ed_mcom>=0.5 & ed_mcom~=.) |  (ed_llm>=0.5 & ed_llm~=.)|  (ed_doc>=0.5 & ed_doc~=.))

encode district, generate(district_encoded)

collapse (firstnm)   mean_coded_vals most_freq_coded_vals JudgeWoman JudgePostGrad delivery_year govt_respondent is_appeal is_constitutional, by (kanoon_id district_encoded)

* finally collapsing on district-year

collapse (mean)   mean_coded_vals most_freq_coded_vals JudgeWoman JudgePostGrad govt_respondent is_appeal is_constitutional, by (district_encoded delivery_year)

loocv reghdfe most_freq_coded_vals JudgeWoman JudgePostGrad , absorb(district_encoded delivery_year)

predict verdict_judges

loocv reghdfe most_freq_coded_vals govt_respondent is_appeal is_constitutional , absorb(district_encoded delivery_year)

predict verdict_case_chars

qui binscatter2 most_freq_coded_vals verdict_judges, absorb(district_encoded delivery_year) mcolors(red) lcolors(blue) xtitle("Predicted Values by Judges") ytitle("Median Coded Values") title("District Year Level") savegraph(g3.gph) replace


qui binscatter2 verdict_case_chars verdict_judges, absorb(district_encoded delivery_year) mcolors(orange) lcolors(green) msymbols(triangle) xtitle("Predicted Values by Judges") ytitle("Predicted Values by Case Characteristics") title("District Year Level") yscale(range(0.2 0.8)) ylabel(0.2 0.4 0.6 0.8) savegraph(g4.gph) replace 

graph combine g1.gph g2.gph g3.gph g4.gph, ycommon xcommon title("For Most Frequently Coded Values")


graph export "fig1_ap.pdf", replace



***********************************************************************************************************************************************************************************************



*************************************************************************************************************************
***************************** Code for Case Level Loocv plots (first stage visualisation) *******************************
*************************************************************************************************************************

** most_freq_coded_vals + d2v

* Case Level Data - 

cd "/Users/shashanksingh/Desktop/air_pollution/data/processed_data"

clear



import delim "/Users/shashanksingh/Desktop/water_pollution_final_folder/India_Pollution/01_Data/Analysis/processed_data/case_data_final.csv", varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

keep if kanoon_id !=.

drop if district == ""
drop if district == "."
drop if district == " "
drop if district == "n.a"
drop if district == "-"
drop if district == "na"

sort district delivery_year

gen most_freq_coded_vals2 = (most_freq_coded_vals>0)

drop most_freq_coded_vals

gen most_freq_coded_vals = most_freq_coded_vals2

drop most_freq_coded_vals2


drop if delivery_year<1980

drop if delivery_year>2020

drop if delivery_year ==.

gen JudgeWoman=(gender_binary<1 & gender_binary ~= .)

gen JudgeGrad=((ed_llb>=0.5 & ed_llb~=.) | (ed_ba>=0.5 & ed_ba~=.) | (ed_bsc>=0.5 & ed_bsc~=.)| (ed_bcom>=0.5 & ed_bcom~=.))

gen JudgePostGrad=((ed_ma>=0.5 & ed_ma~=.) |  (ed_msc>=0.5 & ed_msc~=.) |  (ed_mcom>=0.5 & ed_mcom~=.) |  (ed_llm>=0.5 & ed_llm~=.)|  (ed_doc>=0.5 & ed_doc~=.))

encode district, generate(district_encoded)

collapse (firstnm)   mean_coded_vals most_freq_coded_vals JudgeWoman JudgePostGrad delivery_year govt_respondent is_appeal is_constitutional, by (kanoon_id district_encoded)


loocv reghdfe most_freq_coded_vals JudgeWoman JudgePostGrad , absorb(district_encoded delivery_year)

predict verdict_judges

loocv reghdfe most_freq_coded_vals govt_respondent is_appeal is_constitutional , absorb(district_encoded delivery_year)

predict verdict_case_chars

qui binscatter2 most_freq_coded_vals verdict_judges, absorb(district_encoded delivery_year) mcolors(red) lcolors(blue) xtitle("Predicted Values by Judges") ytitle("Median Coded Values") title("Case Level") savegraph(gw1.gph) replace

qui binscatter2 verdict_case_chars verdict_judges, absorb(district_encoded delivery_year) mcolors(orange) lcolors(green) msymbols(triangle) xtitle("Predicted Values by Judges") ytitle("Predicted Values by Case Characteristics") title("Case Level") yscale(range(0.2 0.8)) ylabel(0.2 0.4 0.6 0.8) savegraph(gw2.gph) replace 




***************************
* District-Year Level Data*
***************************

clear

import delim "/Users/shashanksingh/Desktop/water_pollution_final_folder/India_Pollution/01_Data/Analysis/processed_data/case_data_final.csv", varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

keep if kanoon_id !=.

drop if district == ""
drop if district == "."
drop if district == " "
drop if district == "n.a"
drop if district == "-"
drop if district == "na"


sort district delivery_year

gen most_freq_coded_vals2 = (most_freq_coded_vals>0)

drop most_freq_coded_vals

gen most_freq_coded_vals = most_freq_coded_vals2

drop most_freq_coded_vals2

drop if delivery_year<1980

drop if delivery_year>2020

drop if delivery_year ==.

gen JudgeWoman=(gender_binary<1 & gender_binary ~= .)

gen JudgeGrad=((ed_llb>=0.5 & ed_llb~=.) | (ed_ba>=0.5 & ed_ba~=.) | (ed_bsc>=0.5 & ed_bsc~=.)| (ed_bcom>=0.5 & ed_bcom~=.))

gen JudgePostGrad=((ed_ma>=0.5 & ed_ma~=.) |  (ed_msc>=0.5 & ed_msc~=.) |  (ed_mcom>=0.5 & ed_mcom~=.) |  (ed_llm>=0.5 & ed_llm~=.)|  (ed_doc>=0.5 & ed_doc~=.))

encode district, generate(district_encoded)

collapse (firstnm)   mean_coded_vals most_freq_coded_vals JudgeWoman JudgePostGrad delivery_year govt_respondent is_appeal is_constitutional, by (kanoon_id district_encoded)

* finally collapsing on district-year

collapse (mean)   mean_coded_vals most_freq_coded_vals JudgeWoman JudgePostGrad govt_respondent is_appeal is_constitutional, by (district_encoded delivery_year)

loocv reghdfe most_freq_coded_vals JudgeWoman JudgePostGrad , absorb(district_encoded delivery_year)

predict verdict_judges

loocv reghdfe most_freq_coded_vals govt_respondent is_appeal is_constitutional , absorb(district_encoded delivery_year)

predict verdict_case_chars

qui binscatter2 most_freq_coded_vals verdict_judges, absorb(district_encoded delivery_year) mcolors(red) lcolors(blue) xtitle("Predicted Values by Judges") ytitle("Median Coded Values") title("District Year Level") savegraph(gw3.gph) replace


qui binscatter2 verdict_case_chars verdict_judges, absorb(district_encoded delivery_year) mcolors(orange) lcolors(green) msymbols(triangle) xtitle("Predicted Values by Judges") ytitle("Predicted Values by Case Characteristics") title("District Year Level") yscale(range(0.2 0.8)) ylabel(0.2 0.4 0.6 0.8) savegraph(gw4.gph) replace 

graph combine gw1.gph gw2.gph gw3.gph gw4.gph, ycommon xcommon title("For Most Frequently Coded Values")


graph export "fig1_wp.pdf", replace


