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
global electoral_data "$data/Electoral Analysis"

clear all 

********************************************************************************

use "$clean_data/cleaned.dta", clear 

********************************************************************************

* Missing of comm_loc_evensplit: 40 consituencies (out of 103 receiving aid) have at least one missing value for comm_loc_evensplit, 2 constituencies have all projects with missing comm_loc_evensplit. There are 40 projects with missing values for monetary commitment in the dataset in total 


/* Construction of dataset with two datapoints for each constituency: aid before 2013 and aid between 2013-17 */

******************************************
** 			Create datasets: China		**
******************************************

clear all 

use "$clean_data/cleaned.dta", clear 


*** Cleaning 

* Cleaning for consistency with electoral data 
replace name_2 = "Dadaab" if name_2 == "Daadab"
replace name_2 = "Chuka Igambang'Ombe" if name_2 == "Chuka/Igambang'Ombe"
replace name_2 = "Lang'ata" if name_2=="Langata"  

* Adjusting name to be consistent with electoral analysis 
gen constituencyname = upper(name_2)


** Creating Pre dataset **
preserve

keep if startyear < 2013 & donor == "China"

* Generate variable counting the number of projects 
gen byte num_projects = 1

collapse (sum) num_projects (sum) mon_value = comm_loc_evensplit (count) n_value = comm_loc_evensplit, by(constituencyname)

* Dealing with missing values 
replace mon_value = . if n_value == 0
drop n_value

gen period = "pre"
gen Pre = 1
gen Post = 0

save "$electoral_data/pre_china.dta", replace

restore


** Creating Post dataset **
preserve

keep if startyear > 2013 & startyear < 2017 & donor == "China"

* Generate variable counting the number of projects 
gen byte num_projects = 1

collapse (sum) num_projects (sum) mon_value = comm_loc_evensplit (count) n_value   = comm_loc_evensplit, by(constituencyname)

* Dealing with missing values 
replace mon_value = . if n_value == 0
drop n_value

gen period = "post"
gen Pre = 0
gen Post = 1

save "$electoral_data/post_china.dta", replace

restore


*** Combining Pre with all constituencies ***
clear all 

use "$electoral_data/all_const.dta", clear

merge 1:1 constituencyname using "$electoral_data/pre_china.dta"

* Fill in constituencies that had no projects in pre_china
replace num_projects = 0 if _merge==1
replace mon_value = 0 if _merge==1

drop _merge 

* Fill in period indicators for those constituencies
replace period = "pre" if missing(period)

replace Pre  = 1 if missing(Pre)
replace Post = 0 if missing(Post)

save "$electoral_data/pre_china_fixed.dta", replace


** Combining Post with all constituencies **
clear all 

use "$electoral_data/all_const.dta", clear

merge 1:1 constituencyname using "$electoral_data/post_china.dta"

* Fill in constituencies that had no projects in post_china
replace num_projects = 0 if _merge==1
replace mon_value = 0 if _merge==1

drop _merge 

* Fill in period indicators for those constituencies
replace period = "post" if missing(period)
replace Pre = 0 if missing(Pre)
replace Post = 1 if missing(Post)

save "$electoral_data/post_china_fixed.dta", replace


** Combining fixed (with all constituencies) Pre and Post **
clear all 

use "$electoral_data/pre_china_fixed.dta", clear

append using "$electoral_data/post_china_fixed.dta"

* Adjusting names for final dataset 
rename num_projects num_projects_china
rename mon_value mon_value_ch

* Label variable 
label var num_projects_china "Number of projects China"
label var mon_value_ch "Monetary value China"

save "$electoral_data/china_aid.dta", replace



**********************************************
** 			Create datasets: World Bank		**
**********************************************

clear all 

use "$clean_data/cleaned.dta", clear 


*** Cleaning 

* Cleaning for consistency with electoral data 
replace name_2 = "Dadaab" if name_2 == "Daadab"
replace name_2 = "Chuka Igambang'Ombe" if name_2 == "Chuka/Igambang'Ombe"
replace name_2 = "Lang'ata" if name_2=="Langata"

* Adjusting name to be consistent with electoral analysis 
gen constituencyname = upper(name_2)


** Creating Pre dataset **
preserve

collapse (mean) comm_loc_evensplit, by(project_id project_location_id startyear donor constituencyname)

keep if startyear < 2013 & donor == "World Bank"

* Generate variable counting the number of projects 
gen one = 1

collapse (sum) num_projects = one (sum) mon_value = comm_loc_evensplit (count) n_value = comm_loc_evensplit, by(constituencyname)

* Dealing with missing values 
replace mon_value = . if n_value == 0
drop n_value

gen period = "pre"
gen Pre = 1
gen Post = 0

save "$electoral_data/pre_wb.dta", replace

restore


** Creating Post dataset **
preserve

collapse (mean) comm_loc_evensplit, by(project_id project_location_id startyear donor constituencyname)

keep if startyear > 2013 & startyear < 2017 & donor == "World Bank"

* Generate variable counting the number of projects 
gen one = 1

collapse (sum) num_projects = one (sum) mon_value = comm_loc_evensplit (count) n_value = comm_loc_evensplit, by(constituencyname)

* Dealing with missing values 
replace mon_value = . if n_value == 0
drop n_value

gen period = "post"
gen Pre = 0
gen Post = 1

save "$electoral_data/post_wb.dta", replace

restore


** Combining Pre with all constituencies **
clear all 

use "$electoral_data/all_const.dta", clear

merge 1:1 constituencyname using "$electoral_data/pre_wb.dta"

* Fill in constituencies that had no projects in pre_wb
replace num_projects = 0 if _merge==1
replace mon_value = 0 if _merge==1

drop _merge 

* Fill in period indicators for those constituencies
replace period = "pre" if missing(period)
replace Pre = 1 if missing(Pre)
replace Post = 0 if missing(Post)

save "$electoral_data/pre_wb_fixed.dta", replace


** Combining Post with all constituencies **
clear all 

use "$electoral_data/all_const.dta", clear

merge 1:1 constituencyname using "$electoral_data/post_wb.dta"

* Fill in constituencies that had no projects in post_wb
replace num_projects = 0 if _merge==1
replace mon_value = 0 if _merge==1

drop _merge 

* Fill in period indicators for those constituencies
replace period = "post" if missing(period)
replace Pre = 0 if missing(Pre)
replace Post = 1 if missing(Post)

save "$electoral_data/post_wb_fixed.dta", replace


** Combining fixed (with all constituencies) Pre and Post **
clear all 

use "$electoral_data/pre_wb_fixed.dta", clear

append using "$electoral_data/post_wb_fixed.dta"

* Adjusting names for final dataset 
rename num_projects num_projects_wb
rename mon_value mon_value_wb

* Label variable 
label var num_projects_wb "Number of projects World Bank"
label var mon_value_wb "Monetary value World Bank"

save "$electoral_data/worldbank_aid.dta", replace



**********************************************************
** 			Create datasets: Final Combined Dataset		**
**********************************************************

clear all 

use "$electoral_data/china_aid.dta", clear

merge 1:1 constituencyname period using "$electoral_data/worldbank_aid.dta"

tab _merge
drop _merge

label var Post "Post"

* Generate dummies indicating constituencies receiving aid at a certain point 
bysort constituencyname: egen ever_china_aid = max(num_projects_china  > 0)
bysort constituencyname: egen ever_wb_aid = max(num_projects_wb  > 0)

save "$electoral_data/aid_electoral_final_combined.dta", replace
