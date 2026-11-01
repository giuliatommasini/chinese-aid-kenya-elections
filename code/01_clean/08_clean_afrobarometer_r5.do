********************************************************************************

* Author: Giulia 
* Date Created: January 2026 
* Purpose: Cleaning and saving of raw Survey Data - Wave 5 2011

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
import excel "$data_input/KEN_r5.xlsx", sheet("Sheet1") firstrow

sort respno


* Classify Do Not Know, Refuse to Say and Missing as missing values
ds q*, has(type string)
foreach v of varlist `r(varlist)' {
    destring `v', replace force
}

ds q*
foreach v of varlist `r(varlist)' {
    replace `v' = . if inlist(`v', 9, 99, 998, 999, 9998, 9999, 997, -1)
}


*******************************************************
/********** 		Define outcomes 	 	**********/
*******************************************************

** Close to which political party

*gen close_party_dum = q89a	//close to political party dummy 
*gen close_party_name = q89b	//close to political party which 


** Performance of politicians 

gen good_performance_pres = (q71a == 3 | q71a==4)	//performance: president  
gen good_performance_MP = (q71b == 3 | q71b==4)	//performance: MP/National Assembly rep.
gen good_performance_local = (q71c == 3 | q71c==4)	//performance: local government councilor

label var good_performance_pres "Positive evaluation of President's performance"
label var good_performance_MP "Positive evaluation of MP/National Assembly representative's performance"
label var good_performance_local "Positive evaluation of Local government councilor's performance"


** Trust 

gen trust_pres = (q59a==2 | q59a==3)	//trust president 
gen trust_MP = (q59b==2 | q59b==3)	//trust parliament/national assembly
gen trust_electoral = (q59c==2 | q59c==3)	//trust national electoral commission
gen trust_local = (q59e==2 | q59e==3)	//trust your elected local government council
gen trust_incumbent = (q59f==2 | q59f==3)	//trust the ruling party
gen trust_opposition = (q59g==2 | q59g==3)	//trust opposition political parties

label var trust_pres       "Trust in President"
label var trust_MP         "Trust in Parliament/National Assembly"
label var trust_electoral  "Trust in National Electoral Commission"
label var trust_local      "Trust in elected local government council"
label var trust_incumbent  "Trust in ruling party"
label var trust_opposition "Trust in opposition political parties"


** Satisfaction on central governemnt 

gen manage_economy = (q65a==3 | q65a==4)	//government handling managing the economy
gen manage_poverty = (q65b==3 | q65b==4)	//government handling improving living standards of the poor
gen manage_jobs = (q65c==3 | q65c==4)	//government handling creating jobs
gen manage_pricesdown = (q65d==3 | q65d==4)	//government handling keeping prices down
gen manage_incomegaps = (q65e==3 | q65e==4)	//government handling narrowing income gaps
gen manage_crime = (q65f==3 | q65f==4)	//government handling reducing crime
gen manage_health = (q65g==3 | q65g==4)	//government handling improving basic health services
gen manage_educ = (q65h==3 | q65h==4)	//government handling addressing educational needs
gen manage_water = (q65i==3 | q65i==4)	//government handling providing water and sanitation services
gen manage_eat = (q65j==3 | q65j==4)	//government handling ensuring enough to eat
gen manage_corruption = (q65k==3 | q65k==4)	//government handling fighting corruption
gen manage_roads = (q65n==3 | q65n==4)	//government handling and maintaining roads and bridges
gen manage_electricity = (q65o==3 | q65o==4)	//government handling providing reliable electric supply

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

gen interest_publicaff = (q14==2 | q14 ==3) //interest in public affairs

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

gen improved_econ_conditions_country = (q5a == 4 | q5a == 5)	//country's economic condition wrt 12 months ago
gen exp_econ_conditions_country = (q6a == 4 | q6a == 5)	//country's expected economic condition in 12 months 
gen econ_conditions_country = (q3a == 4 | q3a==5)	//country's present economic conditions
gen econ_conditions_me = (q3b ==4 | q3b==5)	//your present living conditions
gen econ_conditions_me_other = (q4 ==4 | q4==5)	//your living conditions vs. others

label variable improved_econ_conditions "Economic conditions with respect to 12 months ago"
label variable exp_econ_conditions_country "Expected economic conditions in 12 months"
label variable econ_conditions_country  "Current economic conditions in the country (positive)"
label variable econ_conditions_me       "Respondent's present living conditions (positive)"
label variable econ_conditions_me_other "Respondent's living conditions vs others (positive)"


** Freedom

* Freedom of speech 
gen free_speech = (q17a==3 | q17a==4)	//freedom to say what you think
label var free_speech "Freedom of Speech"

* Freedom of political association
gen free_polorg = (q17b==3 | q17b==4)	//freedom to join any political organization 
label var free_polorg "Freedom of Political Association"

* Freedom of electoral choice 
gen free_vote = (q17c==3 | q17c==4)	//freedom to choose who to vote for
label var free_vote "Freedom of Electoral Choice"


** Democracy index 

* Demand for democracy 
gen demand_democracy = (q32==3 & (q31a==1 | q31a==2) & (q31b==1 | q31b==2) & (q31c==1 | q31c==2))	//support for democracy and reject one-party rule and reject military rule
label var demand_democracy "Demand for Democracy"

* Supply for democracy 
gen supply_democracy_raw = (q42==3 | q42==4)	//extent of democracy 
replace supply_democracy_raw = . if q42==8
label var supply_democracy_raw "Perceived Extent of Democracy"
gen supply_democracy_sat = (q43==3 | q43==4)	//satisfaction with democracy
label var supply_democracy_sat "Satisfied with Democracy"
gen supply_democracy = (supply_democracy_raw==1 & supply_democracy_sat==1)
label var supply_democracy "Supply for Democracy"

* Dissatisfaction with democracy
gen dissatisfied_dem = (demand_democracy==1 & supply_democracy==0 & supply_democracy_sat==0)
label var dissatisfied_dem "Dissatisfied Democrat"

* Democracy and rule of law support coding 
gen d32 = inlist(q34,1,2)   // elections
gen d33 = inlist(q35,3,4)   // many parties
gen d34 = inlist(q36,1,2)   // parliament oversight
gen d35 = inlist(q37,1,2)   // opposition monitors
gen d36 = inlist(q38,1,2)   // media investigates
gen d37 = inlist(q39,1,2)   // parliament makes laws
gen d38 = inlist(q40,3,4)   // president obeys law
gen d39 = inlist(q41,1,2)   // two-term limit

egen demo_score = rowtotal(d32 d33 d34 d35 d36 d37 d38 d39)	

gen rulelaw_dem_dummy = demo_score >= 5	//supportive if they agree with at least 5 out of 8 principles 
label var rulelaw_dem_dummy "Support for Democracy & Rule of Law"

* Intention of voting 
* q99


** Media exposure

* Radio news 
gen radio_news = (q13a==3 | q13a==4)

* Television news 
gen tv_news = (q13b==3 | q13b==4)

* Newspaper news 
gen paper_news = (q13c==3 | q13c==4)


** Corruption perception 

* Office of president 
gen corruption_pres = (q60a==2 | q60a==3) //how many people in president office involved in corruption 

* Members of parliament 
gen corruption_mp = (q60b==2 | q60b==3) //how many MP involved in corruption 

* Governement local councilors 
gen corruption_counc = (q60d==2 | q60d==3) //how many governement councilors involved in corruption 

* Government officials 
gen corruption_off = (q60c==2 | q60c==3) //how many governement officials involved in corruption 


** Controls 

gen age = q1 
label var age "Age"
gen language = q2
label var language "Home Language"
gen gender = (q101==1)
label var gender "Gender"
gen rural = (urbrur==2)
label var rural "Rural Primary Sampling Unit"
gen educ = q97
label var educ "Highest Level of Education"
gen race = q102
label var race "Race"
gen religion = q98a 
label var religion "Religion"
gen tribe = q84 
label var tribe "Ethnic Group"
gen employment = q96
label var employment "Employment status"


save "$intermed_data/Wave5", replace 


** Define constituency for each individual based on coordinates

geoinpoly latitude longitude using "$geo_data/kenya_coords.dta" 


** Keep only variables of interest 

drop q* ea_* nocall_*

gen year = 2010

count if _ID == . 

* Cleaning 
replace _ID = 194 if latitude == -4.0609798 & longitude == 39.644821 
replace _ID = 134 if latitude == -1.3166699 & longitude == 34.583328
replace _ID = 189 if latitude == 1.13 & longitude == 34.549999


save "$survey_data/Wave5_const.dta", replace 
