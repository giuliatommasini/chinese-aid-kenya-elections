********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Cleaning and saving of raw Electoral Data

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global data_input "$data/Voting/Elections Results/01_Cleaned Data"
global intermed_data "$data/Voting/Elections Results/02_Intermediary Data"
global electoral_data "$data/Electoral Analysis"

clear all 

********************************************************************************

** Import and save data for National Assembly 2013

import delimited "$data_input/Results_National_Assembly_2013.csv"

sort constituencyname year politicalpartyname

* Checks 
sum totalvotes

duplicates drop candidatesname, force

* Save data 
save "$intermed_data/National_Assembly_2013.dta", replace 


** Import and save data for National Assembly 2017

clear all 

import delimited "$data_input/Results_National_Assembly_2017.csv"

sort constituencyname year politicalpartyname

* Checks 
sum totalvotes

* Save data 
save "$intermed_data/National_Assembly_2017.dta", replace 


** Create combined electoral dataset

use "$intermed_data/National_Assembly_2017.dta", clear 

* Append 2013 data 
append using "$intermed_data/National_Assembly_2013.dta"

* Save data 
save "$intermed_data/National_Assembly_tot.dta", replace 

export delimited using "$data_input/National_Assembly_tot.csv", replace


* Checks for 2013 extraction 

clear all 

use "$intermed_data/National_Assembly_tot.dta", clear 

preserve 
duplicates report constituencyname year

contract constituencyname year
bysort constituencyname: gen num_years = _N

tab num_years

keep if num_years==1
restore


** Create dataset of all constituencies 

use "$intermed_data/National_Assembly_tot.dta", clear 

* Keep only constituencies 
collapse (mean) constituencycode, by(constituencyname)

* Save data 
save "$electoral_data/all_const.dta", replace 
