********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Data Preparation Survey Data for Electoral Analysis

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global survey_data "$data/Survey Analysis"
global geo_data "$data/Geo/gadm36_KEN_shp"


clear all 

********************************************************************************

** Create final datatset of all survey waves 

use "$survey_data/Wave4_const.dta", clear 

* Append Wave 6
append using "$survey_data/Wave6_const.dta", force

* Append Wave 5
append using "$survey_data/Wave5_const.dta", force

* Append Wave 3
append using "$survey_data/Wave3_const.dta", force

* Append Wave 2
append using "$survey_data/Wave2_const.dta", force

* Cleaning 
drop if _ID == . 

replace year = 2003 if year == 2002 
replace year = 2005 if year == 2004 
replace year = 2008 if year == 2007
replace year = 2011 if year == 2010
replace year = 2014 if year == 2013 

* Save final data 
save "$survey_data/survey_final.dta", replace  


** Create dataset at the wave-constituency level

clear

input byte wave int startyear
2 2003
3 2005
4 2008
5 2011
6 2014
end
tempfile wavemap

save `wavemap', replace

use "$geo_data/kenya_coords.dta"

collapse (mean) _X _Y, by(_ID)

drop _X _Y
 
* Assign to each constituency all waves
cross using `wavemap'   

tempfile panel_skeleton

save "$survey_data/panel_skeleton.dta", replace

