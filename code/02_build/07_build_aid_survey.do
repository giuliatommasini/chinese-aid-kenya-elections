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


* ---- End of the code used for the thesis. The code below was exploratory
* ---- and is not run (exit returns control to master.do).
exit

******************************************
** 			Panel construction 			**
******************************************
/* Construct of dataset with two datapoints for each constituency: aid before 2008 and aid between 2008-14*/

gen Pre = startyear < 2008
gen Post = startyear > 2008 & startyear < 2014

gen china = donor == "China"
gen wb = donor == "World Bank"


*** CHINA ***

* Creating Pre dataset
preserve 

use "$clean_data/cleaned_code.dta", clear 

keep if startyear<2008 & donor == "China"

gen num_projects = 1
collapse (count) num_projects (sum) mon_value=comm_loc_evensplit, by(_ID)

gen period = "pre"
gen Pre = 1
gen Post = 0

save "$survey_data/pre_china.dta", replace

restore 


* Creating Post dataset
preserve 

use "$clean_data/cleaned_code.dta", clear 

keep if startyear<2014 & startyear>2008 & donor == "China"

gen num_projects = 1
collapse (count) num_projects (sum) mon_value=comm_loc_evensplit, by(_ID)

gen period = "post"
gen Pre = 0
gen Post = 1

save "$survey_data/post_china.dta", replace

restore 


* Combining Pre with all constituencies
clear all 
use "$survey_data/all_const_id.dta", clear

merge m:1 _ID using "$survey_data/pre_china.dta"
drop _merge 

replace num_projects = 0 if missing(num_projects)
replace mon_value = 0 if missing(mon_value) 

replace period = "pre" if missing(period)
replace Pre = 1 if missing(Pre)
replace Post = 0 if missing(Post)

save "$survey_data/pre_china_fixed.dta", replace


* Combining Post with all constituencies
clear all 
use "$survey_data/all_const_id.dta", clear

merge m:1 _ID using  "$survey_data/post_china.dta"
drop _merge 

replace num_projects = 0 if missing(num_projects)
replace mon_value = 0 if missing(mon_value) 

replace period = "post" if missing(period)
replace Pre = 0 if missing(Pre)
replace Post = 1 if missing(Post)

save  "$survey_data/post_china_fixed.dta", replace


* Combining fixed Pre and Post  
clear all 
use "$survey_data/pre_china_fixed.dta", clear
append using "$survey_data/post_china_fixed.dta"


* Adjusting names for final dataset 
rename num_projects num_projects_china
rename mon_value mon_value_ch

* Label variable 
label var num_projects_china "Number of projects China"
label var mon_value_ch "Monetary value of projects China"

label var Post "Post"

save "$survey_data/aid_survey_china.dta", replace 



*** WORLD BANK ***

* Creating Pre dataset
preserve 

use "$clean_data/cleaned_code.dta", clear 

keep if startyear<2008 & donor == "World Bank"

gen num_projects = 1
collapse (count) num_projects (sum) mon_value=comm_loc_evensplit, by(_ID)

gen period = "pre"
gen Pre = 1
gen Post = 0

save "$survey_data/pre_wb.dta", replace

restore 


* Creating Post dataset
preserve 

use "$clean_data/cleaned_code.dta", clear 

keep if startyear<2014 & startyear>2008 & donor == "World Bank"

gen num_projects = 1
collapse (count) num_projects (sum) mon_value=comm_loc_evensplit, by(_ID)

gen period = "post"
gen Pre = 0
gen Post = 1

save "$survey_data/post_wb.dta", replace

restore 


* Combining Pre with all constituencies
clear all 
use "$survey_data/all_const_id.dta", clear

merge m:1 _ID using "$survey_data/pre_wb.dta"
drop _merge 

replace num_projects = 0 if missing(num_projects)
replace mon_value = 0 if missing(mon_value) 

replace period = "pre" if missing(period)
replace Pre = 1 if missing(Pre)
replace Post = 0 if missing(Post)

save "$survey_data/pre_wb_fixed.dta", replace


* Combining Post with all constituencies
clear all 
use "$survey_data/all_const_id.dta", clear

merge m:1 _ID using  "$survey_data/post_wb.dta"
drop _merge 

replace num_projects = 0 if missing(num_projects)
replace mon_value = 0 if missing(mon_value) 

replace period = "post" if missing(period)
replace Pre = 0 if missing(Pre)
replace Post = 1 if missing(Post)

save  "$survey_data/post_wb_fixed.dta", replace


* Combining fixed Pre and Post  
clear all 
use "$survey_data/pre_wb_fixed.dta", clear
append using "$survey_data/post_wb_fixed.dta"


* Adjusting names for final dataset 
rename num_projects num_projects_wb
rename mon_value mon_value_wb

* Label variable 
label var num_projects_wb "Number of projects World Bank"
label var mon_value_wb "Monetary value of projects World Bank"

label var Post "Post"

save "$survey_data/aid_survey_wb.dta", replace 


*** COMBINED *** 

clear all 
use "$survey_data/aid_survey_china.dta", clear

merge 1:1 _ID period using "$survey_data/aid_survey_wb.dta"

tab _merge

drop _merge

label var Post "Post"

save "$survey_data/aid_survey_final_combined.dta", replace
