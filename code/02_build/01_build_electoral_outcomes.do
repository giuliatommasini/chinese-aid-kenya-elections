********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Data Preparation Electoral Data for Electoral Analysis

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

use "$intermed_data/National_Assembly_tot.dta", clear 

********************************************************************************

***********************************************
*** 				CLEANING 				*** 
***********************************************

** Cleaning political party names 

replace politicalpartyname = "AGANO PARTY" if inlist(politicalpartyname, "AGANO", "AGANO PARTY", " AGANO PARTY")

replace politicalpartyname = "ALLIANCE PARTY OF KENYA" if inlist(politicalpartyname, "ALLIANCE PARTY OF KENYA", "A L L IANCE PARTY OF KENYA")

replace politicalpartyname = "FORD-KENYA" if inlist(politicalpartyname, "FORD KENYA", "FORD-KENYA", "FORD K", "FORD-K", "FORD KENYA", "FORD- KENYA", "FORUM FOR RESTORATION OF DEMOCRACY-KENYA","FORUM FOR RESTORATION OF DEMOCRACY- KENYA", "FORUM FOR RESTORATION OF  DEMOCRACY - KENYA")

replace politicalpartyname = "FORD-KENYA" if inlist(politicalpartyname, "FORUM FOR RESTORATION OF DEMOCRACY - KENYA", "FORUM FOR RESTORATION OF  DEMOCRACY -KENYA", "FORUM FOR RESTORATION OF  DEMOCRACY-KENYA", "FORD K", "FORD  K")

replace politicalpartyname = "KENYA AFRICAN DEMOCRATIC UNION-ASILI" if inlist(politicalpartyname, "KENYA AFRICAN DEMOCRATIC UNION- ASILI", "KENYA AFRICAN DEMOCRATIC UNION-ASILI", "KENYA AFRICAN DEMOCRATIC UNION-  ASILI")

replace politicalpartyname = "MWANGAZA PARTY" if inlist(politicalpartyname, "MWANGAZA", "MWANGAZA PARTY")

replace politicalpartyname = "MZALENDO" if inlist(politicalpartyname,  "MZALENDO", "MZALENDO SABA SABA PARTY")

replace politicalpartyname = "FORD PEOPLE" if inlist(politicalpartyname, "FORD P", "FORD PEOPLE", "FORD-PEOPLE")

replace politicalpartyname = "INDEPENDENT" if strpos(upper(politicalpartyname), "INDEPENDENT") | inlist(politicalpartyname, "IND", "INDEPENDEDNT CANDIDATE", "INDEPENDENY CANDIDATE")

replace politicalpartyname = "KADU-ASILI" if inlist(politicalpartyname, "KADU ASILI", "KADU-ASILI", "KADU-A")

replace politicalpartyname = "GRAND NATIONAL UNION" if strpos(upper(politicalpartyname), "GRAND NATIONAL UNION")

replace politicalpartyname = "KENYA NATIONAL CONGRESS" if strpos(upper(politicalpartyname), "KENYA NATIONAL CONGRESS")

replace politicalpartyname = "MAENDELEO CHAP CHAP PARTY" if strpos(upper(politicalpartyname), "MAENDELEO CHAP CHAP")

replace politicalpartyname = "NARC-KENYA" if inlist(politicalpartyname, "NARC-KENYA", "NARC KENYA", "NARC-K", "NARC K", "NARCK-K", "NARCK-K - K", "NATIONAL RAINBOW COALITION-KENYA", "NARC - K")

replace politicalpartyname = "NARC" if inlist(politicalpartyname, "NARC", "NATIONAL RAINBOW COALITION")

replace politicalpartyname = "NATIONAL VISION PARTY" if inlist(politicalpartyname,  "NATIONAL VISION PARTY", "NATIONAL VISION PARTY OF KENYA", "THE NATIONAL VISION PARTY")

replace politicalpartyname = "NEW FORD" if inlist(politicalpartyname, "NEW FORD KENYA", "NEWFORD KENYA")

replace politicalpartyname = "NATIONAL AGENDA PARTY OF KENYA" if strpos(upper(politicalpartyname), "NATIONAL AGENDA PARTY")

replace politicalpartyname = "NEW DEMOCRATS" if strpos(upper(politicalpartyname), "NEW DEMOCRATS")

replace politicalpartyname = "ORANGE DEMOCRATIC MOVEMENT" if strpos(upper(politicalpartyname), "ORANGE DEMOCRATIC MOVEMENT") | strpos(upper(politicalpartyname), "O R A N G E")

replace politicalpartyname = "ORANGE DEMOCRATIC MOVEMENT" if politicalpartyname == "ORANGE DEMOCTRATIC MOVEMENT"

replace politicalpartyname = "PEOPLES PARTY" if inlist(politicalpartyname, "PEOPLES PARTY", "PEOPLES PARTY OF KENYA", "PPEOPLES PARTY OF KENYA")

replace politicalpartyname = "RESTORE AND BUILD KENYA" if inlist(politicalpartyname, "RESTORE AND BUILD KENYA", "RESTORE AND BUILD KENYA PARTY")

replace politicalpartyname = "SABA SABA ASILI" if inlist(politicalpartyname, "SABASABA ASILI","SABA SABA ASILI")

replace politicalpartyname = "SHIRIKISHO PARTY OF KENYA" if inlist(politicalpartyname,  "SHIRIKISHO", "SHIRIKISHO PARTY OF KENYA") 

replace politicalpartyname = "LABOUR PARTY OF KENYA" if inlist(politicalpartyname, "THE LABOUR PARTY OF KENYA", "LABOUR PARTY OF KENYA", "LPK")
 
replace politicalpartyname = "SISI KWA SISI PARTY" if inlist(politicalpartyname, "SISI KWA SISI PARTY", "SISI KWA SISI PARTY OF KENYA")

replace politicalpartyname = "WIPER DEMOCRATIC MOVEMENT-KENYA" if strpos(upper(politicalpartyname), "WIPER")

replace politicalpartyname = "FARMERS PARTY" if inlist(politicalpartyname, "FARMERS P", "FARMERS PARTY")

replace politicalpartyname = "THE NATIONAL ALLIANCE" if politicalpartyname == " THE NATIONAL ALLIANCE"

tab politicalpartyname


***********************************************************
*** 				CREATION OF VARIABLES 				*** 
***********************************************************

sort constituencyname year politicalpartyname

* Generating total votes cast per constituency-year
bysort constituencyname year (politicalpartyname): egen totalvotes_const = total(totalvotes)

* Computing vote share
gen vote_share = totalvotes / totalvotes_const


***************************************************************
*** 	Incumbent - Opposition defined on national basis 	***
***************************************************************

* Define parties Incumbent at national level 
gen Incumbent=1 if politicalpartyname == "THE NATIONAL ALLIANCE" | politicalpartyname == "NARC-KENYA" | politicalpartyname=="NARC" | politicalpartyname == "UNITED REPUBLICAN PARTY" | politicalpartyname == "REPUBLICAN CONGRESS PARTY OF KENYA" | politicalpartyname == "JUBILEE PARTY" 
*| politicalpartyname == "ALLIANCE PARTY OF KENYA"
replace Incumbent=0 if Incumbent==. 


* Define parties Opposition at national level 
gen Opposition=1 if politicalpartyname == "AMANI NATIONAL CONGRESS" | politicalpartyname == "CHAMA CHA UZALENDO"| politicalpartyname ==  "FEDERAL PARTY OF KENYA" | politicalpartyname == "FORD-KENYA" | politicalpartyname == "KADU-ASILI" | politicalpartyname =="KENYA SOCIAL CONGRESS" | politicalpartyname == "LABOUR PARTY OF KENYA" | politicalpartyname == "MKENYA SOLIDARITY MOVEMENT" |politicalpartyname == "MUUNGANO PARTY" | politicalpartyname =="ORANGE DEMOCRATIC MOVEMENT" | politicalpartyname == "PEOPLES DEMOCRATIC PARTY" | politicalpartyname == "WIPER DEMOCRATIC MOVEMENT-KENYA" | politicalpartyname == "THE INDEPENDENT PARTY" |  politicalpartyname == "UNITED DEMOCRATIC MOVEMENT" | politicalpartyname== "CHAMA CHA MASHINANI" | politicalpartyname == "PROGRESSIVE PARTY OF KENYA" |  politicalpartyname== "MUUNGANO PARTY"
replace Opposition=0 if Opposition==.  


* Define parties Other at national level 
gen Other = (Opposition==0 & Incumbent==0)


* Computing vote share of Incumbent 
gen vote_share_Inc = vote_share if Incumbent == 1
bysort constituencyname year: egen Incumbent_vote_share = total(vote_share_Inc)
drop vote_share_Inc

label var Incumbent_vote_share "National incumbent Vote Share"

* Computing vote share of Opposition
gen vote_share_Opp = vote_share if Opposition == 1
bysort constituencyname year: egen Opposition_vote_share = total(vote_share_Opp)
drop vote_share_Opp

label var Opposition_vote_share "National opposition Vote Share"


***************************************************************
*** 		Incumbent defined on constituency basis 		***
***************************************************************

* Identify the 2013 winner party in each constituency 
preserve

keep if year == 2013

bysort constituencyname (vote_share politicalpartyname): keep if _n == _N

gen winner_2013 = politicalpartyname

* Create winner's coalition (from 2013 winner's info)
gen winner_coalition = .
replace winner_coalition = 1 if Incumbent == 1 & politicalpartyname == winner_2013
replace winner_coalition = 2 if Opposition == 1 & politicalpartyname == winner_2013
replace winner_coalition = 3 if Other == 1 & politicalpartyname == winner_2013

save "$electoral_data/winner_2013.dta", replace 

restore

* Merge the 2013 winner into full dataset
merge m:1 constituencyname using "$electoral_data/winner_2013.dta"
drop _merge


* Mark if each party belongs to same coalition as the 2013 winner
gen same_coalition_as_winner = .
replace same_coalition_as_winner = 1 if winner_coalition == 1 & Incumbent == 1
replace same_coalition_as_winner = 1 if winner_coalition == 2 & Opposition == 1
replace same_coalition_as_winner = 1 if winner_coalition == 3 & Other == 1
replace same_coalition_as_winner = 0 if missing(same_coalition_as_winner)

* Keep vote share only for matching coalition parties
gen vote_share_winning_coal = vote_share if same_coalition_as_winner == 1

* Sum across parties in constituency-year
bysort constituencyname year: egen winning_coalition_vote_share = total(vote_share_winning_coal)

label var winning_coalition_vote_share "Vote Share of 2013 Winner's Coalition"


***************************************************
*** 		Margin of Victory Local Level 		***
***************************************************

gen neg_vote_share = - vote_share

bysort constituencyname year (neg_vote_share politicalpartyname): gen rank = _n

by constituencyname year: gen double top1_share = neg_vote_share[1]
by constituencyname year: gen double top2_share = cond(_N>=2, neg_vote_share[2], .)
by constituencyname year: gen strL   winner_party = politicalpartyname[1]

* Flag ties
by constituencyname year: gen byte tie_for_first = (_N>=2 & neg_vote_share[1]==neg_vote_share[2])

* Generate margin of victory 
gen double neg_margin_victory = top1_share - top2_share

gen margin_victory = - neg_margin_victory
label var margin_victory "Margin of victory (winner - runner-up)"

* Adjust margin of victory for uncontested elections in Kikuyu 
replace margin_victory = 1 if margin_victory == . & constituencyname=="KIKUYU"  


*** Save dataset 

sort constituencyname year 

save "$electoral_data/voting_classified.dta", replace 

