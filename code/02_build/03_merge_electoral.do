********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Merge electoral results with aid data (part 1, before spillovers)

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global electoral_data "$data/Electoral Analysis"
global other_data "$data/Controls"
global geo_data2 "$data/Geo/gadm36_KEN_shp"
global spillover_data "$data/Geo/spillover"

clear all 


********************************************
***		 		MERGE MAIN DATA			 ***
********************************************

** Create main dataset with electoral results and aid 

clear all 

use "$electoral_data/voting_classified.dta", clear 

gen Pre = year==2013
gen Post = year==2017 

gen period = "pre" if year==2013
replace period ="post" if year==2017


* Collapse electoral data at the constituency-period level 
collapse (mean) Incumbent_vote_share Opposition_vote_share winning_coalition_vote_share margin_victory, by(period constituencyname) 

* Merge with aid data 
merge 1:1 constituencyname period using "$electoral_data/aid_electoral_final_combined.dta"
drop _merge 


* Generate normalized money values 
gen mon_value_ch_million = mon_value_ch / 10000000
label var mon_value_ch_million "Monetary value China 10 millions"
gen mon_value_wb_million = mon_value_wb / 10000000 
label var mon_value_wb_million "Monetary value World Bank 10 millions"

* Generate transformation 
gen ln_mon_value_ch = ln(mon_value_ch + 1)
label var ln_mon_value_ch "Log(1+Monetary value China)"
gen ln_mon_value_wb = ln(mon_value_wb + 1)
label var ln_mon_value_wb "Log (1+Monetary value World Bank)"

gen ln_num_proj_ch = ln(num_projects_china + 1)
label var ln_num_proj_ch "Log(1+Number of projects China)"
gen ln_num_proj_wb = ln(num_projects_wb + 1)
label var ln_num_proj_wb "Log(1+Number of projects World Bank)"


save "$electoral_data/electoral_analysis_heter_donor.dta", replace 

