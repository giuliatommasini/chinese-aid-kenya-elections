********************************************************************************

* Author: Giulia 
* Date Created: January 2026 
* Purpose: Data Preparation of Geo Data  

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do


global geo_data "$data/Geo/Kenya_Constituencies"
global geo_data2 "$data/Geo/gadm36_KEN_shp"
global electoral_data "$data/Electoral Analysis"
global clean_data "$data/Aid/01_Cleaned Data"

clear all 


**********************************************
** 			PRAPARATION OF GEO DATA 		**  
**********************************************

cd "$geo_data2"
shp2dta using "gadm36_KEN_2.shp", ///
    database(kenya_data) ///
    coordinates(kenya_coords) ///
    genid(id) ///
    replace


** Clean attribute data 
use kenya_data, clear

* Cleaning 
drop if inlist(NAME_2, "805", "unknown 1", "unknown 2", "unknown 3", "unknown 4", ///
                     "unknown 5", "unknown 6", "unknown 7", "unknown 8")

sort NAME_2

replace NAME_2 =  "Webuye West" if NAME_2 == "Webute West" 

* Generate id to deal with duplicates for name_2 
egen id_diss = group(NAME_2) //alphabetical order 

save kenya_data, replace

* Prepare for filter data in kenya coords as well 
keep id id_diss GID_2 NAME_1 NAME_2
rename id _ID  
save id_crosswalk, replace

* Clean kenya coords 
use kenya_coords, clear

merge m:1 _ID using id_crosswalk, keep(match) nogenerate

replace _ID = id_diss
drop id_diss

save kenya_coords, replace


** Creating dataset of counties 

use kenya_data, clear  

keep NAME_1 NAME_2 

rename NAME_2 constituencyname

* Cleaning for consistency with electoral data 
replace constituencyname = "Dadaab" if constituencyname == "Daadab"
replace constituencyname = "Chuka Igambang'Ombe" if constituencyname == "Chuka/Igambang'Ombe"
replace constituencyname = "Lang'ata" if constituencyname=="Langata" 
replace constituencyname =  "Sigowet Soin" if constituencyname == "Sigowet/Soin"

replace constituencyname = upper(constituencyname)

duplicates drop constituencyname, force 

save "$geo_data2/skeleton_county.dta", replace 


** Merging with electoral analysis data to include _ID 

use "$geo_data2/kenya_coords.dta", clear 

collapse _ID , by(NAME_2)

* Harmonize 
replace NAME_2 = "CHUKA IGAMBANG'OMBE" if NAME_2 == "Chuka/Igambang'Ombe"
replace NAME_2 = "DADAAB" if NAME_2 == "Daadab"
replace NAME_2 = "LANG'ATA" if NAME_2 == "Langata"
replace NAME_2 = "SIGOWET SOIN" if NAME_2 == "Sigowet/Soin"

* Adjusting name to be consistent with electoral analysis 
gen constituencyname = upper(NAME_2)

keep constituencyname _ID 

save "$geo_data2/skeleton_spillover_el.dta", replace  

