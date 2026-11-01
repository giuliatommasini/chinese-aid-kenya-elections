********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Merge electoral data with spillovers and controls (part 2, after 04_electoral_spillovers.py)

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

****************************************************
***		 		MERGE SPILLOVER DATA			 ***
****************************************************

use "$spillover_data/electoral_with_spillovers.dta", clear 

keep spillover_num_projects spillover_mon_value spillover_intensity_projects spillover_intensity_value constituencyname period

* Merge with spillover data 
merge 1:1 constituencyname period using "$electoral_data/electoral_analysis_heter_donor.dta"
drop _merge 


* Lable variables 
label var spillover_intensity_projects "Intensity Spillover Number of Projects China"
label var spillover_intensity_value "Intensity Spillover Monetary Value China"


* Generate tranformation 
gen ln_spillover_intensity_projects = ln(spillover_intensity_projects + 1)
label var ln_spillover_intensity_projects "Log(1+Intensity Spillover Number of Projects China)"

gen ln_spillover_intensity_value = ln(spillover_intensity_value + 1)
label var ln_spillover_intensity_projects "Log(1+Intensity Spillover Monetary Value China)"



save "$electoral_data/electoral_analysis_heter_donor.dta", replace 


************************************************
***		 		MERGE CONTROL DATA			 ***
************************************************

** Merge main dataset with controls data 

clear all 

import delimited "$other_data/controls.csv"

* Cleaning for consistency with electoral data 
replace shapename = "Bureti" if shapename == "Buret"
replace shapename = "Central Imenti" if shapename == "Cental Imenti"
replace shapename = "Dagoretti South" if shapename=="Dagoretti"
replace shapename = "Garissa Township" if shapename== "Dujis"
replace shapename = "Mbeere South" if shapename== "Gachoka"
replace shapename = "Homa Bay Town" if shapename== "Homa Bay"
replace shapename = "Dagoretti North" if shapename== "Kilimani"
replace shapename = "Lang'ata" if shapename== "Langata"
replace shapename = "Lungalunga" if shapename== "Lunga Lunga"
replace shapename = "Mukurweini" if shapename== "Mukurweni"
replace shapename = "MWINGI CENTRAL" if shapename=="Mwingi East"
replace shapename = "CHUKA IGAMBANG'OMBE" if shapename== "Nithi"
replace shapename = "Mbeere North" if shapename== "Siakago"
replace shapename = "Sigowet Soin" if shapename== "Sigowet/Soin"
replace shapename = "Mbita" if shapename== "Suba North"
replace shapename = "Suba" if shapename== "Suba South"

* Adjusting name to be consistent with electoral analysis 
gen constituencyname = upper(shapename)

merge 1:m constituencyname using "$electoral_data/electoral_analysis_heter_donor.dta"
drop _merge 

* Cleaning 
rename v9 luminosity_2012
rename gpw_v4_rev11_density2010mean pop_density_2010
rename access_50knonemean time_tocity
rename dist_to_groadsnonemean distance_road
rename srtm_slope_500mnonemean slope 
rename plad_v70_leader_birthplace2012ma presence_leader_birthplace2012


************************************************
***		 		MERGE COUNTY DATA			 ***
************************************************

* Merge to extract county info 
merge m:1 constituencyname using "$geo_data2/skeleton_county.dta"
drop _merge 

rename NAME_1 countyname 

** Generate county X Post 
encode countyname, gen(county_id)
gen interaction_county = county_id * Post 


************************************************************
***		 		CLEANING & OUTCOMES GENERATION			 ***
************************************************************

** Generate flow variables 
* Number of projects 
gen num_projects_china_flow = num_projects_china if Post == 1
replace num_projects_china_flow = 0 if Post == 0 

gen num_projects_wb_flow = num_projects_wb if Post == 1
replace num_projects_wb_flow = 0 if Post == 0 

* Number of projects logarithmic transformation 
gen ln_num_projects_ch_flow = ln_num_proj_ch if Post == 1
replace ln_num_projects_ch_flow = 0 if Post == 0 

gen ln_num_projects_wb_flow = ln_num_proj_wb if Post == 1
replace ln_num_projects_wb_flow = 0 if Post == 0

* Monetary value normalized  
gen mon_value_ch_flow = mon_value_ch_million if Post == 1
replace  mon_value_ch_flow = 0 if Post == 0 

gen mon_value_wb_flow = mon_value_wb_million if Post == 1
replace  mon_value_wb_flow = 0 if Post == 0 

* Monetary value logarithmic transformation 
gen ln_mon_value_ch_flow = ln_mon_value_ch if Post == 1
replace  ln_mon_value_ch_flow = 0 if Post == 0 

gen ln_mon_value_wb_flow = ln_mon_value_wb if Post == 1
replace  ln_mon_value_wb_flow = 0 if Post == 0 

* Binary treatment 
bys constituencyname: egen treat_ch_flow = max((num_projects_china != 0) & (Post == 1))
replace treat_ch_flow = 0 if Post ==0

bys constituencyname: egen treat_wb_flow = max((num_projects_wb != 0) & (Post == 1))
replace treat_wb_flow = 0 if Post == 0 

* Spillovers - CONTINUOUS FLOW (not binary!)
gen spillover_proj_flow = spillover_intensity_projects if Post == 1
replace spillover_proj_flow = 0 if Post == 0

gen spillover_mon_flow = spillover_intensity_value if Post == 1
replace spillover_mon_flow = 0 if Post == 0

* Spillovers logarithmic transformation
gen ln_spillover_proj_flow = ln_spillover_intensity_projects if Post == 1
replace ln_spillover_proj_flow = 0 if Post == 0

gen ln_spillover_mon_flow = ln_spillover_intensity_value if Post == 1
replace ln_spillover_mon_flow = 0 if Post == 0


** Create interactions - flow 

* Number of projects 
gen interaction_proj_ch = num_projects_china_flow * Post 
gen interaction_proj_wb = num_projects_wb_flow * Post 

* Number of projects logarithmic transformation 
gen interaction_ln_proj_ch = ln_num_projects_ch_flow * Post 
gen interaction_ln_proj_wb = ln_num_projects_wb_flow * Post 

* Monetary value normalized  
gen interaction_mon_ch = mon_value_ch_flow * Post 
gen interaction_mon_wb = mon_value_wb_flow * Post 

* Monetary value logarithmic transformation 
gen interaction_ln_mon_ch = ln_mon_value_ch_flow * Post 
gen interaction_ln_mon_wb = ln_mon_value_wb_flow * Post 

* Binary treatment 
gen interaction_treat_ch = treat_ch_flow * Post
gen interaction_treat_wb = treat_wb_flow * Post

* Spillovers 
gen interaction_spillover_proj = spillover_proj_flow * Post
gen interaction_spillover_mon = spillover_mon_flow * Post

* Spillovers logarithmic transformation 
gen interaction_ln_spillover_proj = ln_spillover_proj_flow * Post
gen interaction_ln_spillover_mon = ln_spillover_mon_flow * Post


** Construct pre and post variables 

* Number of projects 
bys constituencyname: egen num_proj_ch_pre = max(cond(Post == 0, num_projects_china, .))
bys constituencyname: egen num_proj_ch_post = max(cond(Post == 1, num_projects_china, .))

bys constituencyname: egen num_proj_wb_pre = max(cond(Post == 0, num_projects_wb, .))
bys constituencyname: egen num_proj_wb_post = max(cond(Post == 1, num_projects_wb, .))

* Number of projects logarithmic transformation 
bys constituencyname: egen ln_num_proj_ch_pre = max(cond(Post == 0, ln_num_proj_ch, .))
bys constituencyname: egen ln_num_proj_ch_post = max(cond(Post == 1, ln_num_proj_ch, .))

bys constituencyname: egen ln_num_proj_wb_pre = max(cond(Post == 0, ln_num_projects_wb, .))
bys constituencyname: egen ln_num_proj_wb_post = max(cond(Post == 1, ln_num_projects_wb, .))

* Monetary value normalized 
bys constituencyname: egen mon_value_ch_million_pre = max(cond(Post == 0, mon_value_ch_million, .))
bys constituencyname: egen mon_value_ch_million_post = max(cond(Post == 1, mon_value_ch_million, .))

bys constituencyname: egen mon_value_wb_million_pre = max(cond(Post == 0, mon_value_wb_million, .))
bys constituencyname: egen mon_value_wb_million_post = max(cond(Post == 1, mon_value_wb_million, .))

* Monetary value logarithmic transformation  
bys constituencyname: egen ln_mon_value_ch_pre = max(cond(Post == 0, ln_mon_value_ch, .))
bys constituencyname: egen ln_mon_value_ch_post = max(cond(Post == 1, ln_mon_value_ch, .))

bys constituencyname: egen ln_mon_value_wb_pre = max(cond(Post == 0, ln_mon_value_wb, .))
bys constituencyname: egen ln_mon_value_wb_post = max(cond(Post == 1, ln_mon_value_wb, .))

* Binary treatment 
bys constituencyname: egen treat_ch_pre = max(cond(Post == 0, ever_china_aid, .))
bys constituencyname: egen treat_ch_post = max(cond(Post == 1, treat_ch_flow, .))

bys constituencyname: egen treat_wb_pre = max(cond(Post == 0, ever_wb_aid, .))
bys constituencyname: egen treat_wb_post = max(cond(Post == 1, treat_wb_flow, .))

* Spillovers 
bys constituencyname: egen spillover_proj_pre = max(cond(Post == 0, spillover_intensity_projects, .)) 
bys constituencyname: egen spillover_mon_pre = max(cond(Post == 0, spillover_intensity_value, .)) 

* Spillovers logarithmic transformation 
bys constituencyname: egen ln_spillover_proj_pre = max(cond(Post == 0, ln_spillover_intensity_projects, .)) 
bys constituencyname: egen ln_spillover_mon_pre = max(cond(Post == 0, ln_spillover_intensity_value, .)) 


** Create interactions - pre 

* Number of projects 
gen interaction_proj_ch_pre = num_proj_ch_pre * Post 
gen interaction_proj_wb_pre = num_proj_wb_pre * Post 

* Number of projects logarithmic transformation  
gen interaction_ln_proj_ch_pre = ln_num_proj_ch_pre * Post 
gen interaction_ln_proj_wb_pre = ln_num_proj_wb_pre * Post 

* Monetary value normalized  
gen interaction_mon_ch_pre = mon_value_ch_million_pre * Post 
gen interaction_mon_wb_pre = mon_value_wb_million_pre * Post 

* Monetary value logarithmic transformation   
gen interaction_ln_mon_ch_pre = ln_mon_value_ch_pre * Post  
gen interaction_ln_mon_wb_pre = ln_mon_value_wb_pre * Post  

* Binary treatment 
gen interaction_treat_ch_pre = treat_ch_pre * Post
gen interaction_treat_wb_pre = treat_wb_pre * Post

* Spillovers
gen interaction_spillover_proj_pre = spillover_proj_pre * Post 
gen interaction_spillover_mon_pre = spillover_mon_pre * Post 

* Spillovers logarithmic transformation
gen interaction_ln_spill_proj_pre = ln_spillover_proj_pre * Post 
gen interaction_ln_spill_mon_pre = ln_spillover_mon_pre * Post 


** Generate controls 

* Margin of victory 
bys constituencyname: egen margin_victory_pre = max(cond(Post == 0, margin_victory, .))
gen interaction_mv = margin_victory_pre * Post 

* Luminosity
gen interaction_lum = luminosity_2012 * Post 

* Road presence 
gen interaction_road = distance_road * Post

* Population density 
gen interaction_den = pop_density_2010 * Post 

* Time to reach city 
gen interaction_timetocity = time_tocity * Post 

* Slope of territory 
gen interaction_slope = slope * Post 


** Label variables 
label var num_projects_china_flow "Chinese exposure - Projects"
label var num_projects_wb_flow "World Bank exposure - Projects"
label var ln_num_projects_ch_flow "Log(1+Chinese exposure - Projects)"
label var ln_num_projects_wb_flow "Log(1+World Bank exposure - Projects)"
label var mon_value_ch_flow "Chinese exposure - Monetary value"
label var mon_value_wb_flow "World Bank exposure - Monetary value"
label var ln_mon_value_ch_flow "Log(1+Chinese exposure - Monetary value)"
label var ln_mon_value_wb_flow "Log(1+World Bank exposure - Monetary value)"

label var interaction_proj_ch "Projects $\times$  Post"
label var interaction_proj_wb "Projects World Bank $\times$  Post"
label var interaction_ln_proj_ch "log(Projects) $\times$  Post"
label var interaction_ln_proj_wb "log(Projects World Bank) $\times$  Post"
label var interaction_mon_ch "Investment $\times$  Post"
label var interaction_mon_wb "Investment World Bank $\times$  Post"
label var interaction_ln_mon_ch "log(Investment) $\times$  Post"
label var interaction_ln_mon_wb "log(Investment World Bank) $\times$  Post"
label var interaction_treat_ch "Received Funds $\times$  Post"
label var interaction_treat_wb "Received Funds WB $\times$  Post"

label var interaction_proj_ch_pre "Pre Number of Projects * Post"
label var interaction_proj_wb_pre "Pre Number of Projects WB * Post"
label var interaction_ln_proj_ch_pre "Pre Log(1+Number of Projects) * Post"
label var interaction_ln_proj_wb_pre "Pre Log(1+Number of Projects) WB * Post"
label var interaction_mon_ch_pre "Pre Monetary Value * Post"
label var interaction_mon_wb_pre "Pre Monetary Value WB * Post"
label var interaction_ln_mon_ch_pre "Pre Log(1+Monetary Value) * Post"
label var interaction_ln_mon_wb_pre "Pre Log(1+Monetary Value WB) * Post"

label var interaction_spillover_proj "Spillover Intensity Projects $\times$ Post"
label var interaction_spillover_mon "Spillover Intensity Investment $\times$ Post"
label var interaction_ln_spillover_proj "log(Spillover Intensity Projects) $\times$ Post"
label var interaction_ln_spillover_mon "log(Spillover Intensity Investment) $\times$ Post"

label var num_proj_ch_post "Future Projects"
label var ln_num_proj_ch_post "log(Future Projects)"
label var mon_value_ch_million_post "Future Investment"
label var ln_mon_value_ch_post "log(Future Investment)"


* Save cleaned dataset 
save "$electoral_data/electoral_analysis_heter_donor.dta", replace 
