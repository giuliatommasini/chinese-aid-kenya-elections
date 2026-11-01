********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: List of all constituency ids with at least one project
*          (used as the panel universe in 08_build_aid_survey.do)

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global clean_data "$data/Aid/01_Cleaned Data"
global survey_data "$data/Survey Analysis"

********************************************************************************

use "$clean_data/cleaned_code.dta", clear 

keep _ID 
duplicates drop 

save "$survey_data/all_const_id.dta", replace
