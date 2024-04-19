import delimited "air_pollution_olexiy_combined.csv",clear
rename month case_mon
rename year case_yr

save pollution.dta, replace

import delimited "final_merged_air_pollution_cases_compact.csv",clear


*-------------------------------------------------------------------------------
***** Incorporating Olexiy's string cleaning code ********
/* 
I. cleaning state names => correcting them so they match the state names in the 
shapefile used to create air pollustion datset. Please see the list in Excel file 
List_locations_Viknesh_15012024, tab Our locations
*/
replace state = "Andhra Pradesh" if state == "andhra pradesh"
replace state = "Arunachal Pradesh" if state == "arunachal pradesh"
replace state = "Assam" if state == "assam"
replace state = "West Bengal" if state == "bengal"
replace state = "Bihar" if state == "bihar"
replace state = "Chandigarh" if state == "chandigarh"
replace state = "Chhattisgarh" if state == "chhattisgarh"
replace state = "Daman and Diu" if state == "daman and diu"
replace state = "Goa" if state == "goa"
replace state = "Gujarat" if state == "gujarat"
replace state = "Haryana" if state == "haryana"
replace state = "Himachal Pradesh" if state == "himachal pradesh"
replace state = "Jammu and Kashmir" if state == "jammu & kashmir"
replace state = "Jammu and Kashmir" if state == "jammu and kashmir"
replace state = "Jharkhand" if state == "jharkhand"
replace state = "Karnataka" if state == "karnataka"
replace state = "Kerala" if state == "kerala"
replace state = "Madhya Pradesh" if state == "madhya pradesh"
replace state = "Maharashtra" if state == "maharashtra"
replace state = "Manipur" if state == "manipur"
replace state = "Meghalaya" if state == "meghalaya"
replace state = "Mizoram" if state == "mizoram"
replace state = "Delhi" if state == "new delhi"
replace state = "Orissa" if state == "odisha"
replace state = "Bihar" if state == "patna"
replace state = "Puducherry" if state == "puducherry"
replace state = "Punjab" if state == "punjab"
replace state = "Rajasthan" if state == "rajasthan"
replace state = "Tamil Nadu" if state == "tamil nadu"
replace state = "Andhra Pradesh" if state == "telangana"
replace state = "Tripura" if state == "tripura"
replace state = "Uttar Pradesh" if state == "uttar pradesh"
replace state = "Uttarakhand" if state == "uttarakhand"
replace state = "Uttarakhand" if state == "uttaranchal"
replace state = "West Bengal" if state == "west bengal"

*-------------------------------------------------------------------------------

/* 
II. cleaning district names  => correcting them so they match the district names in the 
shapefile used to create air pollustion datset. the justification for corrections presented here can be
seen in more details in Excel file List_locations_Viknesh_15012024, tab Cleaning districts
*/
replace district = "Chennai" if district == "chennai"
replace district = "Devnagere" if district == "devnagere"
replace district = "Dharamshala" if district == "dharamshala"
replace district = "Gauhati" if district == "gauhati"
replace district = "Godhra" if district == "godhra"
replace district = "Guwahati" if district == "guwahati"
replace district = "Moh" if district == "moh"
replace district = "N.aa" if district == "n.aa"
replace district = "Nellore" if district == "nellore"
replace district = "Noamundi" if district == "noamundi"
replace district = "Sihora" if district == "sihora"
replace district = "Ganganagar" if district == "sri ganganagar"
replace district = "Ganganagar" if district == "sriganganagar"
replace district = "Tumkur" if district == "tumkur"

replace district = "Ahmadabad" if district == "Ahmedabad"
replace district = "Ahmadabad" if district == "Ahmedabad (Rural)"
replace district = "Allahabad" if district == "Allahabad District"
replace district = "Vishakhapatnam" if district == "Anakapalli"
replace district = "Anuppur" if district == "Annuppur"
replace district = "Sabar Kantha" if district == "Aravalli"
replace district = "Ashoknagar" if district == "Ashok Nagar"
replace district = "Adilabad" if district == "Asifabad"
replace district = "Belgaum" if district == "BELAGAVI"
replace district = "Bangalore" if district == "BENGALURU"
replace district = "Mumbai city" if district == "BOMBAY"
replace district = "Bolangir" if district == "Balangir"
replace district = "Baleshwar" if district == "Balasore"
replace district = "Bellary" if district == "Ballari"
replace district = "Raipur" if district == "Baloda Bazar"
replace district = "Raipur" if district == "Baloda Bazar - Bhatapara"
replace district = "Banas Kantha" if district == "Banaskantha"
replace district = "Bangalore Rural" if district == "Bangalore Rural District"
replace district = "Bangalore Urban" if district == "Bangalore urban"
replace district = "Bara Banki" if district == "Barabanki"
replace district = "Baramula" if district == "Baramulla"
replace district = "Baragarh" if district == "Bargarh"
replace district = "Bellary" if district == "Bellari"
replace district = "Bangalore" if district == "Bengaluru"
replace district = "Bangalore Urban" if district == "Bengaluru Urban"
replace district = "Bhopal" if district == "Bhopal District"
replace district = "Khordha" if district == "Bhubaneshwar"
replace district = "Khordha" if district == "Bhubeneshwar"
replace district = "Mumbai city" if district == "Bombay"
replace district = "Mumbai Suburban" if district == "Bombay Suburban District"
replace district = "Badaun" if district == "Budaun"
replace district = "South 24 Parganas" if district == "Budge Budge"
replace district = "Bulandshahr" if district == "Bulandshahar"
replace district = "Kolkata" if district == "Calcutta"
replace district = "Delhi" if district == "Central Delhi"
replace district = "Delhi" if district == "Central District"
replace district = "Chamrajnagar" if district == "Chamarajanagar"
replace district = "Chamrajnagar" if district == "Chamarajanagara"
replace district = "Chamrajnagar" if district == "Chamarajnagar"
replace district = "Janjgir-Champa" if district == "Champa"
replace district = "Kancheepuram" if district == "Chengalpattu"
replace district = "Kancheepuram" if district == "Chengalpet"
replace district = "Chennai" if district == "Chennai District"
replace district = "Vadodara" if district == "Chhota Udepur"
replace district = "Vadodara" if district == "Chhota-Udepur"
replace district = "Vadodara" if district == "Chhotaudepur"
replace district = "Chikmagalur" if district == "Chickmagalur"
replace district = "Kolar" if district == "Chikkaballapura"
replace district = "Chikmagalur" if district == "Chikkamagalur"
replace district = "Chikmagalur" if district == "Chikkamagaluru"
replace district = "Chittaurgarh" if district == "Chittorgarh"
replace district = "Coimbatore" if district == "Coimbatore District"
replace district = "Cuddalore" if district == "Cuddalore District"
replace district = "Dakshin Kannad" if district == "Dakshina Kannada"
replace district = "Davanagere" if district == "Davangere"
replace district = "Dehra Dun" if district == "Dehradun"
replace district = "Dehra Dun" if district == "Dehradun District"
replace district = "Davanagere" if district == "Devnagere"
replace district = "Dhaulpur" if district == "Dholpur"
replace district = "Godda" if district == "Dighi"
replace district = "Dindigul" if district == "Dindigul District"
replace district = "Purba Champaran" if district == "East Champaran"
replace district = "Delhi" if district == "East Delhi"
replace district = "Delhi" if district == "East Delhi District"
replace district = "East Godavari" if district == "East Godavari District"
replace district = "Purba Singhbhum" if district == "East Singhbhum"
replace district = "Erode" if district == "Erode District"
replace district = "Firozpur" if district == "Fazilka"
replace district = "Firozabad" if district == "Ferozabad"
replace district = "Firozpur" if district == "Ferozepore"
replace district = "Garhchiroli" if district == "Gadchiroli"
replace district = "Gandhinagar" if district == "Gandhi Nagar"
replace district = "Raipur" if district == "Gariyaband"
replace district = "Kamrup Metropolitan" if district == "Gauhati"
replace district = "Gautam Buddha Nagar" if district == "Gautam Budh Nagar"
replace district = "Junagadh" if district == "Gir Somnath"
replace district = "Junagadh" if district == "Gir-Somnath"
replace district = "Panch Mahals" if district == "Godhra"
replace district = "Gurgaon" if district == "Gurugram"
replace district = "Kamrup Metropolitan" if district == "Guwahati"
replace district = "Gwalior" if district == "Gwalior District"
replace district = "Ghaziabad" if district == "Hapur"
replace district = "Aurangabad" if district == "Haspura"
replace district = "Hazaribag" if district == "Hazaribagh"
replace district = "Hugli" if district == "Hooghly"
replace district = "Haora" if district == "Howrah"
replace district = "Indore" if district == "Indore District"
replace district = "Papum Pare" if district == "Itanagar"
replace district = "Jamui" if district == "JAMUI"
replace district = "Jaipur" if district == "Jaipur District"
replace district = "Jalor" if district == "Jalore"
replace district = "Jhunjhunun" if district == "Jhunjhunu"
replace district = "Jodhpur" if district == "Jodhpur District"
replace district = "Jalandhar" if district == "Jullundur"
replace district = "Kabirdham" if district == "Kabeerdham"
replace district = "Cuddapah" if district == "Kadapa District"
replace district = "Gulbarga" if district == "Kalaburagi"
replace district = "Kancheepuram" if district == "Kancheepuram District"
replace district = "Kancheepuram" if district == "Kanchipuram"
replace district = "Kanpur Nagar" if district == "Kanpur"
replace district = "Kanpur Nagar" if district == "Kanpur Nagar district"
replace district = "Kanniyakumari" if district == "Kanyakumari"
replace district = "Kanniyakumari" if district == "Kanyakumari District"
replace district = "Rohtas" if district == "Kargahar"
replace district = "Karur" if district == "Karur District"
replace district = "Kasaragod" if district == "Kasargod"
replace district = "Keonjhar" if district == "Kendujhar"
replace district = "Keonjhar" if district == "Kendujhar (Keonjhar)"
replace district = "Indore" if district == "Khajrana"
replace district = "East Nimar" if district == "Khandwa"
replace district = "West Midnapore" if district == "Kharagpur"
replace district = "West Nimar" if district == "Khargone"
replace district = "West Nimar" if district == "Khargone (West Nimar)"
replace district = "Lakhimpur Kheri" if district == "Kheri"
replace district = "Lakhimpur Kheri" if district == "Khiri"
replace district = "Ranchi" if district == "Khunti"
replace district = "Khordha" if district == "Khurda"
replace district = "Ernakulam" if district == "Kochi"
replace district = "Dindigul" if district == "Kodaikanal"
replace district = "Kolkata" if district == "Kolkata District"
replace district = "Koriya" if district == "Korea"
replace district = "Kozhikode" if district == "Kozhikkode"
replace district = "Dharmapuri" if district == "Krishnagiri"
replace district = "Kushinagar" if district == "Kushi Nagar"
replace district = "Kachchh" if district == "Kutch"
replace district = "Madurai" if district == "Madurai District"
replace district = "Mandya" if district == "Mandya District"
replace district = "Palakkad" if district == "Mannarkkad"
replace district = "Alappuzha" if district == "Mavelikkara"
replace district = "Nagapattinam" if district == "Mayiladuthurai"
replace district = "Mahesana" if district == "Mehsana"
replace district = "Salem" if district == "Mettur"
replace district = "Rajkot" if district == "Morbi"
replace district = "Mumbai city" if district == "Mumbai"
replace district = "Mumbai city" if district == "Mumbai City"
replace district = "Mumbai Suburban" if district == "Mumbai Suburban District"
replace district = "Mumbai Suburban" if district == "Mumbai suburban"
replace district = "Bilaspur" if district == "Mungeli"
replace district = "Muzaffarnagar" if district == "Muzzafar Nagar"
replace district = "Mysore" if district == "Mysuru"
replace district = "Nagapattinam" if district == "Nagapattinam District"
replace district = "Naini Tal" if district == "Nainital"
replace district = "Nalgonda" if district == "Nalgonda District"
replace district = "Namakkal" if district == "Namakkal District"
replace district = "Nawan Shehar" if district == "Nawanshahr"
replace district = "Nellore" if district == "Nellore District"
replace district = "Delhi" if district == "New Delhi"
replace district = "Pashchim Singhbhum" if district == "Noamundi"
replace district = "Gautam Buddha Nagar" if district == "Noida"
replace district = "Vellore" if district == "North Arcot"
replace district = "Delhi" if district == "North Delhi"
replace district = "Raisen" if district == "Obedullagan"
replace district = "Patna" if district == "PATNA"
replace district = "Thane" if district == "Palghar"
replace district = "Palakkad" if district == "Palghat"
replace district = "Pali" if district == "Pali Marwar"
replace district = "Panch Mahals" if district == "Panchmahal"
replace district = "Barddhaman" if district == "Paschim Bardhaman"
replace district = "West Midnapore" if district == "Paschim Medinipur"
replace district = "Pattanamtitta" if district == "Pathanamthitta"
replace district = "Gurdaspur" if district == "Pathankot"
replace district = "Patiala" if district == "Patiala District"
replace district = "Pauri Garhwal" if district == "Pauri"
replace district = "Kozhikode" if district == "Payyoli"
replace district = "Puducherry" if district == "Pondicherry"
replace district = "Allahabad" if district == "Prayagraj"
replace district = "Pudukkottai" if district == "Pudukottai"
replace district = "Pudukkottai" if district == "Pudukottai District"
replace district = "Pune" if district == "Pune (Gramin)"
replace district = "Pune" if district == "Pune District"
replace district = "Barddhaman" if district == "Purba Bardhaman district"
replace district = "Rae Bareli" if district == "Raebareli"
replace district = "Raigarh" if district == "Raigad"
replace district = "Raigarh" if district == "Raigad District"
replace district = "Bangalore Rural" if district == "Ramanagara"
replace district = "Hazaribag" if district == "Ramgarh"
replace district = "Rangareddi" if district == "Ranga Reddy"
replace district = "Rangareddi" if district == "Ranga Reddy District"
replace district = "Ri-Bhoi" if district == "Ri Bhoi District"
replace district = "Rupnagar" if district == "Ropar"
replace district = "Samastipur" if district == "SAMASTIPUR"
replace district = "Nellore" if district == "SPSR Nellore District"
replace district = "Sabar Kantha" if district == "Sabarkantha"
replace district = "Medak" if district == "Sangareddy"
replace district = "Sawai Madhopur" if district == "Sawaimadhopur"
replace district = "Seoni" if district == "Seoni District"
replace district = "Saraikela Kharsawan" if district == "Seraikela Kharsawan"
replace district = "Delhi" if district == "Shahdara"
replace district = "Delhi" if district == "Shahdara District"
replace district = "Nawan Shehar" if district == "Shaheed Bhagat Singh Nagar"
replace district = "Sidhi" if district == "Sidhi District"
replace district = "Jabalpur" if district == "Sihora"
replace district = "Sidhi" if district == "Singrauli"
replace district = "Sidhi" if district == "Singrouli"
replace district = "Sivaganga" if district == "Sivagangai"
replace district = "Sivaganga" if district == "Sivagangai District"
replace district = "Andaman Islands" if district == "South Andaman"
replace district = "Delhi" if district == "South Delhi"
replace district = "Delhi" if district == "South East District"
replace district = "Delhi" if district == "South West Delhi"
replace district = "Delhi" if district == "South West District"
replace district = "Ganganagar" if district == "Sri Ganganagar"
replace district = "Ganganagar" if district == "Sriganganagar"
replace district = "Ganganagar" if district == "Srigangangar"
replace district = "Surat" if district == "Surat Rural"
replace district = "Angul" if district == "Talcher"
replace district = "Surat" if district == "Tapi"
replace district = "Nilgiris" if district == "The Nilgiris"
replace district = "Theni" if district == "Theni District"
replace district = "Thiruvallur" if district == "Thiruvallur District"
replace district = "Tiruvannamalai" if district == "Thiruvannamalai"
replace district = "Thoothukudi" if district == "Thoothukudi District"
replace district = "Thrissur" if district == "Thrissur District"
replace district = "Tiruchchirappalli" if district == "Tiruchirappalli"
replace district = "Tirunelveli Kattabo" if district == "Tirunelveli"
replace district = "Tirunelveli Kattabo" if district == "Tirunelveli District"
replace district = "Thiruvallur" if district == "Tiruvallur"
replace district = "Thiruvallur" if district == "Tiruvallur District"
replace district = "Tiruvannamalai" if district == "Tiruvannamalai District"
replace district = "Thiruvarur" if district == "Tiruvarur"
replace district = "Tiruchchirappalli" if district == "Tiruverumbur"
replace district = "Tiruchchirappalli" if district == "Trichinopoly"
replace district = "Tiruchchirappalli" if district == "Trichirappalli"
replace district = "Thrissur" if district == "Trichur"
replace district = "Tiruchchirappalli" if district == "Trichy"
replace district = "Thoothukudi" if district == "Tuticorin"
replace district = "Udaipur" if district == "Udaipur District"
replace district = "Umaria" if district == "Umariya"
replace district = "Uttar Kannand" if district == "Uttara Kannada"
replace district = "Vellore" if district == "Vellore District"
replace district = "Villupuram" if district == "Villupuram District"
replace district = "Villupuram" if district == "Viluppuram"
replace district = "Vishakhapatnam" if district == "Visakhapatnam"
replace district = "Warangal" if district == "Warangal Rural"
replace district = "Pashchim Champaran" if district == "West Champaran"
replace district = "Delhi" if district == "West Delhi"
replace district = "Pashchim Singhbhum" if district == "West Singhbhum"
replace district = "Cuddapah" if district == "Y.S.R. Kadapa District"
replace district = "Cuddapah" if district == "YSR District"
replace district = "Gulbarga" if district == "Yadgir"

/*
III. going case by case to identify as many locations as possible.  
For more details please see 3 corresponding tabs in the Excel file: 
NOT merged cases, Not matchd NAs unique districts, and Remaining locations
*/

* correcting the cases with the largest number of observations
replace state = "Chandigarh" if state == "punjab and haryana" & district == "Ambala" & city == "Chandigarh"
replace state = "Chandigarh" if state == "Punjab" & district == "Ambala" & city == "Chandigarh"
replace district = "Chandigarh" if state == "Chandigarh" & district == "Ambala" & city == "Chandigarh"

replace state = "Andaman and Nicobar" if state == "NA" & district == "Andaman Islands" & city == "Port Blair"

replace district = "Bangalore Urban" if state == "Karnataka" & district == "Bangalore" & city == "Bangalore"
replace district = "Bangalore Urban" if state == "Karnataka" & district == "Bangalore" & city == "Bengaluru"
replace district = "Bangalore Urban" if state == "Karnataka" & district == "Bangalore" & city == "Tumakuru"
replace district = "Bangalore Urban" if state == "Karnataka" & district == "Bangalore" & city == "Kadugodi, Mysore"
replace district = "Bangalore Urban" if state == "Karnataka" & district == "Bangalore" & city == "NA"

replace state = "Chandigarh" if state == "Punjab" & district == "Chandigarh" & city == "NA"
replace state = "Chandigarh" if state == "Punjab" & district == "Chandigarh" & city == "Chandigarh"
replace state = "Chandigarh" if state == "Chhattisgarh" & district == "Chandigarh" & city == "NA"
replace state = "Chandigarh" if state == "Haryana" & district == "Chandigarh" & city == "NA"
replace state = "Chandigarh" if state == "NA" & district == "Chandigarh" & city == "NA"
replace state = "Chandigarh" if state == "punjab and haryana" & district == "Chandigarh" & city == "NA"
replace state = "Chandigarh" if state == "punjab and haryana" & district == "Chandigarh" & city == "Chandigarh"
replace district = "Chandigarh" if state == "Chandigarh" & district == "NA" & city == "NA"
replace state = "Haryana" if state == "Chandigarh" & district == "Panchkula" & city == "Gurgaon"

replace state = "Delhi" if state == "NA" & district == "Delhi" & city == "NA"
replace state = "Delhi" if state == "NA" & district == "Delhi" & city == "Hari Nagar"
replace state = "Delhi" if state == "NA" & district == "Delhi" & city == "Connaught Place"
replace state = "Delhi" if state == "NA" & district == "Delhi" & city == "Tis Hazari"
replace state = "Delhi" if state == "Kerala" & district == "Delhi" & city == "Delhi"
replace state = "Delhi" if state == "Gujarat" & district == "Delhi" & city == "NA"
replace state = "Delhi" if state == "Haryana" & district == "Delhi" & city == "New Delhi"
replace state = "Delhi" if state == "NA" & district == "Delhi" & city == "Karkardooma"
replace state = "Delhi" if state == "NA" & district == "Delhi" & city == "Saket"

replace district = "Delhi" if state == "Delhi" & city == "NA"
replace district = "Delhi" if state == "Delhi" & district == "NIL" & city == "Delhi" 
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Karkardooma" 
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Delhi, New Delhi" 
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "NA" 
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Delhi, Ludhiana" 

replace state = "Gujarat" if state == "Delhi" & district == "NA" & city == "Dwarka Courts"
replace district = "Jamnagar" if state == "Gujarat" & district == "NA" & city == "Dwarka Courts" 

tab district if state == "Goa"
/*
                               district |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                     NA |         16       84.21       84.21
                              North Goa |          3       15.79      100.00
----------------------------------------+-----------------------------------
                                  Total |         19      100.00

I hope we can do this. Out of the identified cases, all 3 were from North Goa. 
Can we replace districts in 16 unmerged cases in Goa by North Goa?
*/
replace district = "North Goa" if state == "Goa" & district == "NA" & city == "NA" 
* (16 real changes made)

replace district = "Ahmadabad" if state == "Gujarat" & district == "NA" & city == "Nalsarovar (West) Range" 
replace district = "Kachchh" if state == "Gujarat" & district == "NA" & city == "Samakhiyali" 
replace district = "Panch Mahals" if state == "Gujarat" & district == "NA" & city == "Shehra" 

replace state = "Uttar Pradesh" if state == "NA" & district == "Lakhimpur Kheri" & city == "NA"

replace district = "Coimbatore" if state == "Tamil Nadu" & district == "Tiruppur" & city == "Tirupur" 
replace district = "Coimbatore" if state == "Tamil Nadu" & district == "Tiruppur" & city == "Tiruppur" 
replace district = "Coimbatore" if state == "Tamil Nadu" & district == "Tiruppur" & city == "NA" 
replace district = "Coimbatore" if state == "Tamil Nadu" & district == "Tiruppur" & city == "Udumalpet" 
replace district = "Coimbatore" if state == "Tamil Nadu" & district == "Tirupur" & city == "NA" 
replace district = "Coimbatore" if state == "Tamil Nadu" & district == "Tiruppur" & city == "Kangeyam" 

replace district = "Hyderabad" if state == "Andhra Pradesh" & city == "Greater Hyderabad"
replace district = "Rangareddi" if state == "Andhra Pradesh" & city == "Habshiguda"
replace district = "Hyderabad" if state == "Andhra Pradesh" & city == "Hyderabad, Secunderabad"
replace district = "Hyderabad" if state == "Andhra Pradesh" & city == "Secunderabad"

replace state = "Jharkhand" if state == "Bihar" & district == "NA" & city == "Giridih"
replace district = "Giridih" if state == "Jharkhand" & district == "NA" & city == "Giridih"

replace district = "Kolar" if state == "Karnataka" & district == "NA" & city == "Chintamani Rural Police Station"
replace district = "Mysore" if state == "Karnataka" & district == "NA" & city == "Nanjangu"
replace district = "Bangalore Urban" if state == "Karnataka" & district == "NA" & city == "Bangalore, Mumbai"


replace district = "Ernakulam" if state == "Kerala" & district == "NA" & city == "Central City, Koch"
replace district = "Pattanamtitta" if state == "Kerala" & district == "NA" & city == "Kochukoikkal"
replace district = "Thrissur" if state == "Kerala" & district == "NA" & city == "Koduvalloor"
replace district = "Thrissur" if state == "Kerala" & district == "NA" & city == "Kuzhur Grama Panchayat"
replace district = "Ernakulam" if state == "Kerala" & district == "NA" & city == "Pallipuram Grama Panchayat"
replace district = "Malappuram" if state == "Kerala" & district == "NA" & city == "Parappanangadi"
replace district = "Thrissur" if state == "Kerala" & district == "NA" & city == "Sakthan Thampuran Nagar, Thriss"

replace district = "Mumbai city" if state == "Maharashtra" & district == "NA" & city == "Bombay, Mumbai"
replace district = "Pune" if state == "Maharashtra" & district == "NA" & city == "Poona"
replace district = "Pune" if state == "Maharashtra" & district == "NA" & city == "Pune"

replace district = "Jaintia Hills" if state == "Meghalaya" & district == "NA" & city == "Jhadc"

replace state = "Uttar Pradesh" if state == "NA" & district == "NA" & city == "Agra"
replace district = "Agra" if state == "Uttar Pradesh" & district == "NA" & city == "Agra"
replace state = "Karnataka" if state == "NA" & district == "NA" & city == "Arini"
replace district = "Hassan" if state == "Karnataka" & district == "NA" & city == "Agra"
replace state = "Punjab" if state == "NA" & district == "NA" & city == "Bal"
replace district = "Jalandhar" if state == "Punjab" & district == "NA" & city == "Bal"
replace state = "Orissa" if state == "NA" & district == "NA" & city == "Banpur"
replace district = "Khordha" if state == "Orissa" & district == "NA" & city == "Banpur"
replace state = "Gujarat" if state == "NA" & district == "NA" & city == "Bet"
replace district = "Jamnagar" if state == "Gujarat" & district == "NA" & city == "Bet"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Central Hazari Courts"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Central Hazari Courts"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Dilshad Garden"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Dilshad Garden"
replace state = "Jharkhand" if state == "NA" & district == "NA" & city == "Jherria"
replace district = "Dhanbad" if state == "Jharkhand" & district == "NA" & city == "Jherria"
replace state = "Madhya Pradesh" if state == "NA" & district == "NA" & city == "Kam"
replace district = "Sidhi" if state == "Madhya Pradesh" & district == "NA" & city == "Kam"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Karkardooma"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Karkardooma"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Lajpat Nagar"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Lajpat Nagar"
replace state = "Bihar" if state == "NA" & district == "NA" & city == "Lakhisar"
replace district = "Lakhisarai" if state == "Bihar" & district == "NA" & city == "Lakhisar"
replace state = "Kerala" if state == "NA" & district == "NA" & city == "Mavelikara"
replace district = "Lakhisarai" if state == "Kerala" & district == "NA" & city == "Mavelikara"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Model Town, Delhi"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Model Town, Delhi"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Municipal Corporation of Delhi"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Municipal Corporation of Delhi"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Naraina"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Naraina"
replace state = "Orissa" if state == "NA" & district == "NA" & city == "Nayapalli"
replace district = "Khordha" if state == "Orissa" & district == "NA" & city == "Nayapalli"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "New Delhi, Tis Hazari"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "New Delhi, Tis Hazari"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Nihal Vihar"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Nihal Vihar"
replace state = "Maharashtra" if state == "NA" & district == "NA" & city == "Pune"
replace district = "Pune" if state == "Maharashtra" & district == "NA" & city == "Pune"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Rohini"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Rohini"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Rohini Courts"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Rohini Courts"
replace state = "Orissa" if state == "NA" & district == "NA" & city == "Sambalpur"
replace district = "Sambalpur" if state == "Orissa" & district == "NA" & city == "Sambalpur"
replace state = "Maharashtra" if state == "NA" & district == "NA" & city == "Thana"
replace district = "Thane" if state == "Maharashtra" & district == "NA" & city == "Thana"
replace state = "Delhi" if state == "NA" & district == "NA" & city == "Tis Hazari Courts"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Tis Hazari Courts"
replace state = "Tamil Nadu" if state == "NA" & district == "NA" & city == "Ulundurpet"
replace district = "Villupuram" if state == "Tamil Nadu" & district == "NA" & city == "Ulundurpet"

replace district = "Jaipur" if state == "Rajasthan" & district == "NA" & city == "Jaipur, Kolkata"
replace district = "Chennai" if state == "Tamil Nadu" & district == "NA" & city == "Bangalore, Chennai"
replace district = "Chennai" if state == "Tamil Nadu" & district == "NA" & city == "Chennai, Puducherry"
replace district = "Kancheepuram" if state == "Tamil Nadu" & district == "NA" & city == "Karikili Village, Nelvoy Post, Mad"
replace district = "Madurai" if state == "Tamil Nadu" & district == "NA" & city == "Usilambatti"
replace district = "Nagapattinam" if state == "Tamil Nadu" & district == "NA" & city == "Vedarnayam"

replace district = "Lucknow" if state == "Uttar Pradesh" & district == "NA" & city == "Allahabad, Lucknow Bench"

replace district = "Kolkata" if state == "West Bengal" & district == "NA" & city == "Calcutta, Chennai"

replace state = "Chandigarh" if state == "punjab and haryana" & district == "NA" & city == "Chandigar"
replace district = "Chandigarh" if state == "Chandigarh" & district == "NA" & city == "Chandigar"
replace state = "Punjab" if state == "punjab and haryana" & district == "NA" & city == "Hoshiarpur"
replace district = "Hoshiarpur" if state == "Punjab" & district == "NA" & city == "Hoshiarpur"

*-------------------------------------------------------------------------------

replace district = "Warangal" if state == "Andhra Pradesh" & district == "Jayashankar Bhupalpally"
replace district = "Hyderabad" if state == "Andhra Pradesh" & city == "Greater Hyderabad"

replace state = "Jharkhand" if district == "Deoghar" & city == "Madhupur"

replace state = "Jharkhand" if district == "Purba Singhbhum" & city == "Jamshedpur"
replace state = "Jharkhand" if district == "Ranchi" & city == "NA"


replace state = "Chandigarh" if state == "Haryana" & district == "Chandigarh" & city == "NA"
replace state = "Rajasthan" if state == "Haryana" & district == "Chittaurgarh" & city == "NA"
replace state = "Delhi" if state == "Haryana" & district == "Delhi" & city == "New Delhi"

*-------------------------------------------------------------------------------

replace state = "Uttar Pradesh" if state == "Andhra Pradesh" & district == "Muzaffarnagar" & city == "NA"
replace district = "Muzaffarnagar" if state == "Uttar Pradesh" & district == "Muzaffarnagar" & city == "NA"
replace district = "Medak" if state == "Andhra Pradesh" & district == "Siddipet" & city == "NA"
replace state = "Rajasthan" if state == "Bihar" & district == "Baran" & city == "NA"
replace district = "Baran" if state == "Rajasthan" & district == "Baran" & city == "NA"
replace state = "Gujarat" if state == "Delhi" & district == "Ahmadabad" & city == "Ahmedabad"
replace district = "Ahmadabad" if state == "Gujarat" & district == "Ahmadabad" & city == "Ahmedabad"
replace district = "Delhi" if state == "Delhi" & district == "Gautam Buddha Nagar" & city == "New Delhi, Gautam Nagar"
replace state = "West Bengal" if state == "Delhi" & district == "Kolkata" & city == "Calcutta"
replace state = "Maharashtra" if state == "Delhi" & district == "Mumbai city" & city == "New Delhi, Mumbai"
*replace state = "Uttar Pradesh" if state == "Delhi" & district == "New Delhi, Ghaziabad" & city == "New Delhi, Ghaziabad"
replace state = "Orissa" if state == "Gujarat" & district == "Ganjam" & city == "Berhampur"
replace district = "Panch Mahals" if state == "Gujarat" & district == "Mahisagar" & city == "Santrampur"
replace state = "Himachal Pradesh" if state == "Gujarat" & district == "Una" & city == "NA"
replace district = "Faridabad" if state == "Haryana" & district == "Faridabad, Gurgaon" & city == "NA"
replace district = "Gurgaon" if state == "Haryana" & district == "Gurgaon, Faridabad" & city == "NA"
replace district = "Gurgaon" if state == "Haryana" & district == "Kapurthala" & city == "Gurgaon"
replace state = "Chandigarh" if state == "Haryana" & district == "Mewat" & city == "Chandigarh"
replace district = "Chandigarh" if state == "Chandigarh" & district == "Mewat" & city == "Chandigarh"
replace district = "Gurgaon" if state == "Haryana" & district == "New Delhi District, Gurgaon" & city == "New Delhi, Gurgaon"
replace district = "Gurgaon" if state == "Haryana" & district == "Nuh" & city == "Chand"
replace district = "Gurgaon" if state == "Haryana" & district == "Nuh" & city == "NA"
replace state = "Punjab" if state == "Haryana" & district == "Patiala" & city == "NA"
replace state = "Andhra Pradesh" if state == "Haryana" & district == "Rangareddi" & city == "NA"
replace state = "Madhya Pradesh" if state == "Himachal Pradesh" & district == "Anuppur" & city == "NA"
replace district = "Kangra" if state == "Himachal Pradesh" & district == "Dharamshala" & city == "NA"
replace district = "Shimla" if state == "Himachal Pradesh" & district == "Unavailable" & city == "Shimla"
replace state = "Uttar Pradesh" if state == "Jammu and Kashmir" & district == "Badaun" & city == "NA"
replace district = "Srinagar" if state == "Jammu and Kashmir" & district == "Srinagar, Central Delhi" & city == "Srinagar, Delhi"
replace district = "Bangalore Urban" if state == "Karnataka" & district == "Ashoknagar" & city == "Bangalore"
replace state = "Maharashtra" if state == "Karnataka" & district == "Aurangabad" & city == "NA"
replace district = "Hassan" if state == "Karnataka" & district == "NA" & city == "Arini"
replace state = "Tamil Nadu" if state == "Kerala" & district == "Chennai" & city == "Chennai"
replace district = "Chennai" if state == "Tamil Nadu" & district == "Chennai" & city == "Chennai"
replace district = "Thrissur" if state == "Kerala" & district == "Erode" & city == "Anjur village"
replace district = "Alappuzha" if state == "Kerala" & district == "Lakhisarai" & city == "Mavelikara"

replace state = "Maharashtra" if state == "Kerala" & district == "Mumbai city" & city == "Bombay"
replace district = "Mumbai city" if state == "Maharashtra" & district == "Mumbai city" & city == "Bombay"

replace state = "Tamil Nadu" if state == "Kerala" & district == "Nagapattinam" & city == "NA"
replace district = "Nagapattinam" if state == "Tamil Nadu" & district == "Nagapattinam" & city == "NA"

replace state = "Chhattisgarh" if state == "Madhya Pradesh" & district == "Bilaspur" & city == "NA"
replace state = "Maharashtra" if state == "Madhya Pradesh" & district == "Chandrapur" & city == "NA"

replace state = "Tamil Nadu" if state == "Madhya Pradesh" & district == "Chennai" & city == "Chennai"
replace district = "Chennai" if state == "Tamil Nadu" & district == "Chennai" & city == "Chennai"

replace state = "Chhattisgarh" if state == "Madhya Pradesh" & district == "Durg" & city == "Durg"

replace state = "Tamil Nadu" if state == "Madhya Pradesh" & district == "JUDICATURE" & city == "Madras"
replace district = "Chennai" if state == "Tamil Nadu" & district == "JUDICATURE" & city == "Madras"

replace state = "Tamil Nadu" if state == "Madhya Pradesh" & district == "Kancheepuram" & city == "NA"
replace district = "Kancheepuram" if state == "Tamil Nadu" & district == "Kancheepuram" & city == "NA"

replace state = "Orissa" if state == "Madhya Pradesh" & district == "Khordha" & city == "NA"
replace district = "Khordha" if state == "Orissa" & district == "Khordha" & city == "NA"

replace state = "Tamil Nadu" if state == "Madhya Pradesh" & district == "Madurai" & city == "Madurai"
replace district = "Madurai" if state == "Tamil Nadu" & district == "Madurai" & city == "Madurai"

replace state = "Gujarat" if state == "Maharashtra" & district == "Ahmadabad" & city == "Ahmedabad"
replace district = "Ahmadabad" if state == "Gujarat" & district == "Ahmadabad" & city == "Ahmedabad"

replace state = "Goa" if state == "Maharashtra" & district == "Goa" & city == "NA"
replace district = "Goa" if state == "Goa" & district == "Goa" & city == "NA"

replace state = "Jharkhand" if state == "Maharashtra" & district == "Godda" & city == "NA"
replace district = "Godda" if state == "Jharkhand" & district == "Godda" & city == "NA"

replace state = "Assam" if state == "Mizoram" & district == "Kamrup Metropolitan" & city == "NA"
replace district = "Kamrup Metropolitan" if state == "Assam" & district == "Kamrup Metropolitan" & city == "NA"

replace state = "Tamil Nadu" if state == "Puducherry" & district == "Chennai" & city == "Chennai"
replace district = "Chennai" if state == "Tamil Nadu" & district == "Chennai" & city == "Chennai"

replace state = "Madhya Pradesh" if state == "Punjab" & district == "Dewas" & city == "NA"
replace district = "Dewas" if state == "Punjab" & district == "Dewas" & city == "NA"

replace state = "Gujarat" if state == "Punjab" & district == "Gandhinagar" & city == "NA"
replace district = "Gandhinagar" if state == "Gujarat" & district == "Gandhinagar" & city == "NA"

replace state = "Haryana" if state == "Punjab" & district == "Panipat" & city == "NA"
replace district = "Panipat" if state == "Haryana" & district == "Panipat" & city == "NA"

replace district = "Ludhiana" if state == "Punjab" & district == "SAS Nagar" & city == "Mullapur"
replace district = "Jaipur" if state == "Rajasthan" & district == "Jaipur(West)" & city == "NA"
replace district = "Jaipur" if state == "Rajasthan" & district == "Jajpur" & city == "Jaipur"

replace state = "Maharashtra" if state == "Rajasthan" & district == "Mumbai city" & city == "NA"
replace state = "Uttar Pradesh" if state == "Rajasthan" & district == "Pratapgarh" & city == "NA"

replace district = "Chennai" if state == "Tamil Nadu" & district == "Chennai, Erode" & city == "Chennai"
replace district = "Chennai" if state == "Tamil Nadu" & district == "Chennai, Kancheepuram" & city == "Chennai"
replace district = "Chennai" if state == "Tamil Nadu" & district == "Chennai, Thiruvallur, Kancheepuram" & city == "Chennai"

replace state = "Puducherry" if state == "Tamil Nadu" & district == "Karaikal" & city == "NA"
replace district = "Cuddalore" if state == "Tamil Nadu" & district == "Kudikadu" & city == "NA"
replace district = "Namakkal" if state == "Tamil Nadu" & district == "MUNSIF" & city == "Namakkal"
replace district = "Chennai" if state == "Tamil Nadu" & district == "Madurai District, Virudhunagar District" & city == "Chennai"
replace district = "Namakkal" if state == "Tamil Nadu" & district == "MUNSIF" & city == "Namakkal"

replace state = "Tamil Nadu" if state == "Tamil Nadu" & district == "Namakkal District, Tiruppur District" & city == "Chennai, Dharapuram"
replace district = "Coimbatore" if state == "Tamil Nadu" & district == "Thiruppur District" & city == "NA"

replace district = "Chennai" if state == "Tamil Nadu" & district == "Tiruchirappalli District, Madurai" & city == "Chennai"
replace district = "Kanniyakumari" if state == "Tamil Nadu" & district == "`" & city == "Padmanabhapuram"

replace district = "West Tripura" if state == "Tripura" & district == "Kamrup Metropolitan" & city == "Agartala"
replace district = "Sultanpur" if state == "Uttar Pradesh" & district == "Amethi" & city == "NA"

replace state = "Bihar" if state == "Uttar Pradesh" & district == "Buxar" & city == "NA"
replace state = "Rajasthan" if state == "Uttar Pradesh" & district == "Ganganagar" & city == "NA"
replace state = "Uttarakhand" if state == "Uttar Pradesh" & district == "Pauri Garhwal" & city == "NA"
replace state = "Uttar Pradesh" if state == "West Bengal" & district == "Agra" & city == "NA"
replace state = "Haryana" if state == "punjab and haryana" & district == "Faridabad" & city == "Chandigarh, Faridabad"
replace state = "Haryana" if state == "punjab and haryana" & district == "Faridabad" & city == "NA"
replace state = "Punjab" if state == "punjab and haryana" & district == "Hoshiarpur" & city == "NA"

replace state = "Chandigarh" if state == "punjab and haryana" & district == "Panchkula" & city == "Chandigarh"
replace district = "Chandigarh" if state == "Chandigarh" & district == "Panchkula" & city == "Chandigarh"

replace state = "Haryana" if state == "punjab and haryana" & district == "Panchkula" & city == "Chandigarh, Panchkula"
replace state = "Punjab" if state == "punjab and haryana" & district == "Patiala" & city == "NA"
replace state = "Punjab" if state == "punjab and haryana" & district == "Rupnagar" & city == "NA"

replace state = "Madhya Pradesh" if state == "NA" & district == "Bhind" & city == "Kotwali"
replace state = "Jharkhand" if state == "NA" & district == "Bokaro" & city == "NA"
replace state = "Himachal Pradesh" if state == "NA" & district == "Chamba" & city == "NA"
replace state = "Tamil Nadu" if state == "NA" & district == "Erode" & city == "NA"
replace state = "Karnataka" if state == "NA" & district == "Gulbarga" & city == "NA"
replace state = "Jharkhand" if state == "NA" & district == "Hazaribag" & city == "NA"
replace state = "Bihar" if state == "NA" & district == "Jamui" & city == "NA"
replace state = "Himachal Pradesh" if state == "NA" & district == "Mand" & city == "NA"
replace district = "Mandi" if state == "Himachal Pradesh" & district == "Mand" & city == "NA"
replace state = "Himachal Pradesh" if state == "NA" & district == "Mandi" & city == "NA"

replace state = "Delhi" if state == "NA" & district == "NA" & city == "Dhaula Kuan"
replace district = "Delhi" if state == "Delhi" & district == "NA" & city == "Dhaula Kuan"

replace state = "Rajasthan" if state == "NA" & district == "NA" & city == "Mad"
replace district = "Rajsamand" if state == "Rajasthan" & district == "NA" & city == "Mad"

replace state = "Gujarat" if state == "NA" & district == "Navsari" & city == "NA"
replace state = "Bihar" if state == "NA" & district == "Patna" & city == "NA"
replace state = "Madhya Pradesh" if state == "NA" & district == "Raisen" & city == "NA"
replace state = "Bihar" if state == "NA" & district == "Samastipur" & city == "NA"

replace state = "Madhya Pradesh" if state == "NA" & district == "Se" & city == "Forest Range Office Kevlari"
replace district = "Seoni" if state == "Madhya Pradesh" & district == "Se" & city == "Forest Range Office Kevlari"

replace state = "Tamil Nadu" if state == "NA" & district == "Tiruchchirappalli" & city == "NA"

replace state = "Puducherry" if state == "Tamil Nadu" & district == "Puducherry" & city == "NA"



* Getting back to Goa again
tab district if state == "Goa"
replace district = "North Goa" if state == "Goa" & district == "Goa" & city == "NA" 
* (1 real change made)

foreach i in state district {
	replace `i' = "" if `i'=="NA"
	replace `i' = strlower(`i')
}

foreach i of varlist case_date-court_3 act_1-title pcb_action-social_impact_water {
	replace `i' = "" if `i'=="NA"
}
destring case_yr case_mon, force replace
destring in_air_corpus-green_verdict_human green_verdict impact_coded_water social_impact_water, force replace

capture drop human_case chatgpt_case common_case
gen human_case = 0
replace human_case = 1 if !mi(green_verdict_human)
gen chatgpt_case = 0
replace chatgpt_case = 1 if !mi(green_verdict_gpt)
gen common_case = 0
replace common_case = 1 if !mi(green_verdict_gpt) & !mi(green_verdict_human)

gen no_of_judges = .
replace no_of_judges = 3 if !mi(judge_1) & !mi(judge_2) & !mi(judge_3)
replace no_of_judges = 2 if !mi(judge_1) & !mi(judge_2) & mi(judge_3)
replace no_of_judges = 1 if !mi(judge_1) & mi(judge_2) & mi(judge_3)

capture drop human_case chatgpt_case common_case
gen human_case = 0
replace human_case = 1 if !mi(green_verdict_human)
gen chatgpt_case = 0
replace chatgpt_case = 1 if !mi(green_verdict_gpt)
gen common_case = 0
replace common_case = 1 if !mi(green_verdict_gpt) & !mi(green_verdict_human)
gen mismatch = .
replace mismatch = 0 if common_case == 1 & (green_verdict_gpt == green_verdict_human)
replace mismatch = 1 if common_case == 1 & (green_verdict_gpt != green_verdict_human)

gen erelevant =.
replace erelevant = 1 if env_relevance > 50
replace erelevant = 0 if env_relevance <= 50

label variable pcb_action "Did the judge recommend action from the pollution control board"
label variable follow "Did the judge follow the law or did they tweak interpretation?"
label variable regulator_action "Did the judge compel action from regulators/ploiticians?"
label variable erelevant "Is the case relevant to environment y/n"

save case_data.dta,replace

/**************************************************************************************
****************** creating a template file for pollution data ************************
***************************************************************************************/

use case_data,clear
collapse (count) kanoon_id, by(state district)
drop kanoon_id
save case_list.dta,replace

use pollution,clear
collapse (count) case_yr, by(state district)
drop case_yr
joinby state district using case_list, unmatched(both) update
rename _merge _merge_district
lab var _merge_district "master = pollution list ; using = cases list"
save full_list.dta,replace

use pollution,clear
collapse (count) bc, by(case_yr case_mon)
drop bc
save time_list.dta,replace

use full_list,clear
cross using time_list
sort state district case_yr case_mon
joinby state district case_yr case_mon using pollution, unmatched(both)
rename _merge _merge_template
lab var _merge_template "master = full list; using = pollution list"
save template.dta,replace

/*****************************************************************
****************** Merging Case Data ************************
*****************************************************************/
use template.dta, clear

joinby state district case_yr case_mon using case_data, unmatched(both)
rename _merge _merge_case
lab var _merge_case "master = pollution template; using = case_data"
ta _merge_case

/*****************************************************************
****************** Identifying junk cases ************************
*****************************************************************/

gen junk_1 = .
replace junk_1 = 0 if !mi(word_count_bin)
replace junk_1 = 1 if word_count_bin == "0 to 300"

capture drop junk_hat1
reghdfe junk_1 green_verdict length_of_case num_titles_cited, a(state district case_yr) cluster(district)
predict junk_hat1, xb

gen predicted_junk1 = 0
replace predicted_junk1 = 1 if junk_hat1 > 0.5

capture drop junk_hat2
reghdfe junk_1 green_verdict in_air_corpus-env_relevance length_of_case num_titles_cited, a(state district case_yr) cluster(district)
predict junk_hat2, xb

gen predicted_junk2 = 0
replace predicted_junk2 = 1 if junk_hat2 > 0.5

lab var junk_1 "identified by word count <= 300"
lab var predicted_junk1 "predicted using junk_1 variable"
lab var predicted_junk2 "predicted using junk_1 variable includes chatgpt outcomes as predictors"
save master_dataset_v1.dta,replace




/*******************************************************************************
****************** Extracting dataset for ChatGPT paper ************************
*******************************************************************************/
use master_dataset_v1,clear
keep if _merge_case != 1
save truncated_data_for_paper1.dta,replace

/*******************************************************************************
****************** Reshape for Patrick's analyses on judges ************************
*******************************************************************************/
use truncated_data_for_paper1,clear
reshape long judge_, i(kanoon_id) j(judge_number) string
rename judge_ judge_raw
drop if mi(judge_raw)
gen judge = subinstr(lower(judge_raw), ".", " ",.)
replace judge = subinstr(judge,"honble","",.)
replace judge = subinstr(judge,"honourable","",.)

replace judge = subinstr(judge,"acting chief","",.)
replace judge = subinstr(judge,"chief justice","",.)
replace judge = subinstr(judge,"dr","",.)
replace judge = subinstr(judge,"mr","",.)
replace judge = subinstr(judge,"ms","",.)
replace judge = subinstr(judge,"sh","",.)
replace judge = subinstr(judge,"the chief","",.)
// replace judge = subinstr(judge, """","",.)

replace judge = subinstr(judge,"  "," ",.)
replace judge = trim(judge)

egen judgeid = group(judge)

levelsof judgeid , local(unique_values)
di "Number of unique values of judge: `= wordcount("`unique_values'")'"

// preserve
// egen no_of_cases = count(kanoon_id), by(judgeid)
// egen no_of_green_cases = count(kanoon_id) if green_verdict == 1, by(judgeid)
// gen proportion_green = no_of_green_cases/no_of_cases

/**** Does the median judge vote green? ****/

capture drop no_of_cases no_of_green_cases proportion_green
egen no_of_cases = count(kanoon_id) if !mi(green_verdict), by(judgeid)
egen no_of_green_cases = count(kanoon_id) if green_verdict == 1, by(judgeid)
replace no_of_green_cases = 0 if mi(no_of_green_cases) & !mi(green_verdict)
gen proportion_green = no_of_green_cases/no_of_cases


preserve
collapse (first) judge proportion_green no_of_cases no_of_green_cases if !mi(green_verdict), by(judgeid)
log using "green_pct_judge.log",replace
su proportion_green, de
log close
translate green_pct_judge.log green_pct_judge.pdf,replace
save green_pct_dta.dta,replace
restore

// use green_pct_dta,clear
/*** Only for human coded dataset ****/

preserve
keep if human_case == 1
capture drop no_of_cases no_of_green_cases proportion_green
egen no_of_cases = count(kanoon_id) if !mi(green_verdict_human), by(judgeid)
egen no_of_green_cases = count(kanoon_id) if green_verdict_human == 1, by(judgeid)
gen proportion_green = no_of_green_cases/no_of_cases
collapse (mean) proportion_green if !mi(green_verdict_human), by(judgeid)
log using "green_pct_judge_human.log",replace
su proportion_green, de
log close 
translate green_pct_judge_human.log green_pct_judge_human.pdf,replace
restore

/**** Supreme court green orders *****/



/***** how many state ******/

eststo clear
estpost ta state,sort
esttab using "tabsort_state.csv", replace nogaps cells("b pct")

/*****************************************************************
****************** Air Pollution Analysis ************************
*****************************************************************/
use master_dataset_v1,clear
global gpt_outcomes "pcb_action-env_relevance"

eststo clear
foreach yvar in so2 pm18 {
	eststo: reghdfe `yvar' green_verdict, a(state district case_yr) cluster(district)
	eststo: reghdfe `yvar' green_verdict if predicted_junk2 == 0, a(state district case_yr) cluster(district)
	eststo: reghdfe `yvar' green_verdict $gpt_outcomes , a(state district case_yr) cluster(district)
	eststo: reghdfe `yvar' green_verdict $gpt_outcomes if predicted_junk2 == 0, a(state district case_yr) cluster(district)
	eststo: reghdfe `yvar' green_verdict $gpt_outcomes if junk_1 == 0, a(state district case_yr) cluster(district)

}

esttab using "pollution_regressions_first_pass.csv", ar2 se nogaps nobaselevel noconstant replace


eststo clear
estpost su
esttab using "summary.csv", ar2 se nogaps nobaselevel noconstant replace cells("count min max mean sd")


/***********************************************************************
****************** Summary findings for Paper 1 ************************
***********************************************************************/

use truncated_data_for_paper1, clear

count if human_case == 1 
count if human_case == 1 & green_verdict_human == 1
total no_of_judges if human_case == 1
mean no_of_judges if human_case == 1
mean length_of_case if human_case == 1
trimmean length_of_case if human_case == 1,percent(0(5)50)
su length_of_case if human_case == 1
su num_titles_cited if human_case == 1
total junk_1 if human_case == 1
total predicted_junk2 if human_case == 1
count if env_relevance > 50 & human_case == 1
count if env_relevance > 50 & human_case == 1 & green_verdict_human == 1


count if human_case == 1 & water_cases == 1
count if human_case == 1 & water_cases == 1 & green_verdict_human == 1
total no_of_judges if human_case == 1 & water_cases == 1
mean no_of_judges if human_case == 1 & water_cases == 1
mean length_of_case if human_case == 1 & water_cases == 1
trimmean length_of_case if human_case == 1 & water_cases == 1,percent(0(5)50)
su length_of_case if human_case == 1 & water_cases == 1
su num_titles_cited if human_case == 1 & water_cases == 1
total junk_1 if human_case == 1 & water_cases == 1
total predicted_junk2 if human_case == 1 & water_cases == 1
count if env_relevance > 50 & human_case == 1 & water_cases == 1
count if env_relevance > 50 & human_case == 1 & water_cases == 1 & green_verdict_human == 1

count if human_case == 1 & water_cases == 0
count if human_case == 1 & water_cases == 0 & green_verdict_human == 1
total no_of_judges if human_case == 1 & water_cases == 0
mean no_of_judges if human_case == 1 & water_cases == 0
mean length_of_case if human_case == 1 & water_cases == 0
trimmean length_of_case if human_case == 1 & water_cases == 0,percent(0(5)50)
su length_of_case if human_case == 1 & water_cases == 0
su num_titles_cited if human_case == 1 & water_cases == 0
total junk_1 if human_case == 1 & water_cases == 0
total predicted_junk2 if human_case == 1 & water_cases == 0
count if env_relevance > 50 & human_case == 1 & water_cases == 0
count if env_relevance > 50 & human_case == 1 & water_cases == 0 & green_verdict_human == 1


eststo clear
estpost ta state if human_case == 1,sort
esttab using "tabsort_human1.csv", replace nogaps cells("b pct")

eststo clear
estpost ta state if human_case == 1 & green_verdict_human == 1,sort
esttab using "tabsort_human2.csv", replace nogaps cells("b pct")


count if chatgpt_case == 1 //1910
count if chatgpt_case == 1 & green_verdict_gpt == 1 //481
total no_of_judges if chatgpt_case == 1
mean no_of_judges if chatgpt_case == 1
mean length_of_case if chatgpt_case == 1
trimmean length_of_case if chatgpt_case == 1,percent(0(5)50)
su length_of_case if chatgpt_case == 1
su num_titles_cited if chatgpt_case == 1
total junk_1 if chatgpt_case == 1
total predicted_junk2 if chatgpt_case == 1
count if env_relevance > 50 & chatgpt_case == 1
count if env_relevance > 50 & chatgpt_case == 1 & green_verdict_gpt == 1


count if chatgpt_case == 1 & water_cases == 1
count if chatgpt_case == 1 & water_cases == 1 & green_verdict_gpt == 1
total no_of_judges if chatgpt_case == 1 & water_cases == 1
mean no_of_judges if chatgpt_case == 1 & water_cases == 1
mean length_of_case if chatgpt_case == 1 & water_cases == 1
trimmean length_of_case if chatgpt_case == 1 & water_cases == 1,percent(0(5)50)
su length_of_case if chatgpt_case == 1 & water_cases == 1
su num_titles_cited if chatgpt_case == 1 & water_cases == 1
total junk_1 if chatgpt_case == 1 & water_cases == 1
total predicted_junk2 if chatgpt_case == 1 & water_cases == 1
count if env_relevance > 50 & chatgpt_case == 1 & water_cases == 1
count if env_relevance > 50 & chatgpt_case == 1 & water_cases == 1 & green_verdict_gpt == 1

count if chatgpt_case == 1 & water_cases == 0
count if chatgpt_case == 1 & water_cases == 0 & green_verdict_gpt == 1
total no_of_judges if chatgpt_case == 1 & water_cases == 0
mean no_of_judges if chatgpt_case == 1 & water_cases == 0
mean length_of_case if chatgpt_case == 1 & water_cases == 0
trimmean length_of_case if chatgpt_case == 1 & water_cases == 0,percent(0(5)50)
su length_of_case if chatgpt_case == 1 & water_cases == 0
su num_titles_cited if chatgpt_case == 1 & water_cases == 0
total junk_1 if chatgpt_case == 1 & water_cases == 0
total predicted_junk2 if chatgpt_case == 1 & water_cases == 0
count if env_relevance > 50 & chatgpt_case == 1 & water_cases == 0
count if env_relevance > 50 & chatgpt_case == 1 & water_cases == 0 & green_verdict_gpt == 1

eststo clear
estpost ta state if chatgpt_case == 1,sort
esttab using "tabsort_gpt1.csv", replace nogaps cells("b pct")

eststo clear
estpost ta state if chatgpt_case == 1 & green_verdict_gpt == 1,sort
esttab using "tabsort_gpt2.csv", replace nogaps cells("b pct")


count if common_case == 1 
count if common_case == 1 & green_verdict_gpt == 1 
count if common_case == 1 & green_verdict_human == 1 
total no_of_judges if common_case == 1
mean no_of_judges if common_case == 1
mean length_of_case if common_case == 1
trimmean length_of_case if common_case == 1,percent(0(5)50)
su length_of_case if common_case == 1
su num_titles_cited if common_case == 1
total junk_1 if common_case == 1
total predicted_junk2 if common_case == 1
count if env_relevance > 50 & common_case == 1
count if env_relevance > 50 & common_case == 1 & green_verdict_gpt == 1
count if env_relevance > 50 & common_case == 1 & green_verdict_human == 1

count if common_case == 1 & water_cases == 1
count if common_case == 1 & water_cases == 1 & green_verdict_gpt == 1
count if common_case == 1 & water_cases == 1 & green_verdict_human == 1
total no_of_judges if common_case == 1 & water_cases == 1
mean no_of_judges if common_case == 1 & water_cases == 1
mean length_of_case if common_case == 1 & water_cases == 1
trimmean length_of_case if common_case == 1 & water_cases == 1,percent(0(5)50)
su length_of_case if common_case == 1 & water_cases == 1
su num_titles_cited if common_case == 1 & water_cases == 1
total junk_1 if common_case == 1 & water_cases == 1
total predicted_junk2 if common_case == 1 & water_cases == 1
count if env_relevance > 50 & common_case == 1 & water_cases == 1
count if env_relevance > 50 & common_case == 1 & water_cases == 1 & green_verdict_gpt == 1
count if env_relevance > 50 & common_case == 1 & water_cases == 1 & green_verdict_human == 1



count if common_case == 1 & water_cases == 0
count if common_case == 1 & water_cases == 0 & green_verdict_gpt == 1
count if common_case == 1 & water_cases == 0 & green_verdict_human == 1
total no_of_judges if common_case == 1 & water_cases == 0
mean no_of_judges if common_case == 1 & water_cases == 0
mean length_of_case if common_case == 1 & water_cases == 0
trimmean length_of_case if common_case == 1 & water_cases == 0,percent(0(5)50)
su length_of_case if common_case == 1 & water_cases == 0
su num_titles_cited if common_case == 1 & water_cases == 0
total junk_1 if common_case == 1 & water_cases == 0
total predicted_junk2 if common_case == 1 & water_cases == 0
count if env_relevance > 50 & common_case == 1 & water_cases == 0
count if env_relevance > 50 & common_case == 1 & water_cases == 0 & green_verdict_gpt == 1
count if env_relevance > 50 & common_case == 1 & water_cases == 0 & green_verdict_human == 1
count if (env_relevance > 50 | junk_1 == 1) & common_case == 1 & water_cases == 0

eststo clear
estpost ta state if common_case == 1,sort
esttab using "tabsort_common1.csv", replace nogaps cells("b pct")

eststo clear
estpost ta state if common_case == 1 & green_verdict_human == 1,sort
esttab using "tabsort_common2.csv", replace nogaps cells("b pct")

eststo clear
estpost ta state if common_case == 1 & green_verdict_gpt == 1,sort
esttab using "tabsort_common3.csv", replace nogaps cells("b pct")

/***********************************************************************
****************** Summary findings t-tests ************************
***********************************************************************/

ttest no_of_judges, by(human_case)
ttest no_of_judges, by(chatgpt_case)

ttest num_titles_cited, by(human_case)
ttest num_titles_cited, by(chatgpt_case)

ttest length_of_case, by(human_case)
ttest length_of_case, by(chatgpt_case)


/***********************************************************************
****************** Regressions ************************
***********************************************************************/
use truncated_data_for_paper1, clear


eststo clear
eststo: reghdfe green_verdict_human length_of_case num_titles_cited no_of_judges water_cases, a(state district case_yr) cluster(district)
estadd local sample "full"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

eststo: reghdfe green_verdict_human length_of_case num_titles_cited no_of_judges water_cases if junk_1!=1, a(state district case_yr) cluster(district)
estadd local sample "drop under 300"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

eststo: reghdfe green_verdict_human length_of_case num_titles_cited no_of_judges water_cases if erelevant==1, a(state district case_yr) cluster(district)
estadd local sample "e-relevance"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

eststo: reghdfe green_verdict_human length_of_case num_titles_cited no_of_judges water_cases if junk_1!=1 | erelevant == 1, a(state district case_yr) cluster(district)
estadd local sample "both"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"


esttab using "regression1_human_cases.csv",ar2 se nogaps nobaselevels noconstant replace s(sample state dist year obs r2a, label("Sample" "State FE" "District FE" "Case Year FE" " N" "Adj. R-squared"))

eststo clear
eststo: reghdfe green_verdict_gpt length_of_case num_titles_cited no_of_judges water_cases, a(state district case_yr) cluster(district)
estadd local sample "full"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

eststo: reghdfe green_verdict_gpt length_of_case num_titles_cited no_of_judges water_cases if junk_1!=1, a(state district case_yr) cluster(district)
estadd local sample "drop under 300"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

eststo: reghdfe green_verdict_gpt length_of_case num_titles_cited no_of_judges water_cases if erelevant==1, a(state district case_yr) cluster(district)
estadd local sample "e-relevance"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

eststo: reghdfe green_verdict_gpt length_of_case num_titles_cited no_of_judges water_cases if junk_1!=1 | erelevant == 1, a(state district case_yr) cluster(district)
estadd local sample "both"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

esttab using "regression1_chatgpt_cases.csv",ar2 se nogaps nobaselevels noconstant replace s(sample state dist year obs r2a, label("Sample" "State FE" "District FE" "Case Year FE" " N" "Adj. R-squared"))

eststo clear
eststo: reghdfe green_verdict length_of_case num_titles_cited no_of_judges water_cases if common_case ==1, a(state district case_yr) cluster(district)
estadd local sample "full"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

eststo: reghdfe green_verdict length_of_case num_titles_cited no_of_judges water_cases if common_case ==1 & junk_1 !=1, a(state district case_yr) cluster(district)
estadd local sample "drop under 300"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

eststo: reghdfe green_verdict length_of_case num_titles_cited no_of_judges water_cases if common_case ==1 & erelevant==1, a(state district case_yr) cluster(district)
estadd local sample "e-relevance"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

eststo: reghdfe green_verdict length_of_case num_titles_cited no_of_judges water_cases if common_case ==1 & (junk_1!=1 | erelevant == 1), a(state district case_yr) cluster(district)
estadd local sample "both"
estadd scalar obs =  e(N)
estadd scalar r2a = e(r2_a)
estadd local state "yes"
estadd local dist "yes"
estadd local year "yes"

esttab using "regression1_common_cases.csv",ar2 se nogaps nobaselevels noconstant replace s(sample state dist year obs r2a, label("Sample" "State FE" "District FE" "Case Year FE" " N" "Adj. R-squared"))

************************************************************************************************
/******************************* Mismatch between human and chatgpt green orders ***************
************************************************************************************************/
egen actid_1 = group(act_1)


eststo clear
eststo: reghdfe mismatch length_of_case num_titles_cited no_of_judges water_cases pcb_action env_relevance regulator_action follow, a(state district case_yr) cluster(district)
eststo: reghdfe mismatch length_of_case num_titles_cited no_of_judges water_cases pcb_action env_relevance regulator_action follow i.actid_1, a(state district case_yr) cluster(district)
eststo: reghdfe mismatch length_of_case num_titles_cited no_of_judges water_cases pcb_action env_relevance regulator_action follow green_verdict_gpt, a(state district case_yr) cluster(district)
eststo: reghdfe mismatch length_of_case num_titles_cited no_of_judges water_cases pcb_action env_relevance regulator_action follow green_verdict_gpt i.actid_1, a(state district case_yr) cluster(district)

esttab using "regression2_mismatch.csv",ar2 se nogaps nobaselevels noconstant replace

// reghdfe mismatch num_titles_cited length_of_case i.pcb_action i.follow i.regulator_action env_relevance no_of_judges i.actid_1 green_verdict_gpt, a(state district i.case_yr) cluster(district)
// predict yhat_mismatch, xb