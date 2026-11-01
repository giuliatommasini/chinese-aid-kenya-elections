********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Data Preparation Aid Data for Electoral Analysis: Donor

********************************************************************************


clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global clean_data "$data/Aid/01_Cleaned Data"
global survey_data "$data/Survey Analysis"


******************************************
** 			Create datasets: China		**
******************************************

clear all 

use "$clean_data/cleaned_code.dta", clear 


** Creating constituency-year dataset **

preserve

keep if donor == "China"

* Generate variable counting the number of projects 
gen byte num_projects = 1

collapse (sum) num_projects (sum) mon_value = comm_loc_evensplit (count) n_value = comm_loc_evensplit, by(_ID startyear)

* Dealing with missing values 
replace mon_value = . if n_value == 0

* Set panel
xtset _ID startyear 

* Fill missing years
tsfill, full

* Set missing to zero after tsfill
replace num_projects = 0 if missing(num_projects)
replace mon_value = 0 if missing(mon_value) & n_value != 0

* Generate cumulative sums up to each year
bysort _ID (startyear): gen num_projects_ch = sum(num_projects)
bysort _ID (startyear): gen mon_value_ch = sum(mon_value)

* Drop initial vars 
drop num_projects mon_value

* Keep only Afrobarometer cutoffs (exclude survey year)
*keep if inlist(startyear, 2002, 2004, 2007, 2010, 2013)
keep if inlist(startyear, 2003, 2005, 2008, 2011, 2014)

save "$survey_data/years_china.dta", replace

restore


*** Combining with all constituencies ***

use "$survey_data/panel_skeleton.dta", clear

merge 1:1 _ID startyear using "$survey_data/years_china.dta", keep(master match) nogen

foreach v in num_projects_ch mon_value_ch {
    replace `v' = 0 if missing(`v')
}

save "$survey_data/years_china_fixed.dta", replace


******************************************
** 		Create datasets: World Bank		**
******************************************

clear all 

use "$clean_data/cleaned_code.dta", clear 


** Creating constituency-year dataset **

preserve

collapse (mean) comm_loc_evensplit, ///
    by(project_id project_location_id startyear _ID donor)

keep if donor == "World Bank"

* Generate variable counting the number of projects 
gen byte one = 1

collapse (sum) num_projects = one (sum) mon_value = comm_loc_evensplit (count) n_value = comm_loc_evensplit, by(_ID startyear)

* Dealing with missing values 
replace mon_value = . if n_value == 0

* Set panel
xtset _ID startyear 

* Fill missing years
tsfill, full

* Set missing to zero after tsfill
replace num_projects = 0 if missing(num_projects)
replace mon_value = 0 if missing(mon_value) & n_value != 0

* Generate cumulative sums up to each year
bysort _ID (startyear): gen num_projects_wb = sum(num_projects)
bysort _ID (startyear): gen mon_value_wb = sum(mon_value)

* Drop initial vars 
drop num_projects mon_value

* Keep only Afrobarometer cutoffs (exclude survey year)
*keep if inlist(startyear, 2002, 2004, 2007, 2010, 2013)
keep if inlist(startyear, 2003, 2005, 2008, 2011, 2014)

save "$survey_data/years_wb.dta", replace

restore


*** Combining with all constituencies ***

use "$survey_data/panel_skeleton.dta", clear

merge 1:1 _ID startyear using "$survey_data/years_wb.dta", keep(master match) nogen

foreach v in num_projects_wb mon_value_wb {
    replace `v' = 0 if missing(`v')
}

save "$survey_data/years_wb_fixed.dta", replace



**********************************************************
** 			Create datasets: Final Combined Dataset		**
**********************************************************

clear all 

use "$survey_data/years_china_fixed.dta", clear

merge 1:1 _ID startyear using "$survey_data/years_wb_fixed.dta"

tab _merge
drop _merge

* Cleaning for consistency 
rename startyear year 
drop n_value

save "$survey_data/aid_survey_final_combined.dta", replace
