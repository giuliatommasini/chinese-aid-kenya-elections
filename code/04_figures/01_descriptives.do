********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Descriptives Electoral Analysis 

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do


global electoral_data "$data/Electoral Analysis"
global output_figures "$output/figures"
global geo_data "$data/Geo/Kenya_Constituencies"
global geo_data2 "$data/Geo/gadm36_KEN_shp"
global data_input "$data/Voting/Election Results/01_Cleaned Data"
global clean_data "$data/Aid/01_Cleaned Data"

clear all 


**********************************************
** 			DATA DESCRIPTIVE ANALYSIS 		**  
**********************************************

*** Map winning coalition per constituency 2013 and 2017 ***

cd "$geo_data"
shp2dta using "Constituencies.shp", ///
    database(kenya_data) ///
    coordinates(kenya_coords) ///
    genid(id) ///
	replace
	
use kenya_data, clear

replace CONST_NAME = upper(strtrim(CONST_NAME))

rename CONST_NAME constituencyname

save kenya_data, replace 


use "$electoral_data/voting_classified.dta", clear

keep if year==2013 

collapse (mean) winner_coalition, by(constituencyname)

gen id = _n

label define winner_coalition 1 "Jubilee Alliance" 2 "CORD" 3 "Other"

spmap winner_coalition using ///
    "$geo_data/kenya_coords.dta", ///
    id(id) ///
    fcolor(Blues) ocolor(gs7 ...) ///
    clmethod(unique) ///
    legend(label(2 "Jubilee Alliance") ///
           label(3 "CORD") ///
           label(4 "Other")) ///
    title("{bf:Winner Coalition General Elections 2013}", size(medium) margin(b=5))
	
graph export "$output_figures/winning_coal_const_2013.pdf", replace 

clear all 

use "$electoral_data/voting_classified.dta", clear

preserve 

keep if year == 2017

bysort constituencyname (vote_share politicalpartyname): keep if _n == _N

gen winner_2017 = politicalpartyname

* Create winner's coalition (from 2017 winner's info)
gen winner_coalition_17 = .
replace winner_coalition_17 = 1 if Incumbent == 1 & politicalpartyname == winner_2017
replace winner_coalition_17 = 2 if Opposition == 1 & politicalpartyname == winner_2017
replace winner_coalition_17 = 3 if Other == 1 & politicalpartyname == winner_2017

save "$electoral_data/winner_2017.dta", replace 

restore

* Merge the 2017 winner into full dataset
merge m:1 constituencyname using "$electoral_data/winner_2017.dta"
drop _merge

collapse (mean) winner_coalition_17, by(constituencyname)

gen id = _n

spmap winner_coalition using ///
    "$geo_data/kenya_coords.dta", ///
    id(id) ///
    fcolor(Blues) ocolor(gs7 ..) ///
    clmethod(unique) ///
    legend(label(2 "Jubilee Party") ///
           label(3 "NASA") ///
           label(4 "Other")) ///
		   title("{bf:Winner Coalition General Elections 2017}", size(medium) margin(b=5))
	
graph export "$output_figures/winning_coal_const_2017.pdf", replace 


*** Map projects per constituency *** 

clear all 

use "$clean_data/cleaned.dta", clear 

gen id = _n

spmap  using ///
    "$geo_data/kenya_coords.dta", ///
    id(id) ///
    fcolor(gs14) ocolor(gs8) ///
    point(data("$clean_data/cleaned.dta") ///
          x(longitude) y(latitude) ///
		  size(0.55) /// 
          fcolor(navy%60) /// 
          ocolor(navy%80) osize(vthin) ///
		  legenda(on) leglabel("Aid projects")) ///
    legend(on) ///
    title("Aid Projects by Constituency") 
	
graph export "$output_figures/project_map.pdf", replace 	


spmap  using ///
    "$geo_data/kenya_coords.dta", ///
    id(id) ///
    fcolor(gs14) ocolor(gs8) ///
    point(data("$clean_data/cleaned.dta") ///
          x(longitude) y(latitude) ///
		  select(keep if donor_id==1) ///
		  size(0.55) /// 
          fcolor(red%60) /// 
          ocolor(red%80) osize(vthin) ///
		  legenda(on) leglabel("Chinese Aid projects")) ///
    legend() ///
    title("Aid Projects China by Constituency") 

graph export "$output_figures/project_map_ch.pdf", replace 


spmap  using ///
    "$geo_data/kenya_coords.dta", ///
    id(id) ///
    fcolor(gs14) ocolor(gs8) ///
    point(data("$clean_data/cleaned.dta") ///
          x(longitude) y(latitude) ///
		  select(keep if donor_id==1 & (startyear>2005 & startyear<2014)) ///
		  size(0.55) /// 
          fcolor(red%60) /// 
          ocolor(red%80) osize(vthin) ///
		  legenda(on) leglabel("Chinese Aid projects")) ///
    legend() ///
    title("Aid Projects China by Constituency 2006-2013") 

graph export "$output_figures/project_map_ch_period.pdf", replace 


spmap  using ///
    "$geo_data/kenya_coords.dta", ///
    id(id) ///
    fcolor(gs14) ocolor(gs8) ///
    point(data("$clean_data/cleaned.dta") ///
          x(longitude) y(latitude) ///
		  select(keep if donor_id==2) ///
		  size(0.55) /// 
          fcolor(blue%60) /// 
          ocolor(blue%80) osize(vthin) ///
		  legenda(on) leglabel("World Bank Aid projects")) ///
    legend() ///
    title("Aid Projects World Bank by Constituency") 

graph export "$output_figures/project_map_wb.pdf", replace 


** Descriptive based on type of aid (sector) 

use "$clean_data/cleaned.dta", clear 

* Pie chart 
	
preserve

keep if donor == "China"

* Generate macro sector variable 
gen sector_macro = ""

* Agriculture and related
replace sector_macro = "Agriculture" if regexm(sector_name, "AGRICULTURE|FORESTRY|FISHING|FOOD")

* Education
replace sector_macro = "Education" if regexm(sector_name, "EDUCATION")

* Health
replace sector_macro = "Health" if regexm(sector_name, "HEALTH")

* Infrastructure
replace sector_macro = "Infrastructure" if regexm(sector_name, "TRANSPORT|STORAGE|WATER SUPPLY|SANITATION|ENERGY")

* Government and Public Admin
replace sector_macro = "Government/Civil Society" if regexm(sector_name, "GOVERNMENT|CIVIL SOCIETY")

* Emergency and Relief
replace sector_macro = "Emergency Response" if regexm(sector_name, "EMERGENCY RESPONSE")

* Industry and Mining
replace sector_macro = "Industry/Mining" if regexm(sector_name, "INDUSTRY|MINING|CONSTRUCTION")

* Communications
replace sector_macro = "Communications" if regexm(sector_name, "COMMUNICATION")

* Ordered category for fixed slice + legend order
gen byte sector_order = .
replace sector_order = 1 if sector_macro=="Agriculture"
replace sector_order = 2 if sector_macro=="Education"
replace sector_order = 3 if sector_macro=="Health"
replace sector_order = 4 if sector_macro=="Government/Civil Society"
replace sector_order = 5 if sector_macro=="Communications"
replace sector_order = 6 if sector_macro=="Emergency Response"
replace sector_order = 7 if sector_macro=="Infrastructure"
replace sector_order = 8 if sector_macro=="Industry/Mining"
replace sector_order = 9 if sector_macro=="Other"

label define sectororder ///
  1 "Agriculture" ///
  2 "Education" ///
  3 "Health" ///
  4 "Government and Public Administration" ///
  5 "Communication" ///
  6 "Emergency and Relief" ///
  7 "Infrastructure" ///
  8 "Industry and Mining" ///
  9 "Other"
label values sector_order sectororder
label var sector_order "Macro Sector Category (ordered for plotting)"

label variable sector_macro "Macro Sector Category"

graph pie, over(sector_order) scheme(s1color) ///
    pie(1, color(green))            /// Agriculture
    pie(2, color(yellow))           /// Education
    pie(3, color(red))              /// Health
    pie(4, color(255 105 180))             /// Government & Public Admin
	pie(5, color(blue))             /// Communication
	pie(6, color(139 0 0))           /// Emergency & Relief (dark red)
	pie(7, color(gray))             /// Infrastructure
    pie(8, color(120 70 30))            /// Industry & Mining
    pie(9, color(orange))           /// Other
    title("{bf:Sectoral Distribution Projects - China}") ///
    plabel(_all percent, size(medium))
graph export "$output_figures/pie_sector_ch.pdf", replace

restore

preserve

keep if donor == "World Bank"

* Generate macro sector variable 
gen sector_macro = ""

* Agriculture and related
replace sector_macro = "Agriculture" if regexm(sector_name, "AGRICULTURE|FISHING|FORESTRY")

* Education
replace sector_macro = "Education" if regexm(sector_name, "EDUCATION")

* Health
replace sector_macro = "Health" if regexm(sector_name, "HEALTH|POPULATION")

* Infrastructure
replace sector_macro = "Infrastructure" if regexm(sector_name, "TRANSPORT|STORAGE|WATER SUPPLY|SANITATION|ENERGY")

* Government and Public Admin
replace sector_macro = "Government/Civil Society" if regexm(sector_name, "GOVERNMENT|CIVIL SOCIETY|SOCIAL INFRASTRUCTURE")

* Environment and Disaster
replace sector_macro = "Environment" if regexm(sector_name, "DISASTER PREVENTION|ENVIRONMENT")

* Industry and Mining
replace sector_macro = "Industry/Mining" if regexm(sector_name, "INDUSTRY|MINING|MINERAL RESOURCES")

* Communications
replace sector_macro = "Communications" if regexm(sector_name, "COMMUNICATION")

* Other
*replace sector_macro = "Other" if sector_macro == ""

* Ordered category for fixed slice + legend order
gen byte sector_order = .
replace sector_order = 1 if sector_macro=="Agriculture"
replace sector_order = 2 if sector_macro=="Education"
replace sector_order = 3 if sector_macro=="Health"
replace sector_order = 4 if sector_macro=="Government/Civil Society"
replace sector_order = 5 if sector_macro=="Communications"
replace sector_order = 6 if sector_macro=="Environment"
replace sector_order = 7 if sector_macro=="Infrastructure"
replace sector_order = 8 if sector_macro=="Industry/Mining"
replace sector_order = 9 if sector_macro=="Other"

label define sectororder ///
  1 "Agriculture" ///
  2 "Education" ///
  3 "Health" ///
  4 "Government and Public Administration" ///
  5 "Communication" ///
  6 "Environment" ///
  7 "Infrastructure" ///
  8 "Industry and Mining" ///
  9 "Other"
label values sector_order sectororder
label var sector_order "Macro Sector Category (ordered for plotting)"


label variable sector_macro "Macro Sector Category"

graph pie, over(sector_order) scheme(s1color) ///
    pie(1, color(green))            /// Agriculture
    pie(2, color(yellow))           /// Education
    pie(3, color(red))              /// Health
    pie(4, color(255 105 180))             /// Government & Public Admin
	pie(5, color(blue))             /// Communication
    pie(6, color(140 200 140))           /// Environment
	pie(7, color(gray))             /// Infrastructure
    pie(8, color(120 70 30))            /// Industry & Mining
    pie(9, color(orange))           /// Other
    title("{bf:Sectoral Distribution Projects - World Bank}") ///
    plabel(_all percent, size(medium))
graph export "$output_figures/pie_sector_WB.pdf", replace 

restore

** Option 2: horizontal bar chart 

* ---- CHINA ----

preserve

keep if donor == "China"
keep if startyear <2017

* Macro sector
gen sector_macro = ""
replace sector_macro = "Agriculture"           if regexm(sector_name, "AGRICULTURE|FORESTRY|FISHING|FOOD")
replace sector_macro = "Education"             if regexm(sector_name, "EDUCATION")
replace sector_macro = "Health"                if regexm(sector_name, "HEALTH")
replace sector_macro = "Infrastructure"        if regexm(sector_name, "TRANSPORT|STORAGE|WATER SUPPLY|SANITATION")
replace sector_macro = "Energy"  			   if regexm(sector_name, "ENERGY")
replace sector_macro = "Gov./Civil Society"    if regexm(sector_name, "GOVERNMENT|CIVIL SOCIETY")
replace sector_macro = "Emergency Response"    if regexm(sector_name, "EMERGENCY RESPONSE")
replace sector_macro = "Industry/Mining"       if regexm(sector_name, "INDUSTRY|MINING|CONSTRUCTION")
replace sector_macro = "Communications"        if regexm(sector_name, "COMMUNICATION")
*replace sector_macro = "Other"                 if sector_macro == ""

* Count share per sector (by project-location obs)
bysort sector_macro: gen n_sector = _N
gen total = _N
gen share = (n_sector / total) * 100

* Recompute shares after recoding
drop n_sector total share
bysort sector_macro: gen n_sector = _N
gen total = _N
gen share = (n_sector / total) * 100

* Keep one obs per sector
duplicates drop sector_macro, force

* Sort descending for bar chart readability (Other at bottom)
* Put "Other" last regardless of its share
gen is_other = (sector_macro == "Other")
gsort is_other -share

* Encode for graph
encode sector_macro, gen(sector_num)

* Bar chart
graph hbar share, over(sector_macro, ///
    sort(share) descending ///
    label(labsize(small))) ///
    bar(1, color(navy)) ///
    scheme(s1color) ///
    title("{bf:Sectoral Distribution - China}", size(medium) color(black)) ///
    ytitle("Share of project-location obs. (%)", size(small)) ///
    ylabel(0(10)40, labsize(small)) ///
    blabel(bar, position(outside) format(%4.1f) suffix(%) size(vsmall) color(black)) ///
    graphregion(color(white))

graph export "$output_figures/bar_sector_ch.pdf", replace width(20)

restore

* ---- WORLD BANK ----

preserve

keep if donor == "World Bank"
keep if startyear <2017 | startyear > 2000

* Macro sector
gen sector_macro = ""
replace sector_macro = "Agriculture"           if regexm(sector_name, "AGRICULTURE|FISHING|FORESTRY")
replace sector_macro = "Education"             if regexm(sector_name, "EDUCATION")
replace sector_macro = "Health"                if regexm(sector_name, "HEALTH|POPULATION")
replace sector_macro = "Infrastructure"        if regexm(sector_name, "TRANSPORT|STORAGE|WATER SUPPLY|SANITATION|ENERGY")
replace sector_macro = "Gov./Civil Society"    if regexm(sector_name, "GOVERNMENT|CIVIL SOCIETY|SOCIAL INFRASTRUCTURE")
replace sector_macro = "Environment"           if regexm(sector_name, "DISASTER PREVENTION|ENVIRONMENT")
replace sector_macro = "Industry/Mining"       if regexm(sector_name, "INDUSTRY|MINING|MINERAL RESOURCES")
replace sector_macro = "Communications"        if regexm(sector_name, "COMMUNICATION")
*replace sector_macro = "Other"                 if sector_macro == ""

* Compute shares
bysort sector_macro: gen n_sector = _N
gen total = _N
gen share = (n_sector / total) * 100

* Recompute after recoding
drop n_sector total share
bysort sector_macro: gen n_sector = _N
gen total = _N
gen share = (n_sector / total) * 100

duplicates drop sector_macro, force

* Bar chart
graph hbar share, over(sector_macro, ///
    sort(share) descending ///
    label(labsize(small))) ///
    bar(1, color(navy)) ///
    scheme(s1color) ///
    title("{bf:Sectoral Distribution - World Bank}", size(medium) color(black)) ///
    ytitle("Share of project-location obs. (%)", size(small)) ///
    ylabel(0(10)40, labsize(small)) ///
    blabel(bar, position(outside) format(%4.1f) suffix(%) size(vsmall) color(black)) ///
    graphregion(color(white))

graph export "$output_figures/bar_sector_WB.pdf", replace width(20)

restore


** Descriptive based on the amount of aid 

label var comm_loc_evensplit "Monetary Value Projects by Location"

gen comm_loc_evensplit_mill = comm_loc_evensplit/1e6
label var comm_loc_evensplit_mill "Monetary Value Projects by Location"

graph bar (mean) comm_loc_evensplit_mill, over(donor, sort(1) descending) ///
    title("Mean Project Value by Donor") ///
    ytitle("Mean Value") ///
    bar(1, color(blue))

	
** Box plot 

* China

preserve 

keep if donor == "China"

graph box comm_loc_evensplit_mill, ///
    nooutside ///
    aspect(1.4) ///
    ylabel(, format(%12.0fc) nogrid angle(horizontal)) ///
    ytitle("Monetary value of project-location (USD millions)") ///
    title("{bf:Boxplot Monetary Value Development Assistance China}", color(black) margin(b=5)) ///
	note("") ///
    graphregion(color(white))
	
graph export "$output_figures/boxplot_monetary_value_ch.pdf", replace 

restore 

* World Bank 

preserve 

keep if donor == "World Bank"

graph box comm_loc_evensplit_mill, ///
	nooutside ///
	aspect(1.4) ///
	ylabel(, format(%12.0fc) nogrid angle(horizontal)) ///
    ytitle("Monetary value of project-location (USD millions)") ///
    title("{bf:Boxplot Monetary Value Development Assistance World Bank}", color(black) margin(b=5)) ///
	note("") ///
	graphregion(color(white)) plotregion(margin(zero))
	
graph export "$output_figures/boxplot_monetary_value_wb.pdf", replace 

restore 



** Time series of number of projects and monetary value : China 

clear all 

use "$clean_data/cleaned.dta", clear 


** Number of projects 

preserve

keep if donor == "China" 
keep if startyear <2017

bysort startyear name_2: gen num_proj = _N
collapse (sum) num_proj, by(startyear)
	
twoway ///
    (connected num_proj startyear, sort lwidth(medthick) msymbol(o) msize(small)) ///
, ytitle("Number of  project-location") xtitle("Year") ///
  xlabel(2001(2)2016, angle(0)) ylabel(, angle(0) grid) ///
  xline(2013, lcolor(red) lwidth(medthick)) ///
  title("{bf:Number of Projects Development Assistance}", color(black) margin(b=5)) ///
  graphregion(color(white)) plotregion(margin(zero)) ///
  legend(off) 
  
graph export "$output_figures/projects_over_time.pdf", replace 

restore


** Number of Projects Cumulative 
preserve

keep if donor == "China"
keep if startyear < 2015

* Count projects correctly: 1 per (startyear, name_2)
bysort startyear name_2: gen proj = (_n == 1)

* Yearly total projects
collapse (sum) num_proj = proj, by(startyear)

* Fill missing years with 0 BEFORE cumulative
sort startyear
tsset startyear
tsfill, full
replace num_proj = 0 if missing(num_proj)

* Cumulative over all years
gen cum_proj = sum(num_proj)

* Keep only the years you want to show
keep if inlist(startyear, 2001, 2003, 2005, 2008, 2011, 2014)
sort startyear

* Step line between selected years
gen startyear_next = startyear[_n+1]
expand 2 if _n < _N
bysort startyear: gen t = _n
replace startyear = startyear_next if t == 2
drop t startyear_next
sort startyear

twoway ///
    (connected cum_proj startyear, sort lwidth(medthick)) ///
    (scatter cum_proj startyear if inlist(startyear, 2003, 2005, 2008, 2011, 2014), ///
        msymbol(o) msize(small)) ///
, ytitle("Number of  project-location") xtitle("Year") ///
  xlabel(2003 2005 2008 2011 2014, angle(0)) ///
  ylabel(, angle(0) grid) ///
  title("{bf:Cumulative Number of Projects Development Assistance}", color(black) margin(b=5)) ///
  graphregion(color(white)) plotregion(margin(zero)) ///
  legend(off)

graph export "$output_figures/projects_over_time_2014_cum.pdf", replace

restore


** Monetary value 

preserve

keep if donor == "China" 
keep if startyear <2017

bysort startyear name_2: egen mon_value = total(comm_loc_evensplit)
collapse (sum) mon_value, by(startyear)

gen mon_value_bill = mon_value/1e9
	
twoway ///
    (connected mon_value_bill startyear, sort lwidth(medthick) msymbol(o) msize(small)) ///
, ytitle("USD billions") xtitle("Year") ///
  xlabel(2001(2)2016, angle(0)) ylabel(, angle(0) grid) ///
  xline(2013, lcolor(red) lwidth(medthick)) ///
  title("{bf:Monetary Value Development Assistance}", color(black) margin(b=5)) ///
  graphregion(color(white)) plotregion(margin(zero)) ///
  legend(off) 

graph export "$output_figures/mon_value_over_time.pdf", replace 

restore

** Monetary Value Cumulative 

preserve

keep if donor == "China"
keep if startyear < 2015

* yearly total (money)
bysort startyear name_2: egen mon_value = total(comm_loc_evensplit)
collapse (sum) mon_value, by(startyear)

* fill missing years with zeros BEFORE cumulative logic
sort startyear
tsset startyear
tsfill, full
replace mon_value = 0 if missing(mon_value)

gen period = .
replace period = 2001 if startyear <= 2001
replace period = 2003 if inrange(startyear, 2002, 2003)
replace period = 2005 if inrange(startyear, 2004, 2005)
replace period = 2008 if inrange(startyear, 2006, 2008)
replace period = 2011 if inrange(startyear, 2009, 2011)
replace period = 2014 if inrange(startyear, 2012, 2014)

* sum within periods
collapse (sum) mon_value, by(period)
rename period startyear

* cumulative across the periods
sort startyear
gen cum_mon = sum(mon_value)
gen cum_mon_value_bill = cum_mon/1e9

* make a step line between selected years
gen startyear_next = startyear[_n+1]
expand 2 if _n < _N
bysort startyear: gen t = _n
replace startyear = startyear_next if t == 2
drop t startyear_next
sort startyear

twoway ///
  (connected cum_mon_value_bill startyear, sort lwidth(medthick)) ///
  (scatter   cum_mon_value_bill startyear if inlist(startyear,2003,2005,2008,2011,2014), ///
     msymbol(o) msize(small)) ///
, ytitle("USD billions") xtitle("Year") ///
  xlabel(2003 2005 2008 2011 2014) ///
  ylabel(, grid) ///
  title("{bf:Cumulative Monetary Value Development Assistance}", color(black) margin(b=5)) ///
  graphregion(color(white)) plotregion(margin(zero)) ///
  legend(off)

graph export "$output_figures/mon_value_over_time_2014_cum.pdf", replace

restore



*** Time series of number of projects and monetary value : World Bank 

** Number of projects 

preserve

keep if donor == "World Bank" 
keep if startyear <2017

bysort project_id project_location_id startyear: keep if _n==1

gen one = 1
collapse (sum) num_proj=one, by(startyear)
	
twoway ///
    (connected num_proj startyear, sort lwidth(medthick) msymbol(o) msize(small)) ///
, ytitle("Number of  project-location") xtitle("Year") ///
  xlabel(1995(2)2016, angle(0)) ylabel(, angle(0) grid) ///
  title("{bf:Number of Projects World Bank Development Assistance}", color(black) margin(b=5)) ///
  graphregion(color(white)) plotregion(margin(zero)) ///
  legend(off) 
  
graph export "$output_figures/projects_over_time_wb.pdf", replace 

restore


** Monetary value 

preserve

keep if donor == "World Bank" 
keep if startyear <2017

collapse (mean) comm_loc_evensplit, by(project_id project_location_id startyear)
collapse (sum) mon_value=comm_loc_evensplit, by(startyear)

gen mon_value_bill = mon_value/1e9
	
twoway ///
    (connected mon_value_bill startyear, sort lwidth(medthick) msymbol(o) msize(small)) ///
, ytitle("USD billions") xtitle("Year") ///
  xlabel(1995(2)2016, angle(0)) ylabel(, angle(0) grid) ///
  title("{bf:Monetary Value of World Bank Development Assistance}", color(black) margin(b=5)) ///
  graphregion(color(white)) plotregion(margin(zero)) ///
  legend(off) 

graph export "$output_figures/mon_value_over_time_wb.pdf", replace 

restore


