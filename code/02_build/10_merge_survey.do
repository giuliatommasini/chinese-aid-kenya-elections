********************************************************************************

* Author: Giulia 
* Date Created: January 2026 
* Purpose: Data Merge Survey with Aid data

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global survey_data "$data/Survey Analysis"
global other_data "$data/Controls"
global clean_data "$data/Aid/01_Cleaned Data"
global geo_data2 "$data/Geo/gadm36_KEN_shp"
global spillover_data "$data/Geo/spillover"

clear all 


********************************************
***		 		MERGE MAIN DATA			 ***
********************************************

** Create main dataset with survey responses and aid 

clear all 

use "$survey_data/survey_final.dta", clear 

* Merge with aid data 
merge m:1 _ID year using "$survey_data/aid_survey_final_combined.dta"

*keep if _merge == 3 //to drop constituencies where there are no respondents 
drop _merge 

* Generate normalized money values 
gen mon_value_ch_million = mon_value_ch / 10000000 
gen mon_value_wb_million = mon_value_wb / 10000000 

* Generate transformation 
gen ln_mon_value_ch = ln(mon_value_ch + 1)
label var ln_mon_value_ch "Log(1+Monetary value China)"
gen ln_mon_value_wb = ln(mon_value_wb + 1)
label var ln_mon_value_wb "Log (1+Monetary value World Bank)"

gen ln_num_proj_ch = ln(num_projects_ch + 1)
label var ln_num_proj_ch "Log(1+Number of projects China)"
gen ln_num_proj_wb = ln(num_projects_wb + 1)
label var ln_num_proj_wb "Log(1+Number of projects World Bank)"

* Label 
label var num_projects_ch "Projects Stock"
label var num_projects_wb "Projects World Bank Stock"

label var mon_value_ch_million "Investment Stock"
label var mon_value_wb_million "Investment World Bank Stock"

label var ln_num_proj_ch "log(Projects) Stock"
label var ln_num_proj_wb "log(Projects World Bank) Stock"

label var ln_mon_value_ch "log(Investment) Stock"
label var ln_mon_value_wb "log(Investment World Bank) Stock"


save "$survey_data/survey_analysis_heter_donor.dta", replace 


****************************************************
***		 		MERGE SPILLOVER DATA			 ***
****************************************************

* Merge with spillover data 
merge m:1 _ID wave using "$spillover_data/aid_data_with_spillovers.dta"
drop _merge 

rename spillover_intensity spillover_intensity_proj
gen spillover_intensity_mon = spillover_mon_value /total_neighbors

** Label vars 
label var spillover_intensity_proj "Spillover Intensity Projects"
label var spillover_intensity_mon "Spillover Intensity Investment"


************************************************
***		 		MERGE CONTROL DATA			 ***
************************************************

** Merge main dataset with controls data 

merge m:1 _ID using "$clean_data/control_data_formerge.dta", 
drop _merge


************************************************
***		 		MERGE COUNTY DATA			 ***
************************************************

* Temporary var for merge 
gen constituencyname = upper(name_2)

replace constituencyname = "CHUKA IGAMBANG'OMBE" if constituencyname == "CHUKA/IGAMBANG'OMBE"
replace constituencyname = "DADAAB" if constituencyname == "DAADAB"
replace constituencyname = "LANG'ATA" if constituencyname == "LANGATA"
replace constituencyname = "SIGOWET SOIN" if constituencyname == "SIGOWET/SOIN"

* Merge to extract county info 
merge m:1 constituencyname using "$geo_data2/skeleton_county.dta"
drop _merge 

rename NAME_1 name_1 

** Generate county id 
encode name_1, gen(county_id) 


************************************************************
***		 		CLEANING & OUTCOMES GENERATION			 ***
************************************************************

* Binary treatment 
// think about construction 

** Generate controls
gen t = wave-2
global controls_const_by_year ///
c.luminosity_2002#c.t  c.time_tocity#c.t  c.pop_density_2000#c.t  c.slope#c.t

global controls_trend c.county_id#i.wave 


** Generate flow variables for stock analysis  

* Number of projects China 

sort _ID year

bys _ID: egen cum_proj_2003 = max(cond(year==2003, num_projects_ch, .))
bys _ID: egen cum_proj_2005 = max(cond(year==2005, num_projects_ch, .))
bys _ID: egen cum_proj_2008 = max(cond(year==2008, num_projects_ch, .))
bys _ID: egen cum_proj_2011 = max(cond(year==2011, num_projects_ch, .))
bys _ID: egen cum_proj_2014 = max(cond(year==2014, num_projects_ch, .))

gen flow_proj_ch = cum_proj_2003 if inrange(year, 2000, 2003)
replace flow_proj_ch = cum_proj_2005 - cum_proj_2003 if inrange(year, 2004, 2005)
replace flow_proj_ch = cum_proj_2008 - cum_proj_2005 if inrange(year, 2006, 2008)
replace flow_proj_ch = cum_proj_2011 - cum_proj_2008 if inrange(year, 2009, 2011)
replace flow_proj_ch = cum_proj_2014 - cum_proj_2011 if inrange(year, 2012, 2014)


* Number of projects World Bank  

sort _ID year

bys _ID: egen cum_proj_2003_wb = max(cond(year==2003, num_projects_wb, .))
bys _ID: egen cum_proj_2005_wb = max(cond(year==2005, num_projects_wb, .))
bys _ID: egen cum_proj_2008_wb = max(cond(year==2008, num_projects_wb, .))
bys _ID: egen cum_proj_2011_wb = max(cond(year==2011, num_projects_wb, .))
bys _ID: egen cum_proj_2014_wb = max(cond(year==2014, num_projects_wb, .))

gen flow_proj_wb = cum_proj_2003_wb if inrange(year, 2000, 2003)
replace flow_proj_wb = cum_proj_2005_wb - cum_proj_2003_wb if inrange(year, 2004, 2005)
replace flow_proj_wb = cum_proj_2008_wb - cum_proj_2005_wb if inrange(year, 2006, 2008)
replace flow_proj_wb = cum_proj_2011_wb - cum_proj_2008_wb if inrange(year, 2009, 2011)
replace flow_proj_wb = cum_proj_2014_wb - cum_proj_2011_wb if inrange(year, 2012, 2014)


* Monetary value China 

sort _ID year

bys _ID: egen cum_mon_2003 = max(cond(year==2003, mon_value_ch_million, .))
bys _ID: egen cum_mon_2005 = max(cond(year==2005, mon_value_ch_million, .))
bys _ID: egen cum_mon_2008 = max(cond(year==2008, mon_value_ch_million, .))
bys _ID: egen cum_mon_2011 = max(cond(year==2011, mon_value_ch_million, .))
bys _ID: egen cum_mon_2014 = max(cond(year==2014, mon_value_ch_million, .))

gen flow_mon_ch = cum_mon_2003 if inrange(year, 2000, 2003)
replace flow_mon_ch = cum_mon_2005 - cum_mon_2003 if inrange(year, 2004, 2005)
replace flow_mon_ch = cum_mon_2008 - cum_mon_2005 if inrange(year, 2006, 2008)
replace flow_mon_ch = cum_mon_2011 - cum_mon_2008 if inrange(year, 2009, 2011)
replace flow_mon_ch = cum_mon_2014 - cum_mon_2011 if inrange(year, 2012, 2014)


* Monetary value World Bank  

sort _ID year

bys _ID: egen cum_mon_2003_wb = max(cond(year==2003, mon_value_wb_million, .))
bys _ID: egen cum_mon_2005_wb = max(cond(year==2005, mon_value_wb_million, .))
bys _ID: egen cum_mon_2008_wb = max(cond(year==2008, mon_value_wb_million, .))
bys _ID: egen cum_mon_2011_wb = max(cond(year==2011, mon_value_wb_million, .))
bys _ID: egen cum_mon_2014_wb = max(cond(year==2014, mon_value_wb_million, .))

gen flow_mon_wb = cum_mon_2003_wb if inrange(year, 2000, 2003)
replace flow_mon_wb = cum_mon_2005_wb - cum_mon_2003_wb if inrange(year, 2004, 2005)
replace flow_mon_wb = cum_mon_2008_wb - cum_mon_2005_wb if inrange(year, 2006, 2008)
replace flow_mon_wb = cum_mon_2011_wb - cum_mon_2008_wb if inrange(year, 2009, 2011)
replace flow_mon_wb = cum_mon_2014_wb - cum_mon_2011_wb if inrange(year, 2012, 2014)


** Label vars 
label var flow_proj_ch "Projects Flow"
label var flow_proj_wb "Projects Flow World Bank"

label var flow_mon_ch "Investment Flow"
label var flow_mon_wb "Investment Flow World Bank"


** Generate leads and lags 
preserve

collapse (mean) flow_proj_ch flow_proj_wb flow_mon_ch flow_mon_wb, by(_ID wave)
 
xtset _ID wave

gen flow_proj_ch_l1 = L1.flow_proj_ch
gen flow_proj_ch_f1 = F1.flow_proj_ch

gen flow_proj_ch_l2 = L2.flow_proj_ch
gen flow_proj_ch_f2 = F2.flow_proj_ch

/* create "previous-observation" leads/lags (robust to gaps)
sort _ID wave
bysort _ID (wave): replace flow_proj_ch_l2 = flow_proj_ch[_n+2] if missing(flow_proj_ch_l2)
bysort _ID (wave): replace flow_proj_ch_f2 = flow_proj_ch[_n-2] if missing(flow_proj_ch_f2) */

gen flow_mon_ch_l1  = L1.flow_mon_ch
gen flow_mon_ch_f1  = F1.flow_mon_ch

gen flow_mon_ch_l2  = L2.flow_mon_ch
gen flow_mon_ch_f2  = F2.flow_mon_ch

keep flow_proj_ch_l1 flow_proj_ch_l2 flow_proj_ch_f1 flow_proj_ch_f2 flow_mon_ch_l1 flow_mon_ch_l2 flow_mon_ch_f1 flow_mon_ch_f2 _ID wave 

save "$survey_data/flow_leads_largs.dta", replace 

restore 


* Generate ever treated var 
bysort _ID: egen ever_treat_ch = max(num_projects_ch > 0)
bysort _ID: egen ever_treat_wb = max(num_projects_wb > 0)


* Merge them back to main data 
sort _ID wave

merge m:1 _ID wave using "$survey_data/flow_leads_largs.dta"


save "$survey_data/survey_analysis_heter_donor.dta", replace 


  