********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Analysis Survey: Placebo World Bank

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global survey_data "$data/Survey Analysis"
global output_tables "$output/tables"
global output_figures "$output/figures"


clear all 

********************************************************************************

use "$survey_data/survey_analysis_heter_donor.dta", replace 

********************************************************************************

* Local respondents controls 
global controls_dem age gender rural educ race religion

* Generate ethnicity FE 
gen eth_FE = tribe 
replace eth_FE = language if year ==2003 
replace eth_FE = . if inlist(eth_FE, 998, 999, -1) //should not change things 

* Global controls 
global controls_const_by_year ///
c.luminosity_2002#i.wave   c.time_tocity#i.wave   c.pop_density_2000#i.wave   c.slope#i.wave 

global controls_trend c.county_id#i.wave 


***************************************************
*** 	Main Plots: Local Living Conditions 	*** 
***************************************************

*** Number of Projects 

preserve 

local depv "tecn_services road econ_conditions_country improved_econ_conditions_country  exp_econ_conditions_country"    

local depv_lab `" "Utility Access" "Road Presence" "Good Economic Conditions" "Improved Economy" "Expect Better Economy" "' 

* Collect coefficients into a dataset
tempfile bdat
tempname posth
postfile `posth' str40 outcome byte series ///
    double b se lb ub ///
    double y using `bdat', replace

local i = 0
foreach y of local depv {
    local ++i
    local outlab : word `i' of `depv_lab'

    * ---- Stock spec
    reghdfe `y' num_projects_ch ///
        $controls_dem $controls_const_by_year ///
        num_projects_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[num_projects_wb]
    local se = _se[num_projects_wb]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_proj_ch ///
        $controls_dem $controls_const_by_year ///
        flow_proj_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_proj_wb]
    local se = _se[flow_proj_wb]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (1) (`b') (`se') (`lb') (`ub') (`i')
}
postclose `posth'

use `bdat', clear


* Positioning: same row per outcome, slight vertical offset
gen yplot = y
replace yplot = y + 0.12 if series==0   // Stock slightly above
replace yplot = y - 0.12 if series==1   // Flow  slightly below


* Y-axis labels (outcome names)
local ylabs ""
forvalues j = 1/`i' {
    local outlab : word `j' of `depv_lab'
    local ylabs `ylabs' `j' `"`outlab'"'
}


* Plot: horizontal CIs + points 
twoway ///
    (rcap lb ub yplot if series==0, horizontal lcolor(navy) lwidth(medium)) ///
    (scatter yplot b if series==0, mcolor(navy) msymbol(O) msize(medium)) ///
    (rcap lb ub yplot if series==1, horizontal lcolor(maroon) lwidth(medium)) ///
    (scatter yplot b if series==1, mcolor(maroon) msymbol(O) msize(medium)) ///
    , ///
    xline(0, lcolor(red) lwidth(medthick)) ///
    yscale(reverse) ///
    ylabel(`ylabs', angle(0) noticks) ///
    xlabel(, grid) ///
    legend(order(2 "Stock" 4 "Flow") pos(6) ring(1) cols(2) region(lcolor(none))) /// 
	title("{bf:Placebo Test: World Bank Project Exposure}", color(black) size(medium) justification(center)) ///
    subtitle("{bf:Number of Projects: Living Conditions & Econ Perceptions}", size(small) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_localcond_proj_wb.pdf", replace 

restore 


*** Monetary Value  

preserve 

local depv "tecn_services road econ_conditions_country improved_econ_conditions_country  exp_econ_conditions_country"    

local depv_lab `" "Utility Access" "Road Presence" "Good Economic Conditions" "Improved Economy" "Expect Better Economy" "' 

* Collect coefficients into a dataset
tempfile bdat
tempname posth
postfile `posth' str40 outcome byte series ///
    double b se lb ub ///
    double y using `bdat', replace

local i = 0
foreach y of local depv {
    local ++i
    local outlab : word `i' of `depv_lab'

    * ---- Stock spec
    reghdfe `y' mon_value_ch_million ///
        $controls_dem $controls_const_by_year ///
        mon_value_wb_million $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[mon_value_wb_million]
    local se = _se[mon_value_wb_million]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_mon_ch ///
        $controls_dem $controls_const_by_year ///
        flow_mon_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_mon_wb]
    local se = _se[flow_mon_wb]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (1) (`b') (`se') (`lb') (`ub') (`i')
}
postclose `posth'

use `bdat', clear


* Positioning: same row per outcome, slight vertical offset
gen yplot = y
replace yplot = y + 0.12 if series==0   // Stock slightly above
replace yplot = y - 0.12 if series==1   // Flow  slightly below


* Y-axis labels (outcome names)
local ylabs ""
forvalues j = 1/`i' {
    local outlab : word `j' of `depv_lab'
    local ylabs `ylabs' `j' `"`outlab'"'
}


* Plot: horizontal CIs + points 
twoway ///
    (rcap lb ub yplot if series==0, horizontal lcolor(navy) lwidth(medium)) ///
    (scatter yplot b if series==0, mcolor(navy) msymbol(O) msize(medium)) ///
    (rcap lb ub yplot if series==1, horizontal lcolor(maroon) lwidth(medium)) ///
    (scatter yplot b if series==1, mcolor(maroon) msymbol(O) msize(medium)) ///
    , ///
    xline(0, lcolor(red) lwidth(medthick)) ///
    yscale(reverse) ///
    ylabel(`ylabs', angle(0) noticks) ///
    xlabel(, grid) ///
    legend(order(2 "Stock" 4 "Flow") pos(6) ring(1) cols(2) region(lcolor(none))) /// 
	title("{bf:Placebo Test: World Bank Project Exposure}", color(black) size(medium) justification(center)) ///
    subtitle("{bf:Monetary Value: Living Conditions & Econ Perceptions}", size(small) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_localcond_mon_wb.pdf", replace 

restore 


***********************************************************************
*** 	Main Plots: Goverment Performance and Institutional Trust 	*** 
***********************************************************************

*** Number of Projects 

preserve 

local depv "good_performance_MP trust_MP manage_economy manage_jobs manage_corruption manage_roads"    

local depv_lab `" "Good Performance MPs" "Trust MPs" "Satisfaction: Economy" "Satisfaction: Jobs" "Satisfaction: Corruption" "Satisfaction: Roads" "' 

* Collect coefficients into a dataset
tempfile bdat
tempname posth
postfile `posth' str40 outcome byte series ///
    double b se lb ub ///
    double y using `bdat', replace

local i = 0
foreach y of local depv {
    local ++i
    local outlab : word `i' of `depv_lab'

    * ---- Stock spec
    reghdfe `y' num_projects_ch ///
        $controls_dem $controls_const_by_year ///
        num_projects_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[num_projects_wb]
    local se = _se[num_projects_wb]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_proj_ch ///
        $controls_dem $controls_const_by_year ///
        flow_proj_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_proj_wb]
    local se = _se[flow_proj_wb]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (1) (`b') (`se') (`lb') (`ub') (`i')
}
postclose `posth'

use `bdat', clear


* Positioning: same row per outcome, slight vertical offset
gen yplot = y
replace yplot = y + 0.12 if series==0   // Stock slightly above
replace yplot = y - 0.12 if series==1   // Flow  slightly below


* Y-axis labels (outcome names)
local ylabs ""
forvalues j = 1/`i' {
    local outlab : word `j' of `depv_lab'
    local ylabs `ylabs' `j' `"`outlab'"'
}


* Plot: horizontal CIs + points 
twoway ///
    (rcap lb ub yplot if series==0, horizontal lcolor(navy) lwidth(medium)) ///
    (scatter yplot b if series==0, mcolor(navy) msymbol(O) msize(medium)) ///
    (rcap lb ub yplot if series==1, horizontal lcolor(maroon) lwidth(medium)) ///
    (scatter yplot b if series==1, mcolor(maroon) msymbol(O) msize(medium)) ///
    , ///
    xline(0, lcolor(red) lwidth(medthick)) ///
    yscale(reverse) ///
    ylabel(`ylabs', angle(0) noticks) ///
    xlabel(, grid) ///
    legend(order(2 "Stock" 4 "Flow") pos(6) ring(1) cols(2) region(lcolor(none))) ///
	title("{bf:Placebo Test: World Bank Project Exposure}", color(black) size(medium) justification(center)) ///
    subtitle("{bf:Number of Projects: Institutional Performance and Trust}", size(small) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_polperception_proj_wb.pdf", replace 

restore 


*** Monetary Value  

preserve 

local depv "good_performance_MP trust_MP manage_economy manage_jobs manage_corruption manage_roads"    

local depv_lab `" "Good Performance MPs" "Trust MPs" "Satisfaction: Economy" "Satisfaction: Jobs" "Satisfaction: Corruption" "Satisfaction: Roads" "' 

* Collect coefficients into a dataset
tempfile bdat
tempname posth
postfile `posth' str40 outcome byte series ///
    double b se lb ub ///
    double y using `bdat', replace

local i = 0
foreach y of local depv {
    local ++i
    local outlab : word `i' of `depv_lab'

    * ---- Stock spec
    reghdfe `y' mon_value_ch_million ///
        $controls_dem $controls_const_by_year ///
        mon_value_wb_million $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[mon_value_wb_million]
    local se = _se[mon_value_wb_million]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_mon_ch ///
        $controls_dem $controls_const_by_year ///
        flow_mon_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_mon_wb]
    local se = _se[flow_mon_wb]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (1) (`b') (`se') (`lb') (`ub') (`i')
}
postclose `posth'

use `bdat', clear


* Positioning: same row per outcome, slight vertical offset
gen yplot = y
replace yplot = y + 0.12 if series==0   // Stock slightly above
replace yplot = y - 0.12 if series==1   // Flow  slightly below


* Y-axis labels (outcome names)
local ylabs ""
forvalues j = 1/`i' {
    local outlab : word `j' of `depv_lab'
    local ylabs `ylabs' `j' `"`outlab'"'
}


* Plot: horizontal CIs + points 
twoway ///
    (rcap lb ub yplot if series==0, horizontal lcolor(navy) lwidth(medium)) ///
    (scatter yplot b if series==0, mcolor(navy) msymbol(O) msize(medium)) ///
    (rcap lb ub yplot if series==1, horizontal lcolor(maroon) lwidth(medium)) ///
    (scatter yplot b if series==1, mcolor(maroon) msymbol(O) msize(medium)) ///
    , ///
    xline(0, lcolor(red) lwidth(medthick)) ///
    yscale(reverse) ///
    ylabel(`ylabs', angle(0) noticks) ///
    xlabel(, grid) ///
    legend(order(2 "Stock" 4 "Flow") pos(6) ring(1) cols(2) region(lcolor(none))) ///
	title("{bf:Placebo Test: World Bank Project Exposure}", color(black) size(medium) justification(center)) ///
    subtitle("{bf:Monetary Value: Institutional Performance and Trust}", size(small) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_polperception_mon_wb.pdf", replace 

restore 


***********************************************************
*** 	Main Plots: Democraatic Demand and Legitimacy 	*** 
***********************************************************

*** Number of Projects 

preserve 

local depv "demand_democracy supply_democracy_raw supply_democracy_sat rulelaw_dem_dummy" 

local depv_lab `" "Demand for Democracy" "Perceived Extent of Democracy" "Satisfaction with Democracy" "Support for Democracy" "' 

* Collect coefficients into a dataset
tempfile bdat
tempname posth
postfile `posth' str40 outcome byte series ///
    double b se lb ub ///
    double y using `bdat', replace

local i = 0
foreach y of local depv {
    local ++i
    local outlab : word `i' of `depv_lab'

    * ---- Stock spec
    reghdfe `y' num_projects_ch ///
        $controls_dem $controls_const_by_year ///
        num_projects_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[num_projects_wb]
    local se = _se[num_projects_wb]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_proj_ch ///
        $controls_dem $controls_const_by_year ///
        flow_proj_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_proj_wb]
    local se = _se[flow_proj_wb]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (1) (`b') (`se') (`lb') (`ub') (`i')
}
postclose `posth'

use `bdat', clear


* Positioning: same row per outcome, slight vertical offset
gen yplot = y
replace yplot = y + 0.12 if series==0   // Stock slightly above
replace yplot = y - 0.12 if series==1   // Flow  slightly below


* Y-axis labels (outcome names)
local ylabs ""
forvalues j = 1/`i' {
    local outlab : word `j' of `depv_lab'
    local ylabs `ylabs' `j' `"`outlab'"'
}


* Plot: horizontal CIs + points 
twoway ///
    (rcap lb ub yplot if series==0, horizontal lcolor(navy) lwidth(medium)) ///
    (scatter yplot b if series==0, mcolor(navy) msymbol(O) msize(medium)) ///
    (rcap lb ub yplot if series==1, horizontal lcolor(maroon) lwidth(medium)) ///
    (scatter yplot b if series==1, mcolor(maroon) msymbol(O) msize(medium)) ///
    , ///
    xline(0, lcolor(red) lwidth(medthick)) ///
    yscale(reverse) ///
    ylabel(`ylabs', angle(0) noticks) ///
    xlabel(, grid) ///
    legend(order(2 "Stock" 4 "Flow") pos(6) ring(1) cols(2) region(lcolor(none))) ///
	title("{bf:Placebo Test: World Bank Project Exposure}", color(black) size(medium) justification(center)) ///
    subtitle("{bf:Number of Projects: Democratic Demand and Legitimacy}", size(small) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_democracy_proj_wb.pdf", replace 

restore 


*** Monetary Value 

preserve 

local depv "demand_democracy supply_democracy_raw supply_democracy_sat rulelaw_dem_dummy" 

local depv_lab `" "Demand for Democracy" "Perceived Extent of Democracy" "Satisfaction with Democracy" "Support for Democracy" "' 

* Collect coefficients into a dataset
tempfile bdat
tempname posth
postfile `posth' str40 outcome byte series ///
    double b se lb ub ///
    double y using `bdat', replace

local i = 0
foreach y of local depv {
    local ++i
    local outlab : word `i' of `depv_lab'

    * ---- Stock spec
    reghdfe `y' mon_value_ch_million ///
        $controls_dem $controls_const_by_year ///
        mon_value_wb_million $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[mon_value_wb_million]
    local se = _se[mon_value_wb_million]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_mon_ch ///
        $controls_dem $controls_const_by_year ///
        flow_mon_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_mon_wb]
    local se = _se[flow_mon_wb]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (1) (`b') (`se') (`lb') (`ub') (`i')
}
postclose `posth'

use `bdat', clear


* Positioning: same row per outcome, slight vertical offset
gen yplot = y
replace yplot = y + 0.12 if series==0   // Stock slightly above
replace yplot = y - 0.12 if series==1   // Flow  slightly below


* Y-axis labels (outcome names)
local ylabs ""
forvalues j = 1/`i' {
    local outlab : word `j' of `depv_lab'
    local ylabs `ylabs' `j' `"`outlab'"'
}


* Plot: horizontal CIs + points 
twoway ///
    (rcap lb ub yplot if series==0, horizontal lcolor(navy) lwidth(medium)) ///
    (scatter yplot b if series==0, mcolor(navy) msymbol(O) msize(medium)) ///
    (rcap lb ub yplot if series==1, horizontal lcolor(maroon) lwidth(medium)) ///
    (scatter yplot b if series==1, mcolor(maroon) msymbol(O) msize(medium)) ///
    , ///
    xline(0, lcolor(red) lwidth(medthick)) ///
    yscale(reverse) ///
    ylabel(`ylabs', angle(0) noticks) ///
    xlabel(, grid) ///
    legend(order(2 "Stock" 4 "Flow") pos(6) ring(1) cols(2) region(lcolor(none))) ///
	title("{bf:Placebo Test: World Bank Project Exposure}", color(black) size(medium) justification(center)) ///
    subtitle("{bf:Monetary Value: Democratic Demand and Legitimacy}", size(small) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_democracy_mon_wb.pdf", replace 

restore 
