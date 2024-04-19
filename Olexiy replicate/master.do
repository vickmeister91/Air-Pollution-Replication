
global your_path_here "C:/Users/vickm/Downloads"
cd "$your_path_here/5-Final_data_processing_in_Stata/olexiy replicate"
do bc_gis_to_dta.do
do du_gis_to_dta.do
do oc_gis_to_dta.do
do PM_gis_to_dta.do
do so2_gis_to_dta.do
do so4_gis_to_dta.do
do ss_gis_to_dta.do
do merging_all_files_together.do

