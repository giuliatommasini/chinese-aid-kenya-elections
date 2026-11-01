********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Analysis Survey: Donor

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

    local b  = _b[num_projects_ch]
    local se = _se[num_projects_ch]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_proj_ch ///
        $controls_dem $controls_const_by_year ///
        flow_proj_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_proj_ch]
    local se = _se[flow_proj_ch]
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
	title("{bf:Number of Projects: Living Conditions & Econ Perceptions}", color(black) size(medium) justification(center) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_localcond_proj.pdf", replace 

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

    local b  = _b[mon_value_ch_million]
    local se = _se[mon_value_ch_million]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_mon_ch ///
        $controls_dem $controls_const_by_year ///
        flow_mon_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_mon_ch]
    local se = _se[flow_mon_ch]
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
	title("{bf:Monetary Value: Living Conditions & Econ Perceptions}", color(black) size(medium) justification(center) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_localcond_mon.pdf", replace 

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

    local b  = _b[num_projects_ch]
    local se = _se[num_projects_ch]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_proj_ch ///
        $controls_dem $controls_const_by_year ///
        flow_proj_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_proj_ch]
    local se = _se[flow_proj_ch]
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
	title("{bf:Number of Projects: Institutional Performance and Trust}", size(medium) color(black) justification(center) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_polperception_proj.pdf", replace 

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

    local b  = _b[mon_value_ch_million]
    local se = _se[mon_value_ch_million]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_mon_ch ///
        $controls_dem $controls_const_by_year ///
        flow_mon_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_mon_ch]
    local se = _se[flow_mon_ch]
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
	title("{bf:Monetary Value: Institutional Performance and Trust}", size(medium) color(black) justification(center) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_polperception_mon.pdf", replace 

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

    local b  = _b[num_projects_ch]
    local se = _se[num_projects_ch]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_proj_ch ///
        $controls_dem $controls_const_by_year ///
        flow_proj_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_proj_ch]
    local se = _se[flow_proj_ch]
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
	title("{bf:Number of Projects: Democratic Demand and Legitimacy}", color(black) size(medium) justification(center) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_democracy_proj.pdf", replace 

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

    local b  = _b[mon_value_ch_million]
    local se = _se[mon_value_ch_million]
    local lb = `b' - 1.96*`se'
    local ub = `b' + 1.96*`se'
    post `posth' ("`outlab'") (0) (`b') (`se') (`lb') (`ub') (`i')

    * ---- Flow spec
    reghdfe `y' flow_mon_ch ///
        $controls_dem $controls_const_by_year ///
        flow_mon_wb $controls_trend ///
        [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

    local b  = _b[flow_mon_ch]
    local se = _se[flow_mon_ch]
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
	title("{bf:Monetary Value: Democratic Demand and Legitimacy}", color(black) size(medium) justification(center) margin(b=5)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    ytitle("") xtitle("") 
	
graph export "$output_figures/main_survey_democracy_mon.pdf", replace 

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

eststo performance_mp_r: reghdfe good_performance_MP num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo performance_pres_r: reghdfe trust_MP num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_performance_proj.tex", replace /// 
keep(num_projects_ch) ///
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


** Log Number of projects 


* With respondents controls

eststo performance_mp_r: reghdfe good_performance_MP ln_num_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo performance_pres_r: reghdfe trust_MP ln_num_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo performance_mp_c: reghdfe good_performance_MP ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo performance_pres_c: reghdfe trust_MP ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year   

eststo performance_mp_c2: reghdfe good_performance_MP ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_pres_c2: reghdfe trust_MP ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_performance_ln_proj.tex", replace /// 
keep(ln_num_proj_ch) ///
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

eststo performance_mp_r: reghdfe good_performance_MP mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo performance_pres_r: reghdfe trust_MP mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_performance_mon.tex", replace /// 
keep(mon_value_ch_million) ///
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


** Log Monetary value normalized 

* With respondents controls

eststo performance_mp_r: reghdfe good_performance_MP ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo performance_pres_r: reghdfe trust_MP ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo performance_mp_c: reghdfe good_performance_MP ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo performance_pres_c: reghdfe trust_MP ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year

eststo performance_mp_c2: reghdfe good_performance_MP ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_pres_c2: reghdfe trust_MP ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_performance_ln_mon.tex", replace /// 
keep(ln_mon_value_ch) ///
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

/*------------------------*/
/*   Number of Projects   */
/*------------------------*/

** Panel A

* With respondent controls

eststo econ_FE: reghdfe manage_economy num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)        

eststo job_FE: reghdfe manage_jobs num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_satisf_proj.tex", replace fragment /// 
keep(num_projects_ch) ///
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

eststo price_FE: reghdfe manage_corruption num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace 

eststo road_FE: reghdfe manage_roads num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_satisf_proj.tex", append fragment /// 
keep(num_projects_ch) ///
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


/*----------------------------*/
/*   Log Number of Projects   */
/*----------------------------*/

** Panel A  

* With respondent controls

eststo econ_FE: reghdfe manage_economy ln_num_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo job_FE: reghdfe manage_jobs ln_num_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo price_FE: reghdfe manage_corruption ln_num_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    


* With respondent and constituency controls 

eststo econ_FE_c: reghdfe manage_economy ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)         

eststo job_FE_c: reghdfe manage_jobs ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo price_FE_c: reghdfe manage_corruption ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     


* With respondent and constituency controls + county X year 

eststo econ_FE_c2: reghdfe manage_economy ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)         

eststo job_FE_c2: reghdfe manage_jobs ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo price_FE_c2: reghdfe manage_corruption ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    


* Export all results table 
esttab econ_FE econ_FE_c econ_FE_c2 ///
job_FE job_FE_c job_FE_c2 /// 
price_FE price_FE_c price_FE_c2 ///
using "$output_tables/Donor_satisf_ln_proj.tex", replace fragment /// 
keep(ln_num_proj_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Manage Economy" "Creating Jobs" "Fighting Corruption", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\begin{tabular}{l*{9}{c}}\hline\hline\multicolumn{10}{c}{\textbf{Panel A}} \\\\")

eststo clear 


** Panel B 

* With respondent controls

eststo health_FE: reghdfe manage_health ln_num_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_health [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo educ_FE: reghdfe manage_educ ln_num_proj_ch $controls_dem  [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_educ [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe manage_roads ln_num_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo health_FE_c: reghdfe manage_health ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_health [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo educ_FE_c: reghdfe manage_educ ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_educ [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo road_FE_c: reghdfe manage_roads ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo health_FE_c2: reghdfe manage_health ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_health [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo educ_FE_c2: reghdfe manage_educ ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_educ [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_FE_c2: reghdfe manage_roads ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab health_FE health_FE_c health_FE_c2 ///
educ_FE educ_FE_c educ_FE_c2 /// 
road_FE road_FE_c road_FE_c2 ///
using "$output_tables/Donor_satisf_ln_proj.tex", append fragment /// 
keep(ln_num_proj_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "Country X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Improving Health Services" "Addressing Educational Need" "Mantaining Roads", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///              
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\hline \multicolumn{10}{c}{\textbf{Panel B}} \\\\") postfoot("\hline\hline\end{tabular}")

eststo clear 


/*-------------------------*/
/*   Monetary Value Norm   */
/*-------------------------*/

** Panel A 

* With respondent controls

eststo econ_FE: reghdfe manage_economy mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    

eststo job_FE: reghdfe manage_jobs mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_satisf_mon.tex", replace fragment /// 
keep(mon_value_ch_million) ///
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

eststo price_FE: reghdfe manage_corruption mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe manage_roads mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_satisf_mon.tex", append fragment /// 
keep(mon_value_ch_million) ///
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


/*-------------------------*/
/*   Log Monetary Value    */
/*-------------------------*/

** Panel A 

* With respondent controls

eststo econ_FE: reghdfe manage_economy ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo job_FE: reghdfe manage_jobs ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo price_FE: reghdfe manage_corruption ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     


* With respondent and constituency controls 

eststo econ_FE_c: reghdfe manage_economy ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo job_FE_c: reghdfe manage_jobs ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb  [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo price_FE_c: reghdfe manage_corruption ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   


* With respondent and constituency controls + county X year 

eststo econ_FE_c2: reghdfe manage_economy ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo job_FE_c2: reghdfe manage_jobs ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo price_FE_c2: reghdfe manage_corruption ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     


* Export all results table 
esttab econ_FE econ_FE_c econ_FE_c2 ///
job_FE job_FE_c job_FE_c2 /// 
price_FE price_FE_c price_FE_c2 ///
using "$output_tables/Donor_satisf_ln_mon.tex", replace fragment /// 
keep(ln_mon_value_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Manage Economy" "Creating Jobs" "Fighting Corruption", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0 ) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\begin{tabular}{l*{9}{c}}\hline\hline\multicolumn{10}{c}{\textbf{Panel A}} \\\\")

eststo clear 


** Panel B 

* With respondent controls

eststo health_FE: reghdfe manage_health ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_health [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo educ_FE: reghdfe manage_educ ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_educ [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe manage_roads ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls  

eststo health_FE_c: reghdfe manage_health ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_health [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo educ_FE_c: reghdfe manage_educ ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_educ [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo road_FE_c: reghdfe manage_roads ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls  

eststo health_FE_c2: reghdfe manage_health ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_health [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo educ_FE_c2: reghdfe manage_educ ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_educ [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_FE_c2: reghdfe manage_roads ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab health_FE health_FE_c health_FE_c2 /// 
educ_FE educ_FE_c educ_FE_c2 ///
road_FE road_FE_c road_FE_c2 ///
using "$output_tables/Donor_satisf_ln_mon.tex", append fragment /// 
keep(ln_mon_value_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "Country X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Improving Health Services" "Addressing Educational Need" "Mantaining Roads", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///              
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\hline \multicolumn{9}{c}{\textbf{Panel B}} \\\\") postfoot("\hline\hline\end{tabular}")

eststo clear 


*******************************************
*** 		Presence of Services 		*** 
******************************************* 

** Number of projects 

* With respondent controls 

eststo tecn_FE: reghdfe tecn_services num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe road num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_services_proj.tex", replace /// 
keep(num_projects_ch) ///
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

eststo tecn_FE: reghdfe tecn_services mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace  

eststo road_FE: reghdfe road mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_services_mon.tex", replace /// 
keep(mon_value_ch_million) ///
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

eststo demand_FE: reghdfe demand_democracy num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe supply_democracy_raw num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_dem_proj.tex", replace /// 
keep(num_projects_ch) ///
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

eststo demand_FE: reghdfe demand_democracy mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe supply_democracy_raw mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_dem_mon.tex", replace /// 
keep(mon_value_ch_million) ///
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

eststo demand_FE: reghdfe supply_democracy_sat num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe rulelaw_dem_dummy num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_dem2_proj.tex", replace /// 
keep(num_projects_ch) ///
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

eststo demand_FE: reghdfe supply_democracy_sat mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe rulelaw_dem_dummy mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_dem2_mon.tex", replace /// 
keep(mon_value_ch_million) ///
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

eststo pres_FE: reghdfe econ_conditions_country num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo past_FE: reghdfe improved_econ_conditions_country num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo fut_FE: reghdfe exp_econ_conditions_country  num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_econcond_proj.tex", replace /// 
keep(num_projects_ch) ///
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

eststo pres_FE: reghdfe econ_conditions_country mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo past_FE: reghdfe improved_econ_conditions_country mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


eststo fut_FE: reghdfe exp_econ_conditions_country mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_econcond_mon.tex", replace /// 
keep(mon_value_ch_million) ///
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

eststo me_FE: reghdfe econ_conditions_me num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo other_FE: reghdfe econ_conditions_me_other num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_livingcond_proj.tex", replace /// 
keep(num_projects_ch) ///
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

eststo me_FE: reghdfe econ_conditions_me mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo other_FE: reghdfe econ_conditions_me_other mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_livingcond_mon.tex", replace /// 
keep(mon_value_ch_million) ///
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



**--------------------------------------------------**
**					FLOW ANALYSIS				  	**
**--------------------------------------------------**

***********************************
*** 	Performance & Trust 	*** 
***********************************

** Number of projects 

* With respondents controls

eststo performance_mp_r: reghdfe good_performance_MP flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo performance_pres_r: reghdfe trust_MP flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo performance_mp_c: reghdfe good_performance_MP flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo performance_pres_c: reghdfe trust_MP flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year  

eststo performance_mp_c2: reghdfe good_performance_MP flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_pres_c2: reghdfe trust_MP flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_performance_proj_flow.tex", replace /// 
keep(flow_proj_ch) ///
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

eststo performance_mp_r: reghdfe good_performance_MP flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo performance_pres_r: reghdfe trust_MP flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo performance_mp_c: reghdfe good_performance_MP flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo performance_pres_c: reghdfe trust_MP flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo performance_mp_c2: reghdfe good_performance_MP flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_pres_c2: reghdfe trust_MP flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_performance_mon_flow.tex", replace /// 
keep(flow_mon_ch) ///
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

** Number of projects 

** Panel A

* With respondents controls 

eststo econ_r: reghdfe manage_economy flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo jobs_r: reghdfe manage_jobs flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls  

eststo econ_c: reghdfe manage_economy flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo jobs_c: reghdfe manage_jobs flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo econ_c2: reghdfe manage_economy flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo jobs_c2: reghdfe manage_jobs flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab econ_r econ_c econ_c2 ///
jobs_r jobs_c jobs_c2 /// 
using "$output_tables/Donor_satisf_proj_flow.tex", replace fragment /// 
keep(flow_proj_ch) ///
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

eststo corr_r: reghdfe manage_corruption flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_r: reghdfe manage_roads flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo corr_c: reghdfe manage_corruption flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo road_FE_c: reghdfe manage_roads flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year  

eststo corr_c2: reghdfe manage_corruption flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_FE_c2: reghdfe manage_roads flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab corr_r corr_c corr_c2 ///
road_r road_FE_c road_FE_c2 ///   
using "$output_tables/Donor_satisf_proj_flow.tex", append fragment /// 
keep(flow_proj_ch) ///
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

* With respondents controls 

eststo econ_r: reghdfe manage_economy flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo jobs_r: reghdfe manage_jobs flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls  

eststo econ_c: reghdfe manage_economy flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo jobs_c: reghdfe manage_jobs flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo econ_c2: reghdfe manage_economy flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo jobs_c2: reghdfe manage_jobs flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab econ_r econ_c econ_c2 ///
jobs_r jobs_c jobs_c2 /// 
using "$output_tables/Donor_satisf_mon_flow.tex", replace fragment /// 
keep(flow_mon_ch) ///
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

eststo corr_r: reghdfe manage_corruption flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_r: reghdfe manage_roads flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo corr_c: reghdfe manage_corruption flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo road_FE_c: reghdfe manage_roads flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year  

eststo corr_c2: reghdfe manage_corruption flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_FE_c2: reghdfe manage_roads flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab corr_r corr_c corr_c2 ///
road_r road_FE_c road_FE_c2 ///   
using "$output_tables/Donor_satisf_mon_flow.tex", append fragment /// 
keep(flow_mon_ch) ///
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

eststo tecn_FE: reghdfe tecn_services flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe road flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace 


* With respondent and constituency controls 

eststo tecn_FE_c: reghdfe tecn_services flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo road_FE_c: reghdfe road flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo tecn_FE_c2: reghdfe tecn_services flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_FE_c2: reghdfe road flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_services_proj_flow.tex", replace /// 
keep(flow_proj_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "Country X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Utility Access" "Road Presence", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Montary value normalized  

* With constituencies fe

eststo tecn_FE: reghdfe tecn_services flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo road_FE: reghdfe road flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo tecn_FE_c: reghdfe tecn_services flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace    

eststo road_FE_c: reghdfe road flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year  

eststo tecn_FE_c2: reghdfe tecn_services flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)      
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_FE_c2: reghdfe road flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_services_mon_flow.tex", replace /// 
keep(flow_mon_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "\addlinespace Obs.")) ///
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

eststo demand_FE: reghdfe demand_democracy flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe supply_democracy_raw flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo demand_FE_c: reghdfe demand_democracy flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply_FE_c: reghdfe supply_democracy_raw flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand_FE_c2: reghdfe demand_democracy flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_FE_c2: reghdfe supply_democracy_raw flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_dem_proj_flow.tex", replace /// 
keep(flow_proj_ch) ///
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

eststo demand_FE: reghdfe demand_democracy flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe supply_democracy_raw flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo demand_FE_c: reghdfe demand_democracy flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply_FE_c: reghdfe supply_democracy_raw flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand_FE_c2: reghdfe demand_democracy flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_FE_c2: reghdfe supply_democracy_raw flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_dem_mon_flow.tex", replace /// 
keep(flow_mon_ch) ///
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

eststo demand_FE: reghdfe supply_democracy_sat flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe rulelaw_dem_dummy flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls

eststo demand_FE_c: reghdfe supply_democracy_sat flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply_FE_c: reghdfe rulelaw_dem_dummy flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand_FE_c2: reghdfe supply_democracy_sat flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_FE_c2: reghdfe rulelaw_dem_dummy flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_dem2_proj_flow.tex", replace /// 
keep(flow_proj_ch) ///
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

* With constituencies fe

eststo demand_FE: reghdfe supply_democracy_sat flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply_FE: reghdfe rulelaw_dem_dummy flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo demand_FE_c: reghdfe supply_democracy_sat flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply_FE_c: reghdfe rulelaw_dem_dummy flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand_FE_c2: reghdfe supply_democracy_sat flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_FE_c2: reghdfe rulelaw_dem_dummy flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_dem2_mon_flow.tex", replace /// 
keep(flow_mon_ch) ///
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

eststo pres_FE: reghdfe econ_conditions_country flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo past_FE: reghdfe improved_econ_conditions_country flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo fut_FE: reghdfe exp_econ_conditions_country flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo pres_FE_c: reghdfe econ_conditions_country flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo past_FE_c: reghdfe improved_econ_conditions_country flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo fut_FE_c: reghdfe exp_econ_conditions_country flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year

eststo pres_FE_c2: reghdfe econ_conditions_country flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_FE_c2: reghdfe improved_econ_conditions_country flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_FE_c2: reghdfe exp_econ_conditions_country flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_econcond_proj_flow.tex", replace /// 
keep(flow_proj_ch) ///
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

eststo pres_FE: reghdfe econ_conditions_country flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo past_FE: reghdfe improved_econ_conditions_country flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


eststo fut_FE: reghdfe exp_econ_conditions_country flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo pres_FE_c: reghdfe econ_conditions_country flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo past_FE_c: reghdfe improved_econ_conditions_country flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo fut_FE_c: reghdfe exp_econ_conditions_country flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo pres_FE_c2: reghdfe econ_conditions_country flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo past_FE_c2: reghdfe improved_econ_conditions_country flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo fut_FE_c2: reghdfe exp_econ_conditions_country flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_econcond_mon_flow.tex", replace /// 
keep(flow_mon_ch) ///
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

eststo me_FE: reghdfe econ_conditions_me flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo other_FE: reghdfe econ_conditions_me_other flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo me_FE_c: reghdfe econ_conditions_me flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo other_FE_c: reghdfe econ_conditions_me_other flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo me_FE_c2: reghdfe econ_conditions_me flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_FE_c2: reghdfe econ_conditions_me_other flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_livingcond_proj_flow.tex", replace /// 
keep(flow_proj_ch) ///
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

eststo me_FE: reghdfe econ_conditions_me flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo other_FE: reghdfe econ_conditions_me_other flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondents and constituency controls 

eststo me_FE_c: reghdfe econ_conditions_me flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo other_FE_c: reghdfe econ_conditions_me_other flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year 

eststo me_FE_c2: reghdfe econ_conditions_me flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_FE_c2: reghdfe econ_conditions_me_other flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_livingcond_mon_flow.tex", replace /// 
keep(flow_mon_ch) ///
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


***********************************************
*** 		Heterogeneity: Salience 		*** 
***********************************************

//Media Exposure: radio_news tv_news radio_news paper_news

gen interaction_radio_proj = radio_news * flow_proj_ch
gen interaction_radio_mon = radio_news * flow_mon_ch

** Number of projects 

* With respondent controls

eststo china_r: reghdfe good_performance_MP interaction_radio_proj flow_proj_ch radio_news $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo interest_r: reghdfe trust_MP interaction_radio_proj flow_proj_ch radio_news $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls  

eststo china_c: reghdfe good_performance_MP interaction_radio_proj flow_proj_ch radio_news $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo interest_c: reghdfe trust_MP interaction_radio_proj flow_proj_ch radio_news $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year  

eststo china_c2: reghdfe good_performance_MP interaction_radio_proj flow_proj_ch radio_news $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo interest_c2: reghdfe trust_MP interaction_radio_proj flow_proj_ch radio_news $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab china_r china_c china_c2 ///
interest_r interest_c interest_c2 ///
using "$output_tables/Donor_perf_proj_flow_het_radio.tex", replace /// 
keep(flow_proj_ch interaction_radio_proj) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good performance MP" "Trust MP", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary value normalized 

* With respondent controls 

eststo china_r: reghdfe good_performance_MP interaction_radio_mon radio_news flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo interest_r: reghdfe trust_MP interaction_radio_mon radio_news flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls  

eststo china_c: reghdfe good_performance_MP interaction_radio_mon radio_news flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo interest_c: reghdfe trust_MP interaction_radio_mon radio_news flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo china_c2: reghdfe good_performance_MP interaction_radio_mon radio_news flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo interest_c2: reghdfe trust_MP interaction_radio_mon radio_news flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab china_r china_c china_c2 ///
interest_r interest_c interest_c2 ///
using "$output_tables/Donor_perf_mon_flow_het_radio.tex", replace /// 
keep(flow_mon_ch interaction_radio_mon) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good performance MP" "Trust MP", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes noobs  

eststo clear 

exit

gen as_mon_value_ch = asinh(mon_value_ch_million)
gen as_mon_value_wb = asinh(mon_value_wb_million)

gen any_china = mon_value_ch > 0 

reghdfe manage_economy as_mon_value_ch $controls_dem $controls_const_by_year as_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

reghdfe manage_economy ln_mon_value_ch any_china $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)

sum mon_value_ch_million if mon_value_ch_million>0, detail
local p75 = r(p75)
local p90 = r(p90)
local p95 = r(p95)
local p99 = r(p99)

gen ch_tailbin = .
replace ch_tailbin = 1 if mon_value_ch_million>0 & mon_value_ch_million<=`p75'
replace ch_tailbin = 2 if mon_value_ch_million>`p75' & mon_value_ch_million<=`p90'
replace ch_tailbin = 3 if mon_value_ch_million>`p90' & mon_value_ch_million<=`p95'
replace ch_tailbin = 4 if mon_value_ch_million>`p95' & mon_value_ch_million<=`p99'
replace ch_tailbin = 5 if mon_value_ch_million>`p99'

label define chb 1 "0+–p75" 2 "p75–p90" 3 "p90–p95" 4 "p95–p99" 5 "p99+"
label values ch_tailbin chb

tab ch_tailbin if mon_value_ch_million>0

reghdfe manage_economy ib1.ch_tailbin ///
  $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend ///
  if mon_value_ch_million>0 [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
 
  

reghdfe manage_economy mon_value_ch $controls_dem $controls_const_by_year mon_bin mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID) 

margins mon_bin, post
marginsplot, ///
    ytitle("Pr(manage_economy=1)") ///
    xtitle("Decile of Chinese monetary value (positives)") ///
    title("Intensity margin: dose-response across positive values")
	

*** Heterogeneity on monetary value 

logit manage_economy ln_mon_value_ch ///
    i.year i.eth_FE i._ID ///
    [pw=withinwt], vce(cluster _ID)

margins, at(ln_mon_value_ch=(0(1)20))
marginsplot, ///
    ytitle("Pr(Improving living standards)") ///
    xtitle("Log(1+Monetary Value)") ///
    title("Heterogeneous effect of monetary value")

marginsplot, ///
    addplot(histogram ln_mon_value_ch, percent yaxis(2)) ///
    ytitle("Pr(improving)") 
	
	
logit trust_inc ln_mon_value_ch ///
    i.year i.eth_FE i._ID ///
    [pw=withinwt], vce(cluster _ID)

margins, at(ln_mon_value_ch=(0(1)19)) vce(unconditional)
marginsplot, ///
    ytitle("Pr(Trust incumbent)") ///
    xtitle("ln(1 + Monetary Value)") ///
    title("Heterogeneous effect of monetary value")

marginsplot, ///
    addplot(histogram ln_mon_value_ch, percent yaxis(2)) ///
    ytitle("Pr(improving)") 
	
	
logit good_performance_pres ln_mon_value_ch ///
    i.year i.eth_FE i._ID ///
    [pw=withinwt], vce(cluster _ID)

margins, at(ln_mon_value_ch=(0(1)19)) vce(unconditional)
marginsplot, ///
    ytitle("Pr(Good Performance President)") ///
    xtitle("ln(1 + Monetary Value)") ///
    title("Heterogeneous effect of monetary value")

marginsplot, ///
    addplot(histogram ln_mon_value_ch, percent yaxis(2)) ///
    ytitle("Pr(improving)") 

exit

preserve

tempfile diff
tempname hh2
postfile `hh2' int year double b se using `diff', replace

* Base year difference is 0
post `hh2' (2004) (0) (0)

foreach y in 2002 2007 2010 2013 {
    lincom `y'.year#c.num_projects_ch_13
    post `hh2' (`y') (r(estimate)) (r(se))
}
postclose `hh2'

use `diff', clear
gen lb = b - 1.96*se
gen ub = b + 1.96*se

twoway (rcap ub lb year) (scatter b year), ///
    yline(0) xline(2004) ///
    xtitle("Year") ytitle("Difference in effect vs 2004") ///
    title("Δ effect relative to 2004 (interaction terms)") ///
    legend(off)
	
graph export "$output_figures/coef_plot_performanceMP.png", replace 

restore 


** Log monetary value trust 
* Generate time-invariant eventual exposure in each constituency 
bysort _ID: egen ln_mon_value_ch_13 = max(cond(year==2013, ln_mon_value_ch, .))

reghdfe trust_pres c.ln_mon_value_ch_13##ib2004.year $controls_dem $controls_const_by_year [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
lincom c.ln_mon_value_ch_13#2002.year

preserve

tempfile diff
tempname hh2
postfile `hh2' int year double b se using `diff', replace

* Base year difference is 0
post `hh2' (2004) (0) (0)

foreach y in 2002 2007 2010 2013 {
    lincom `y'.year#c.ln_mon_value_ch_13
    post `hh2' (`y') (r(estimate)) (r(se))
}
postclose `hh2'

use `diff', clear
gen lb = b - 1.96*se
gen ub = b + 1.96*se

twoway (rcap ub lb year) (scatter b year), ///
    yline(0) xline(2004) ///
    xtitle("Year") ytitle("Difference in effect vs 2004") ///
    title("Δ effect relative to 2004 (interaction terms)") ///
    legend(off)
	
graph export "$output_figures/coef_plot_trustpres.png", replace 

restore 



** Monetary value Manage economy  
* Generate time-invariant eventual exposure in each constituency 
bysort _ID: egen mon_value_ch_13 = max(cond(year==2014, mon_value_ch_million, .))

reghdfe manage_economy c.mon_value_ch_13##ib3.wave $controls_dem $controls_const_by_year [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
lincom c.mon_value_ch_13#2.wave //significant! 
nlcom _b[c.mon_value_ch_13#2.wave]

reghdfe manage_jobs c.mon_value_ch_13##iib3.wave $controls_dem $controls_const_by_year [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
lincom c.mon_value_ch_13#2.wave

reghdfe manage_corruption c.mon_value_ch_13##ib3.wave $controls_dem $controls_const_by_year [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
lincom c.mon_value_ch_13#2.wave 

preserve

tempfile diff
tempname hh2
postfile `hh2' int year double b se using `diff', replace

* Base year difference is 0
post `hh2' (2004) (0) (0)

foreach y in 2002 2007 2010 2013 {
    lincom `y'.year#c.mon_value_ch_13
    post `hh2' (`y') (r(estimate)) (r(se))
}
postclose `hh2'

use `diff', clear
gen lb = b - 1.96*se
gen ub = b + 1.96*se

twoway (rcap ub lb year) (scatter b year), ///
    yline(0) xline(2004) ///
    xtitle("Year") ytitle("Difference in effect vs 2004") ///
    title("Δ effect relative to 2004 (interaction terms)") ///
    legend(off)
	
graph export "$output_figures/coef_plot_manageecon_mon.png", replace 

restore 

exit

* Adoption wave (first wave with positive cumulative projects)
bysort _ID (wave): egen adopt_w = min(cond(num_projects_ch>0, wave, .))

* Ever-treated constituency indicator
gen ever = !missing(adopt_w)

* Event time (only defined for ever-treated)
gen evt = wave - adopt_w if ever==1

* Keep never-treated + treated observations within window [-2, +2]
keep if ever==0 | inrange(evt, -2, 2)

* Manual event-time dummies (all set to 0 for never-treated)
gen evt_m2 = (evt==-2) if ever==1
replace evt_m2 = 0 if ever==0

* base period is evt=-1 (omit it)

gen evt_0  = (evt==0)  if ever==1
replace evt_0  = 0 if ever==0

gen evt_p1 = (evt==1)  if ever==1
replace evt_p1 = 0 if ever==0

gen evt_p2 = (evt==2)  if ever==1
replace evt_p2 = 0 if ever==0

reghdfe good_performance_MP evt_m2 evt_0 evt_p1 evt_p2 ///
   [pw=withinwt], ///
    absorb(_ID wave eth_FE) vce(cluster _ID)
	
* Store coefficients into a small dataset
tempfile es
tempname hh
postfile `hh' int evt double b se using `es', replace

foreach k in -2 0 1 2 {
    if `k'==-2 local v evt_m2
    if `k'== 0 local v evt_0
    if `k'== 1 local v evt_p1
    if `k'== 2 local v evt_p2

    lincom `v'
    post `hh' (`k') (r(estimate)) (r(se))
}
postclose `hh'

use `es', clear
gen lb = b - 1.96*se
gen ub = b + 1.96*se

twoway (rarea ub lb evt) (line b evt), ///
    yline(0) xline(0) xlabel(-2(1)2) ///
    xtitle("Event time (waves relative to adoption)") ///
    ytitle("Effect relative to evt=-1") ///
    title("Event-study coefficients") legend(off)

	
BBBBBB


** Event study constituency level 
bysort _ID (wave): egen adopt = min(cond(num_projects_ch>0, wave, .))

gen treated = !missing(adopt)
gen evt = wave - adopt if treated==1

keep if treated==0 | inrange(evt, -2, 2)

gen evt_s = evt + 2 if treated==1   // now 0..4

fvset base 1 evt_s

reghdfe good_performance_MP i.evt_s#i.treated ///
    `controls_dem' $controls_const_by_year [pw=withinwt], ///
    absorb(_ID wave eth_FE) vce(cluster _ID)



exit

**--------------------------------------------------**
**				APPENDIX: NOT INCLUDED			  	**
**--------------------------------------------------**


***************************************************
*** 		Trust Incumbent - Opposition		*** 
***************************************************

** Nothing shows up -> Appendix! 

** Number of projects 

* Basic 

eststo trust_inc_No: reghdfe trust_incumbent num_projects_ch [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "No", replace
estadd local control_c "No", replace

eststo trust_opp_No: reghdfe trust_opposition num_projects_ch [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "No", replace
estadd local control_c "No", replace


* With respondent controls 

eststo trust_inc_r: reghdfe trust_incumbent num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace

eststo trust_opp_r: reghdfe trust_opposition num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace


* With respondent and constituency controls + wb 

eststo trust_inc_c: reghdfe trust_incumbent num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace

eststo trust_opp_c: reghdfe trust_opposition num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace


* Export all results table 
esttab trust_inc_No trust_inc_r trust_inc_c ///
trust_opp_No trust_opp_r trust_opp_c ///
using "$output_tables/Donor_trust_inc_proj.tex", replace /// 
keep(num_projects_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\Respondent" "Constituency" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Trust National Incumbent" "Trust National Opposition", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Log Number of projects 

* Basic 

eststo trust_inc_No: reghdfe trust_incumbent ln_num_proj_ch [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "No", replace
estadd local control_c "No", replace

eststo trust_opp_No: reghdfe trust_opposition ln_num_proj_ch [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "No", replace
estadd local control_c "No", replace


* With respondent controls 

eststo trust_inc_r: reghdfe trust_incumbent ln_num_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace

eststo trust_opp_r: reghdfe trust_opposition ln_num_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace


* With respondent and constituency controls + wb 

eststo trust_inc_c: reghdfe trust_incumbent ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace

eststo trust_opp_c: reghdfe trust_opposition ln_num_proj_ch $controls_dem $controls_const_by_year ln_num_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace


* Export all results table 
esttab trust_inc_No trust_inc_r trust_inc_c ///
trust_opp_No trust_opp_r trust_opp_c ///
using "$output_tables/Donor_trust_inc_ln_proj.tex", replace /// 
keep(ln_num_proj_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\Respondent" "Constituency" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Trust National Incumbent" "Trust National Opposition", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary value normalized 

* Basic

eststo trust_inc_No: reghdfe trust_incumbent  mon_value_ch_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "No", replace
estadd local control_c "No", replace

eststo trust_opp_No: reghdfe trust_opposition mon_value_ch_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "No", replace
estadd local control_c "No", replace


* With respondent controls 

eststo trust_inc_r: reghdfe trust_incumbent mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace

eststo trust_opp_r: reghdfe trust_opposition mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace


* With respondent and constituency controls + wb 

eststo trust_inc_c: reghdfe trust_incumbent mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace

eststo trust_opp_c: reghdfe trust_opposition mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace


* Export all results table 
esttab trust_inc_No trust_inc_r trust_inc_c ///
trust_opp_No  trust_opp_r trust_opp_c ///
using "$output_tables/Donor_trust_inc_mon.tex", replace /// 
keep(mon_value_ch_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\Respondent" "Constituency" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Trust National Incumbent" "Trust National Opposition", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Log Monetary value 

* Basic

eststo trust_inc_No: reghdfe trust_incumbent ln_mon_value_ch [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "No", replace
estadd local control_c "No", replace

eststo trust_opp_No: reghdfe trust_opposition ln_mon_value_ch [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "No", replace
estadd local control_c "No", replace


* With respondent controls 

eststo trust_inc_r: reghdfe trust_incumbent ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace

eststo trust_opp_r: reghdfe trust_opposition ln_mon_value_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace


* With respondent and constituency controls + wb 

eststo trust_inc_c: reghdfe trust_incumbent ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_incumbent [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace

eststo trust_opp_c: reghdfe trust_opposition ln_mon_value_ch $controls_dem $controls_const_by_year ln_mon_value_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_opposition [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace


* Export all results table 
esttab trust_inc_No trust_inc_r trust_inc_c ///
trust_opp_No  trust_opp_r trust_opp_c ///
using "$output_tables/Donor_trust_inc_ln_mon.tex", replace /// 
keep(ln_mon_value_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\Respondent" "Constituency" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Trust National Incumbent" "Trust National Opposition", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 



