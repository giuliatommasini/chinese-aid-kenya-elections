********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Cleaning and saving of raw Survey Data - Wave 4 2008

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global data_input "$data/Afrobarometer/00_Raw Data"
global intermed_data "$data/Afrobarometer/01_Intermediary Data"
global survey_data "$data/Survey Analysis"
global geo_data "$data/Geo/gadm36_KEN_shp"


clear all 

********************************************************************************

* Import raw data 
import excel "$data_input/KEN_r4.xlsx", sheet("Sheet1") firstrow

sort respno


* Classify Do Not Know, Refuse to Say and Missing as missing values
ds q*, has(type string)
foreach v of varlist `r(varlist)' {
    destring `v', replace force
}

ds q*
foreach v of varlist `r(varlist)' {
    replace `v' = . if inlist(`v', 9, 98, 998, 999, 997, 9998, 9999, -1)
}


*******************************************************
/********** 		Define outcomes 	 	**********/
*******************************************************

** Close to which political party

*gen close_party_dum = q85	//close to political party dummy 
*gen close_party_name = q86	//close to political party which 


** Performance of politicians 

gen good_performance_pres = (q70a == 3 | q70a==4)	//performance: president  
gen good_performance_MP = (q70b == 3 | q70b==4)	//performance: MP/National Assembly rep.
gen good_performance_local = (q70c == 3 | q70c==4)	//performance: local government councilor

label var good_performance_pres "Positive evaluation of President's performance"
label var good_performance_MP "Positive evaluation of MP/National Assembly representative's performance"
label var good_performance_local "Positive evaluation of Local government councilor's performance"


** Trust 

gen trust_pres = (q49a==2 | q49a==3)	//trust president 
gen trust_MP = (q49b==2 | q49b==3)	//trust parliament/national assembly
gen trust_electoral = (q49c==2 | q49c==3)	//trust national electoral commission
gen trust_local = (q49d==2 | q49d==3)	//trust your elected local government council
gen trust_incumbent = (q49e==2 | q49e==3)	//trust the ruling party
gen trust_opposition = (q49f==2 | q49f==3)	//trust opposition political parties

label var trust_pres       "Trust in President"
label var trust_MP         "Trust in Parliament/National Assembly"
label var trust_electoral  "Trust in National Electoral Commission"
label var trust_local      "Trust in elected local government council"
label var trust_incumbent  "Trust in ruling party"
label var trust_opposition "Trust in opposition political parties"


** Satisfaction on central governemnt 

gen manage_economy = (q57a==3 | q57a==4)	//governement handling managing the economy
gen manage_poverty = (q57b==3 | q57b==4)	//governement handling improving living standards of the poor
gen manage_jobs = (q57c==3 | q57c==4)	//governement handling creating jobs
gen manage_pricesdown = (q57d==3 | q57d==4)	//governement handling keeping prices down
gen manage_incomegaps = (q57e==3 | q57e==4)	//governement handling narrowing income gaps
gen manage_crime = (q57f==3 | q57f==4)	//governement handling reducing crime
gen manage_health = (q57g==3 | q57g==4)	//governement handling improving basic health services
gen manage_educ = (q57h==3 | q57h==4)	//governement handling addressing educational needs
gen manage_water = (q57i==3 | q57i==4)	//governement handling providing water and sanitation services
gen manage_eat = (q57j==3 | q57j==4)	//governement handling ensuring enough to eat
gen manage_corruption = (q57k==3 | q57k==4)	//governement handling fighting corruption
gen manage_roads = (q57m==3 | q57m==4)	//governement handling and maintaining roads and bridges
gen manage_electricity = (q57n==3 | q57n==4)	//governement handling providing reliable electric supply

label variable manage_economy      "Govt handling: managing the economy"
label variable manage_poverty      "Govt handling: improving living standards of the poor"
label variable manage_jobs         "Govt handling: creating jobs"
label variable manage_pricesdown   "Govt handling: keeping prices down"
label variable manage_incomegaps   "Govt handling: narrowing income gaps"
label variable manage_crime        "Govt handling: reducing crime"
label variable manage_health       "Govt handling: improving basic health services"
label variable manage_educ         "Govt handling: addressing educational needs"
label variable manage_water        "Govt handling: providing water and sanitation services"
label variable manage_eat          "Govt handling: ensuring enough to eat"
label variable manage_corruption   "Govt handling: fighting corruption"
label variable manage_roads        "Govt handling: maintaining roads/bridges"
label variable manage_electricity  "Govt handling: providing reliable electricity supply"


** Involvement in politics 

gen interest_publicaff = (q13==2 | q13 ==3) //interest in public affairs

label variable interest_publicaff  "Interest in public affairs"


** Presence of services in locality 

gen tecn_services = (ea_svc_a==1 | ea_svc_b==1 | ea_svc_c==1) //electricity grid or piped water system or sewage system in the PSU/EA
gen cell_services = (ea_svc_d==1)	//cell phone service in the PSU/EA
gen school = (ea_fac_b==1)	//school in the PSU/EA
gen health_facility = (ea_fac_d==1)	//health clinic in the PSU/EA
gen market_stalls = (ea_fac_e==1)	//market stalls in the PSU/EA
gen road = (ea_road ==1)	//tarred/paved road in the PSU/EA

label variable tecn_services   "Electricity, piped water, or sewage system present in locality"
label variable cell_services   "Cell phone service present in locality"
label variable school          "School present in locality"
label variable health_facility "Health clinic present in locality"
label variable market_stalls   "Market stalls present in locality"
label variable road            "Tarred/paved road present in locality"


** Services / basic living conditions in family

gen without_food = (q8a==2 | q8a==3 | q8a==4)	//how often gone without food
gen without_water = (q8b==2 | q8b==3 | q8b==4)	//how often gone without water
gen withou_med = (q8c==2 | q8c==3 | q8c==4)	//how often gone without medical care
gen withou_fuel = (q8d==2 | q8d==3 | q8d==4)	//how often gone without cooking fuel
gen withou_cash = (q8e==2 | q8e==3 | q8e==4)	//how often gone without a cash income

label variable without_food "Household gone without food"
label variable without_water "Household gone without water"
label variable withou_med    "Household gone without medical care"
label variable withou_fuel   "Household gone without cooking fuel"
label variable withou_cash   "Household gone without cash income"


** Economic conditions in the country  

gen improved_econ_conditions_country = (q6a == 4 | q6a == 5)	//country's economic condition wrt 12 months ago
gen exp_econ_conditions_country = (q7a == 4 | q7a == 5)	//country's expected economic condition in 12 months 
gen econ_conditions_country = (q4a == 4 | q4a==5)	//country's present economic conditions
gen econ_conditions_me = (q4b ==4 | q4b==5)	//your present living conditions
gen econ_conditions_me_other = (q5 ==4 | q5==5)	//your living conditions vs. others

label variable improved_econ_conditions "Economic conditions with respect to 12 months ago"
label variable exp_econ_conditions_country "Expected economic conditions in 12 months"
label variable econ_conditions_country  "Current economic conditions in the country (positive)"
label variable econ_conditions_me       "Respondent's present living conditions (positive)"
label variable econ_conditions_me_other "Respondent's living conditions vs others (positive)"


** Freedom

* Freedom of speech 
gen free_speech = (q15a==3 | q15a==4)	//freedom to say what you think
label var free_speech "Freedom of Speech"

* Freedom of political association
gen free_polorg = (q15b==3 | q15b==4)	//freedom to join any political organization 
label var free_polorg "Freedom of Political Association"

* Freedom of electoral choice 
gen free_vote = (q15c==3 | q15c==4)	//freedom to choose who to vote for
label var free_vote "Freedom of Electoral Choice"


** Democracy index 

* Demand for democracy 
gen demand_democracy = (q30==3 & (q29a==1 | q29a==2) & (q29b==1 | q29b==2) & (q29c==1 | q29c==2))	//support for democracy and reject one-party rule and reject military rule
label var demand_democracy "Demand for Democracy"

* Supply for democracy 
gen supply_democracy_raw = (q42a==3 | q42a==4)	//extent of democracy 
replace supply_democracy_raw = . if q42a==8
label var supply_democracy_raw "Perceived Extent of Democracy"
gen supply_democracy_sat = (q43==3 | q43==4)	//satisfaction with democracy
label var supply_democracy_sat "Satisfied with Democracy"
gen supply_democracy = (supply_democracy_raw==1 & supply_democracy_sat==1)
label var supply_democracy "Supply for Democracy"

* Dissatisfaction with democracy
gen dissatisfied_dem = (demand_democracy==1 & supply_democracy==0 & supply_democracy_sat==0)
label var dissatisfied_dem "Dissatisfied Democrat"

* Democracy and rule of law support coding 
gen d32 = inlist(q31,1,2)   // elections
gen d33 = inlist(q32,3,4)   // many parties
gen d34 = inlist(q33,1,2)   // parliament oversight
gen d35 = inlist(q34,1,2)   // opposition monitors
gen d36 = inlist(q35,1,2)   // media investigates
gen d37 = inlist(q36,1,2)   // parliament makes laws
gen d38 = inlist(q37,3,4)   // president obeys law
gen d39 = inlist(q38,1,2)   // two-term limit

egen demo_score = rowtotal(d32 d33 d34 d35 d36 d37 d38 d39)	

gen rulelaw_dem_dummy = demo_score >= 5	//supportive if they agree with at least 5 out of 8 principles 
label var rulelaw_dem_dummy "Support for Democracy & Rule of Law"


** China index 

gen china_help = (q98h==2 | q98h==3) //how much help country: China
replace china_help = . if q98h==4
label var china_help "China Helpful"


** Media exposure

* Radio news 
gen radio_news = (q12a==3 | q12a==4)

* Television news 
gen tv_news = (q12b==3 | q12b==4)

* Newspaper news 
gen paper_news = (q12c==3 | q12c==4)


** Corruption perception 

* Office of president 
gen corruption_pres = (q50a==2 | q50a==3) //how many people in president office involved in corruption 

* Members of parliament 
gen corruption_mp = (q50b==2 | q50b==3) //how many MP involved in corruption 

* Governement local councilors 
gen corruption_counc = (q50c==2 | q50c==3) //how many governement councilors involved in corruption 

* Government officials 
gen corruption_off = (q50d==2 | q50d==3) //how many governement officials involved in corruption 


** Controls 

gen age = q1 
label var age "Age"
gen language = q114
label var language "Home Language"
gen gender = (q3==1)
label var gender "Gender"
gen rural = (urbrur==2)
label var rural "Rural Primary Sampling Unit"
gen educ = q89
label var educ "Highest Level of Education"
gen race = q102
label var race "Race"
gen religion = q90 
label var religion "Religion"
gen tribe = q79 
label var tribe "Ethnic Group"
gen employment = q94
label var employment "Employment status"


save "$intermed_data/Wave4", replace 


** Define constituency for each individual based on coordinates

geoinpoly latitude longitude using "$geo_data/kenya_coords.dta" 


** Keep only variables of interest 

drop q* ea_* nocall_*

gen year = 2007

count if _ID == . 

save "$survey_data/Wave4_const.dta", replace 
