********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Cleaning and saving of raw Aid Data

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global data_input "$data/Aid/00_Raw Data/GODAD"
global intermed_data "$data/Aid/01_Intermediary Data"
global clean_data "$data/Aid/01_Cleaned Data"

clear all 

********************************************************************************

** Importing raw data 

import delimited "$data_input/projectlevel_china_wb.csv"

* Keep only projects in Kenya
keep if name_0=="Kenya" 

* Save raw data 
save "$intermed_data/raw.dta", replace 


** Cleaning and saving cleaned data 

clear all 
use "$intermed_data/raw.dta", clear 

* Drop projects whose location is unknown 
drop if name_2 == "unknown 2" | name_2== "unknown 7"
drop if name_2== ""

* Generate code for donor identity 
encode donor, gen(donor_id) 

* Save cleaned data 
save "$clean_data/cleaned.dta", replace 
