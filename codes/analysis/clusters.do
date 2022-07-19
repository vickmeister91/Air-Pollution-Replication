********************************************************************************
* Export Pollution Clusters
********************************************************************************

* global Data /Users/shashanksingh/Desktop/github/india_air_pollution/data

clear all


* Load Data
import delimited "$Data/processed_data/yearly_air.csv", varnames(1) case(lower) bindquote(strict) maxquotedrows(200) clear 

* Only keep relevant variables



keep state_x district_x year kanoon_id




* "Big Pond" clusters
* All districts, which are connected via some cases,
* are assigned the same cluster


** Create the Clusters **
 
egen cluster_bp = group(district_x year)
group_id cluster_bp, match(kanoon_id)



* Small Pond Clusters:
* Only district-years, which have exactely the same cases


* create district_year group
egen dy_group = group(district_x year)

by dy_group, sort: gen kanoonN = sum(kanoon_id != .) 
by dy_group, sort: replace kanoonN = kanoonN[_N]


* Important to group as well by kanoon_id for later grouping
sort dy_group kanoon_id

* Create count of kanoon_ids
by dy_group, sort: gen countkanoon = _n


** Reshape to wide (by kanoon_id*) **

drop state_x
reshape wide kanoon_id, i(dy_group) j(countkanoon)


** Create the Clusters **

* Create variable which runs if no kanoon id in district_year, otherwise 0
* (To distinguish differetn dsitrict-years without cases)
gen kanoon_idN = 0 if kanoonN > 0
replace kanoon_idN = _n if kanoon_idN == .

* Group by all kanoon_id1 to kanoon_id13 and kanoon_idN
egen cluster_sp = group(kanoon_id*), missing

keep district_x year cluster_bp cluster_sp

sort district_x year

save "$Data/processed_data/yearly_air_clusters.dta", replace
