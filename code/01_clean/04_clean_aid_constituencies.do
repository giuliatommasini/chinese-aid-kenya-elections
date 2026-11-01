********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Cleaning and saving of raw Aid Data

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global clean_data "$data/Aid/01_Cleaned Data"
global geo_data "$data/Geo/gadm36_KEN_shp"
global other_data "$data/Controls"


clear all 


** Define constituency (code) for each project based on coordinates

use "$clean_data/cleaned.dta", clear 

geoinpoly latitude longitude using "$geo_data/kenya_coords.dta"

* Generate a unique identifier for each row (project)
gen long row_id = _n

* Checks 
sort name_2
egen const_id = group(name_2)

bysort const_id: egen n_id = nvals(_ID)
count if n_id > 1 //227 
drop const_id 


* Adjust for borders 
preserve 
keep if n_id > 1

/* Inconsistencies in aid data based on cleaning _ID to 290: 
Igembe South has missing _ID (solved keeping more _ID with obs divided in _ID = 164 and _ID = 263)
Kabete has all _ID = 82 except for one _ID = 85
Kajiado East is divided between _ID = 57 and _ID = 146
Kiharu has all _ID = 188 except for one _ID = 100 
Kitui East has all _ID = 118 except for one _ID = 119 
Langata has all _ID = 201 except for a few _ID = 2006 
Masinga has all _ID = 137 except for one _ID = 37 
Mvita has missing _ID -> classify under _ID = 194
Mwala has all _ID = 140 except for one _ID = 148
Narok South has _ID = 229 except for one _ID = 228
*/

gen problematic = 1 

keep problematic _ID row_id name_2

save "$clean_data/inconsitent_boundary.dta", replace 

restore 

* Merge it back to solve inconsistencies for boundaries 
merge 1:1 row_id using "$clean_data/inconsitent_boundary.dta" 
drop _merge 

* Manually cleaning for misclassified locations 
replace _ID = 72 if _ID == 106 & problematic==1 
replace _ID = 78 if _ID == 110 & problematic==1 
replace _ID = 105 if _ID == 213 & problematic==1 
replace _ID = 124 if _ID == 125 & problematic==1 
replace _ID = 145 if _ID == 253 & problematic==1 
replace _ID = 170 if _ID == 180 & problematic==1 
replace _ID = 194 if _ID == .  & problematic==1 
replace _ID = 195 if _ID == 182 & problematic==1 
replace _ID = 208 if _ID == 207 & problematic==1 


* Save dataset 
save "$clean_data/cleaned_code.dta", replace 


************************************************
***		 		MERGE CONTROL DATA			 ***
************************************************

** Merge main dataset with controls data 

clear all 

import delimited "$other_data/controls.csv"

* Cleaning for consistency with aid data 
replace shapename = "Bureti" if shapename == "Buret"
replace shapename = "Central Imenti" if shapename == "Cental Imenti" 
replace shapename = "Chuka/Igambang'Ombe" if shapename == "Nithi"
replace shapename = "Daadab" if shapename == "Dadaab"
replace shapename = "Dagoretti South" if shapename=="Dagoretti"
replace shapename = "Dagoretti North" if shapename== "Kilimani"
replace shapename = "Garissa Township" if shapename== "Dujis"
replace shapename = "Homa Bay Town" if shapename== "Homa Bay"
replace shapename = "Lungalunga" if shapename== "Lunga Lunga"
replace shapename = "Mbeere North" if shapename== "Siakago"
replace shapename = "Mbeere South" if shapename== "Gachoka"
replace shapename = "Mbita" if shapename== "Suba North"
replace shapename = "Mukurweini" if shapename== "Mukurweni"
replace shapename = "Mwingi Central" if shapename=="Mwingi East"
replace shapename = "Suba" if shapename== "Suba South"


* Rename var name for consistency 
gen NAME_2 = shapename

merge 1:m NAME_2 using "$geo_data/kenya_coords.dta"
drop _merge 

sort NAME_2
egen id_diss = group(NAME_2)


* Cleaning 
rename v4composites_calibrated_20170920 luminosity_2002
rename gpw_v4_rev11_density2000mean pop_density_2000
rename access_50knonemean time_tocity
rename srtm_slope_500mnonemean slope 
rename plad_v70_leader_birthplace2002ma presence_leader_birthplace2002

collapse _ID luminosity_2002 pop_density_2000 time_tocity slope presence_leader_birthplace2002, by(NAME_2)

rename NAME_2 name_2 

keep name_2 _ID luminosity_2002 pop_density_2000 time_tocity slope presence_leader_birthplace2002

save "$clean_data/control_data_formerge.dta", replace 
