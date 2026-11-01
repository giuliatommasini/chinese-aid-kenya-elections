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

* ---- End of the code used for the thesis. The code below was exploratory
* ---- and is not run (exit returns control to master.do).
exit
**--------------------------------------------------**
**					STOCK ANALYSIS				  	**
**--------------------------------------------------**

***********************************
*** 	Performance & Trust 	*** 
***********************************

** Number of projects 

* With respondents controls

eststo performance_mp_r: reghdfe good_performance_MP num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo performance_pres_r: reghdfe trust_MP num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + wb 

eststo performance_mp_c: reghdfe good_performance_MP num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo performance_pres_c: reghdfe trust_MP num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year  

eststo performance_mp_c2: reghdfe good_performance_MP num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_pres_c2: reghdfe trust_MP num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab performance_mp_r performance_mp_c performance_mp_c2 ///
performance_pres_r performance_pres_c performance_pres_c2 ///
using "$output_tables/Donor_performance_proj_wb.tex", replace /// 
keep(num_projects_wb) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "Country X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good Performance MP" "Trust MP", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 



** Monetary value normalized 

* With respondents controls

eststo performance_mp_r: reghdfe good_performance_MP mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo performance_pres_r: reghdfe trust_MP mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo performance_mp_c: reghdfe good_performance_MP mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo performance_pres_c: reghdfe trust_MP mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo performance_mp_c2: reghdfe good_performance_MP mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_pres_c2: reghdfe trust_MP mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab performance_mp_r performance_mp_c performance_mp_c2 ///
performance_pres_r performance_pres_c performance_pres_c2 ///
using "$output_tables/Donor_performance_mon_wb.tex", replace /// 
keep(mon_value_wb_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "Country X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good Performance MP" "Trust MP", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


***********************************
*** 		Satisfaction 		***
***********************************

** Numer of projects 

* With respondent controls

eststo econ_FE: reghdfe manage_economy num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)        

eststo job_FE: reghdfe manage_jobs num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)      


* With respondent and constituency controls

eststo econ_FE_c: reghdfe manage_economy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)       

eststo job_FE_c: reghdfe manage_jobs num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     


* With respondent and constituency controls + county X year  

eststo econ_FE_c2: reghdfe manage_economy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)       

eststo job_FE_c2: reghdfe manage_jobs num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)       


* Export all results table 
esttab econ_FE econ_FE_c econ_FE_c2 ///
job_FE job_FE_c job_FE_c2 /// 
using "$output_tables/Donor_satisf_proj_wb.tex", replace fragment /// 
keep(num_projects_wb) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Manage Economy" "Creating Jobs", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A}} \\\\")

eststo clear 


** Panel B 

* With respondent controls

eststo price_FE: reghdfe manage_corruption num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)       
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe manage_roads num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo price_FE_c: reghdfe manage_corruption num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)        
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo road_FE_c: reghdfe manage_roads num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year  

eststo price_FE_c2: reghdfe manage_corruption num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_FE_c2: reghdfe manage_roads num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab price_FE price_FE_c price_FE_c2 ///
road_FE road_FE_c road_FE_c2 ///   
using "$output_tables/Donor_satisf_proj_wb.tex", append fragment /// 
keep(num_projects_wb) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "Country X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Fighting Corruption" "Mantaining Roads", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///              
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B}} \\\\") postfoot("\hline\hline\end{tabular}")

eststo clear 


** Monetary value normalized 

* With respondent controls

eststo econ_FE: reghdfe manage_economy mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    

eststo job_FE: reghdfe manage_jobs mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   


* With respondent and constituency controls 

eststo econ_FE_c: reghdfe manage_economy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    

eststo job_FE_c: reghdfe manage_jobs mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)      


* With respondent and constituency controls + county X year  

eststo econ_FE_c2: reghdfe manage_economy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    

eststo job_FE_c2: reghdfe manage_jobs mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     


* Export all results table 
esttab econ_FE econ_FE_c econ_FE_c2 ///
job_FE job_FE_c job_FE_c2 /// 
using "$output_tables/Donor_satisf_mon_wb.tex", replace fragment /// 
keep(mon_value_wb_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Manage Economy" "Creating Jobs", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A}} \\\\")

eststo clear 


** Panel B 

* With respondent controls

eststo price_FE: reghdfe manage_corruption mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)      
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe manage_roads mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls

eststo price_FE_c: reghdfe manage_corruption mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)       
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo road_FE_c: reghdfe manage_roads mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo price_FE_c2: reghdfe manage_corruption mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)       
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_FE_c2: reghdfe manage_roads mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab price_FE price_FE_c price_FE_c2 ///
road_FE road_FE_c road_FE_c2 ///    
using "$output_tables/Donor_satisf_mon_wb.tex", append fragment /// 
keep(mon_value_wb_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "Country X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Fighting Corruption" "Mantaining Roads", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///              
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B}} \\\\") postfoot("\hline\hline\end{tabular}")

eststo clear 


*******************************************
*** 		Presence of Services 		*** 
******************************************* 

** Number of projects 

* With respondent controls 

eststo tecn_FE: reghdfe tecn_services num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe road num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo tecn_FE_c: reghdfe tecn_services num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo road_FE_c: reghdfe road num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo tecn_FE_c2: reghdfe tecn_services num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_FE_c2: reghdfe road num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab tecn_FE tecn_FE_c tecn_FE_c2 ///
road_FE road_FE_c road_FE_c2 /// 
using "$output_tables/Donor_services_proj_wb.tex", replace /// 
keep(num_projects_wb) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Utility Access" "Road Presence", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary Value Norm 

* With constituencies fe

eststo tecn_FE: reghdfe tecn_services mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe road mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo tecn_FE_c: reghdfe tecn_services mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace   

eststo road_FE_c: reghdfe road mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace   


* With respondent and constituency controls + county X year  

eststo tecn_FE_c2: reghdfe tecn_services mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)      
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace   

eststo road_FE_c2: reghdfe road mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace    


* Export all results table 
esttab tecn_FE tecn_FE_c tecn_FE_c2 ///
road_FE road_FE_c road_FE_c2 /// 
using "$output_tables/Donor_services_mon_wb.tex", replace /// 
keep(mon_value_wb_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Utility Access" "Road Presence", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///              
collabels(none) nonotes noobs 

eststo clear 



***************************************************
*** 		Demand & Supply for Democracy  		*** 
*************************************************** 

** Number of projects 

* With respondent controls 

eststo demand_FE: reghdfe demand_democracy num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe supply_democracy_raw num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo demand_FE_c: reghdfe demand_democracy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply_FE_c: reghdfe supply_democracy_raw num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand_FE_c2: reghdfe demand_democracy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_FE_c2: reghdfe supply_democracy_raw num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab demand_FE demand_FE_c demand_FE_c2 ///
supply_FE supply_FE_c supply_FE_c2 ///
using "$output_tables/Donor_dem_proj_wb.tex", replace /// 
keep(num_projects_wb) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Demand for Democracy" "Perceived Extent of Democracy", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary value normalized 

* With respondent controls

eststo demand_FE: reghdfe demand_democracy mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe supply_democracy_raw mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo demand_FE_c: reghdfe demand_democracy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply_FE_c: reghdfe supply_democracy_raw mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand_FE_c2: reghdfe demand_democracy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_FE_c2: reghdfe supply_democracy_raw mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab demand_FE demand_FE_c demand_FE_c2 /// 
supply_FE supply_FE_c supply_FE_c2 ///
using "$output_tables/Donor_dem_mon_wb.tex", replace /// 
keep(mon_value_wb_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Demand for Democracy" "Perceived Extent of Democracy", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes noobs  

eststo clear 


*******************************************
*** 		Support for Democracy 		*** 
******************************************* 

** Number of projects 

* With respondents controls 

eststo demand_FE: reghdfe supply_democracy_sat num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe rulelaw_dem_dummy num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls

eststo demand_FE_c: reghdfe supply_democracy_sat num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply_FE_c: reghdfe rulelaw_dem_dummy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand_FE_c2: reghdfe supply_democracy_sat num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_FE_c2: reghdfe rulelaw_dem_dummy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab demand_FE demand_FE_c demand_FE_c2 ///
supply_FE supply_FE_c supply_FE_c2 ///
using "$output_tables/Donor_dem2_proj_wb.tex", replace /// 
keep(num_projects_wb) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Satisfaction with Democracy" "Democracy Support", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary value normalized 

* With respondents controls 

eststo demand_FE: reghdfe supply_democracy_sat mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe rulelaw_dem_dummy mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo demand_FE_c: reghdfe supply_democracy_sat mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply_FE_c: reghdfe rulelaw_dem_dummy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand_FE_c2: reghdfe supply_democracy_sat mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_FE_c2: reghdfe rulelaw_dem_dummy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab demand_FE demand_FE_c demand_FE_c2 ///
supply_FE supply_FE_c supply_FE_c2 ///
using "$output_tables/Donor_dem2_mon_wb.tex", replace /// 
keep(mon_value_wb_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Satisfaction with Democracy" "Democracy Support", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes noobs  

eststo clear


*******************************************
*** 		Economic Conditions 		*** 
******************************************* 

** Number of projects 

* With respondents controls 

eststo pres_FE: reghdfe econ_conditions_country num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo past_FE: reghdfe improved_econ_conditions_country num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo fut_FE: reghdfe exp_econ_conditions_country  num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo pres_FE_c: reghdfe econ_conditions_country num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo past_FE_c: reghdfe improved_econ_conditions_country num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo fut_FE_c: reghdfe exp_econ_conditions_country num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year

eststo pres_FE_c2: reghdfe econ_conditions_country num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_FE_c2: reghdfe improved_econ_conditions_country num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_FE_c2: reghdfe exp_econ_conditions_country num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab pres_FE pres_FE_c pres_FE_c2 ///
past_FE past_FE_c past_FE_c2 /// 
fut_FE fut_FE_c fut_FE_c2 ///
using "$output_tables/Donor_econcond_proj_wb.tex", replace /// 
keep(num_projects_wb) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Good Economic Conditions" "Improved Economy" "Expect Better Economy", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary value normalized 

* With respondents controls 

eststo pres_FE: reghdfe econ_conditions_country mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo past_FE: reghdfe improved_econ_conditions_country mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


eststo fut_FE: reghdfe exp_econ_conditions_country mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo pres_FE_c: reghdfe econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo past_FE_c: reghdfe improved_econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo fut_FE_c: reghdfe exp_econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo pres_FE_c2: reghdfe econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo past_FE_c2: reghdfe improved_econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo fut_FE_c2: reghdfe exp_econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* Export all results table 
esttab pres_FE pres_FE_c pres_FE_c2 ///
past_FE past_FE_c past_FE_c2 /// 
fut_FE fut_FE_c fut_FE_c2 ///
using "$output_tables/Donor_econcond_mon_wb.tex", replace /// 
keep(mon_value_wb_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Good Economic Conditions" "Improved Economy" "Expect Better Economy", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///   
collabels(none) nonotes noobs  

eststo clear 


***************************************
*** 		Living Conditions 		*** 
*************************************** 

** Number of projects 

* With respondents controls 

eststo me_FE: reghdfe econ_conditions_me num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo other_FE: reghdfe econ_conditions_me_other num_projects_wb $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo me_FE_c: reghdfe econ_conditions_me num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo other_FE_c: reghdfe econ_conditions_me_other num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo me_FE_c2: reghdfe econ_conditions_me num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_FE_c2: reghdfe econ_conditions_me_other num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab me_FE me_FE_c me_FE_c2 ///
other_FE other_FE_c other_FE_c2 ///
using "$output_tables/Donor_livingcond_proj_wb.tex", replace /// 
keep(num_projects_wb) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Positive Present Living Conditions" "Positive Relative Living Conditions", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary value normalized 

* With respondents controls 

eststo me_FE: reghdfe econ_conditions_me mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo other_FE: reghdfe econ_conditions_me_other mon_value_wb_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo me_FE_c: reghdfe econ_conditions_me mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo other_FE_c: reghdfe econ_conditions_me_other mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo me_FE_c2: reghdfe econ_conditions_me mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_FE_c2: reghdfe econ_conditions_me_other mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab me_FE me_FE_c me_FE_c2 ///
other_FE other_FE_c other_FE_c2 ///
using "$output_tables/Donor_livingcond_mon_wb.tex", replace /// 
keep(mon_value_wb_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Positive Present Living Conditions" "Positive Relative Living Conditions", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes noobs  

eststo clear 
