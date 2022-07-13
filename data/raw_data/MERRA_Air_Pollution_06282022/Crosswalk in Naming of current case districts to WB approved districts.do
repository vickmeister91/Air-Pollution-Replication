
* CORRECTING DISTRICT_STATE NAMING
* to be consistent with the districts from the WB approved map of districts


cd "/...your path.../"
use district_state_sample_corrected.dta, clear
sort district year

replace district = "Rangareddi" if district == "Ranga Reddy" & state == "Andhra Pradesh"
replace district = "Vishakhapatnam" if district == "Visakhapatnam" & state == "Andhra Pradesh"
replace district = "Purba Champaran" if district == "East Champaran" & state == "Bihar"
replace district = "Bhabua" if district == "Kaimur" & state == "Bihar"
replace district = "Raj Nandgaon" if district == "Rajnandgaon" & state == "Chhattisgarh"
replace district = "Ahmadabad" if district == "Ahmedabad" & state == "Gujarat"
replace district = "Kachchh" if district == "Kutch" & state == "Gujarat"
replace district = "Panch Mahals" if district == "Panchmahal" & state == "Gujarat"
replace district = "Sonepat" if district == "Sonipat" & state == "Haryana"
replace district = "Purba Singhbhum" if district == "East Singhbhum" & state == "Jharkhand"
replace district = "Pashchim Singhbhum" if district == "West Singhbhum" & state == "Jharkhand"
replace district = "Saraikela Kharsawan" if district == "Seraikela Kharsawan" & state == "Jharkhand"
replace district = "Bellary" if district == "Ballari" & state == "Karnataka"
replace district = "Chamrajnagar" if district == "Chamarajanagar" & state == "Karnataka"
replace district = "Dakshin Kannad" if district == "Dakshin Kannada" & state == "Karnataka"
replace district = "Uttar Kannand" if district == "Uttara Kannada" & state == "Karnataka"
replace district = "Pattanamtitta" if district == "Pathanamthitta" & state == "Kerala"
replace district = "Garhchiroli" if district == "Gadchiroli" & state == "Maharashtra"
replace district = "Mumbai city" if district == "Mumbai City" & state == "Maharashtra"
replace district = "Raigarh" if district == "Raigad" & state == "Maharashtra"
replace district = "Ri-Bhoi" if district == "Ri Bhoi" & state == "Meghalaya"
replace state = "Orissa" if state == "Odisha"
replace district = "Angul" if district == "Anugul" & state == "Orissa"
replace district = "Bolangir" if district == "Balangir" & state == "Orissa"
replace district = "Baleshwar" if district == "Balasore" & state == "Orissa"
replace district = "Keonjhar" if district == "Kendujhar" & state == "Orissa"
replace district = "Sonepur" if district == "Sonapur" & state == "Orissa"
replace district = "Puducherry" if district == "Pondicherry" & state == "Puducherry"
replace district = "Nawan Shehar" if district == "Nawanshahr" & state == "Punjab"
replace district = "Chittaurgarh" if district == "Chittorgarh" & state == "Rajasthan"
replace district = "Dhaulpur" if district == "Dholpur" & state == "Rajasthan"
replace district = "Kancheepuram" if district == "Kanchipuram" & state == "Tamil Nadu"
replace district = "Kanniyakumari" if district == "Kanyakumari" & state == "Tamil Nadu"
replace district = "Thoothukudi" if district == "Thoothukkudi" & state == "Tamil Nadu"
replace district = "Tiruchchirappalli" if district == "Tiruchirappalli" & state == "Tamil Nadu"
replace district = "Tirunelveli Kattabo" if district == "Tirunelveli" & state == "Tamil Nadu"
replace district = "Villupuram" if district == "Viluppuram" & state == "Tamil Nadu"
replace district = "Baghpat" if district == "Bagpat" & state == "Uttar Pradesh"
replace district = "Sant Ravi Das Nagar" if district == "Bhadohi" & state == "Uttar Pradesh"
replace district = "Badaun" if district == "Budaun" & state == "Uttar Pradesh"
replace district = "Rae Bareli" if district == "Raebareli" & state == "Uttar Pradesh"
replace district = "Siddharth Nagar" if district == "Siddharthnagar" & state == "Uttar Pradesh"
replace district = "Dehra Dun" if district == "Dehradun" & state == "Uttarakhand"
replace district = "Haridwar" if district == "Hardwar" & state == "Uttarakhand"
replace district = "Naini Tal" if district == "Nainital" & state == "Uttarakhand"
replace district = "Haora" if district == "Howrah" & state == "West Bengal"
replace district = "West Midnapore" if district == "Paschim Medinipur" & state == "West Bengal"
replace district = "East Midnapore" if district == "Purba Medinipur" & state == "West Bengal"

save district_state_sample_corrected_WB_Naming.dta, replace

/* 
after merging with any of (pm14, pm16, pm18, so2, bc, du, oc14, oc16, oc18, so4, ss)_MERRA_long_WB_Naming,
the result of 

merge m:m district state year using *_MERRA_long_WB_Naming

will be 

    Result                           # of obs.
    -----------------------------------------
    not matched                       266,820
        from master                         0  (_merge==1)
        from using                    266,820  (_merge==2)

    matched                            10,427  (_merge==3)
    -----------------------------------------
*/

