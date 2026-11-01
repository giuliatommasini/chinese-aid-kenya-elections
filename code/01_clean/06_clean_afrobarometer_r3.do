********************************************************************************

* Author: Giulia 
* Date Created: January 2026 
* Purpose: Cleaning and saving of raw Survey Data - Wave 3 2005

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
import excel "$data_input/KEN_r3.xlsx", sheet("Sheet1") firstrow

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

gen good_performance_pres = (q68a == 3 | q68a==4)	//performance: president  
gen good_performance_MP = (q68b == 3 | q68b==4)	//performance: MP/National Assembly rep.
gen good_performance_local = (q68c == 3 | q68c==4)	//performance: local government councilor

label var good_performance_pres "Positive evaluation of President's performance"
label var good_performance_MP "Positive evaluation of MP/National Assembly representative's performance"
label var good_performance_local "Positive evaluation of Local government councilor's performance"


** Trust 

gen trust_pres = (q55a==2 | q55a==3)	//trust president 
gen trust_MP = (q55b==2 | q55b==3)	//trust parliament/national assembly
gen trust_electoral = (q55c==2 | q55c==3)	//trust national electoral commission
gen trust_local = (q55d==2 | q55d==3)	//trust your elected local government council
gen trust_incumbent = (q55e==2 | q55e==3)	//trust the ruling party
gen trust_opposition = (q55f==2 | q55f==3)	//trust opposition political parties

label var trust_pres       "Trust in President"
label var trust_MP         "Trust in Parliament/National Assembly"
label var trust_electoral  "Trust in National Electoral Commission"
label var trust_local      "Trust in elected local government council"
label var trust_incumbent  "Trust in ruling party"
label var trust_opposition "Trust in opposition political parties"


** Satisfaction on central governemnt 

gen manage_economy = (q65a==3 | q65a==4)	//governement handling managing the economy
* missing	//governement handling improving living standards of the poor
gen manage_jobs = (q65b==3 | q65b==4)	//governement handling creating jobs
gen manage_pricesdown = (q65c==3 | q65c==4)	//governement handling keeping prices down
gen manage_incomegaps = (q65d==3 | q65d==4)	//governement handling narrowing income gaps
gen manage_crime = (q65e==3 | q65e==4)	//governement handling reducing crime
gen manage_health = (q65f==3 | q65f==4)	//governement handling improving basic health services
gen manage_educ = (q65g==3 | q65g==4)	//governement handling addressing educational needs
gen manage_water = (q65h==3 | q65h==4)	//governement handling providing water and sanitation services
gen manage_eat = (q65i==3 | q65i==4)	//governement handling ensuring enough to eat
gen manage_corruption = (q65j==3 | q65j==4)	//governement handling fighting corruption
gen manage_roads = (q67a==3 | q67a==4)	//governement handling and maintaining roads and bridges
* missing	//governement handling providing reliable electric supply

label variable manage_economy      "Govt handling: managing the economy"
*label variable manage_poverty      "Govt handling: improving living standards of the poor"
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
*label variable manage_electricity  "Govt handling: providing reliable electricity supply"


** Involvement in politics 

gen interest_publicaff = (q16==2 | q16 ==3) //interest in public affairs

label variable interest_publicaff  "Interest in public affairs"


** Presence of services in locality 

gen tecn_services = (q116d==1 | q116e==1 | q116f==1) //electricity grid or piped water system or sewage system in the PSU/EA
* missing	//cell phone service in the PSU/EA
gen school = (q116b==1)	//school in the PSU/EA
gen health_facility = (q116g==1)	//health clinic in the PSU/EA
gen market_stalls = (q116k==1)	//market stalls in the PSU/EA
gen road = (q118 ==1)	//tarred/paved road in the PSU/EA

label variable tecn_services   "Electricity, piped water, or sewage system present in locality"
*label variable cell_services   "Cell phone service present in locality"
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


** Freedom //different! 

* Freedom of speech 
gen free_speech = (q54a==3 | q54a==4)	//freedom to say what you think wrt before
label var free_speech "Freedom of Speech"

* Freedom of political association
gen free_polorg = (q54b==3 | q54b==4)	//freedom to join any political organization wrt before
label var free_polorg "Freedom of Political Association"

* Freedom of electoral choice 
gen free_vote = (q54c==3 | q54c==4)	//freedom to choose who to vote wrt before
label var free_vote "Freedom of Electoral Choice"


** Democracy index 

* Demand for democracy 
gen demand_democracy = (q37==3 & (q36a==1 | q36a==2) & (q36b==1 | q36b==2) & (q36c==1 | q36c==2))	//support for democracy and reject one-party rule and reject military rule
label var demand_democracy "Demand for Democracy"

* Supply for democracy 
gen supply_democracy_raw = (q46==3 | q46==4)	//extent of democracy 
replace supply_democracy_raw = . if q46==8
label var supply_democracy_raw "Perceived Extent of Democracy"
gen supply_democracy_sat = (q47==3 | q47==4)	//satisfaction with democracy
label var supply_democracy_sat "Satisfied with Democracy"
gen supply_democracy = (supply_democracy_raw==1 & supply_democracy_sat==1)
label var supply_democracy "Supply for Democracy"

* Dissatisfaction with democracy //different! 
gen dissatisfied_dem = (demand_democracy==1 & supply_democracy==0 & supply_democracy_sat==0)
label var dissatisfied_dem "Dissatisfied Democrat"

* Democracy and rule of law support coding 
gen d32 = inlist(q38,1,2)   // elections
gen d33 = inlist(q39,3,4)   // many parties
*gen d34 = inlist(q40,1,2)   // parliament oversight
*gen d35 = inlist(q,1,2)   // opposition monitors
*gen d36 = inlist(q42,1,2)   // media investigates
gen d37 = inlist(q40,1,2)   // parliament makes laws
gen d38 = inlist(q41,3,4)   // president obeys law
*gen d39 = inlist(q45,1,2)   // two-term limit

egen demo_score = rowtotal(d32 d33 d37 d38)	

gen rulelaw_dem_dummy = demo_score >= 2	//supportive if they agree with at least 2 out of 4 principles 
label var rulelaw_dem_dummy "Support for Democracy & Rule of Law"


** Media exposure

* Radio news 
gen radio_news = (q15a==3 | q15a==4)

* Television news 
gen tv_news = (q15b==3 | q15b==4)

* Newspaper news 
gen paper_news = (q15c==3 | q15c==4)


** Corruption perception 

* Office of president 
gen corruption_pres = (q56a==2 | q56a==3) //how many people in president office involved in corruption 

* Members of parliament 
gen corruption_mp = (q56b==2 | q56b==3) //how many MP involved in corruption 

* Local governement councilors 
gen corruption_local_c = (q56c==2 | q56c==3) //how many local governement councilors involved in corruption 

* National government officials //different 
gen corruption_local_off = (q56d==2 | q56d==3) //how many national governement officials involved in corruption 

* Local government officials //different 
gen corruption_national_off = (q56e==2 | q56e==3) //how many local governement officials involved in corruption 


** Controls 

gen age = q1 
label var age "Age"
gen language = q3
label var language "Home Language"
gen gender = (q101==1)
label var gender "Gender"
gen rural = (urbrur==2)
label var rural "Rural Primary Sampling Unit"
gen educ = q90
label var educ "Highest Level of Education"
gen race = q102
label var race "Race"
gen religion = q91
label var religion "Religion"
gen tribe = q79 
label var tribe "Ethnic Group"
gen employment = q94
label var employment "Employment status"


save "$intermed_data/Wave3", replace 


** Define constituency for each individual based on coordinates

geoinpoly latitude longitude using "$geo_data/kenya_coords.dta" 


** Keep only variables of interest 

drop q* ea_* 

gen year = 2004

count if _ID == . 

save "$survey_data/Wave3_const.dta", replace 
