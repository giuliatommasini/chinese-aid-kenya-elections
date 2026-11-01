********************************************************************************

* Author: Giulia 
* Date Created: January 2026
* Purpose: Exogeneity tests Survey Analysis

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
 

***************************************************************
*** 			Exogeneity Political Targeting  	 		***
***************************************************************

gen interaction_birthplace = presence_leader_birthplace2002 * wave
label var interaction_birthplace "Political Leader's Birthplace $\times$ Wave FE"


* With respondents and constituency controls + wb 

eststo performance_mp_c: reghdfe num_projects_ch interaction_birthplace $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum num_projects_ch [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo performance_pres_c: reghdfe mon_value_ch_million interaction_birthplace $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum mon_value_ch_million [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo dum_c: reghdfe  ever_treat_ch interaction_birthplace $controls_dem $controls_const_by_year ever_treat_wb [pw=withinwt], absorb(county_id year eth_FE) vce(cluster _ID)
sum ever_treat_ch [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondents and constituency controls + county X year  

eststo performance_mp_c2: reghdfe num_projects_ch interaction_birthplace $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum num_projects_ch [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_pres_c2: reghdfe mon_value_ch_million interaction_birthplace $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum mon_value_ch_million [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo dum_c2: reghdfe ever_treat_ch interaction_birthplace $controls_dem $controls_const_by_year ever_treat_wb $controls_trend [pw=withinwt], absorb(county_id year eth_FE) vce(cluster _ID)
sum ever_treat_ch [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab performance_mp_c performance_mp_c2 ///
performance_pres_c performance_pres_c2 ///
dum_c dum_c2 ///
using "$output_tables/test_birthplace.tex", replace /// 
keep(interaction_birthplace) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Respondent Controls" "Constituency Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Number of Projects" "Monetary Value" "Received Funds", ///
lhs("") pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


***************************************************************
*** 			Anticipation Effects Stock  	 			***
***************************************************************

preserve 

* Drop constituencies receiving aid  
bysort _ID: egen bad_id = max(num_projects_ch > 0 & year < 2007)
keep if bad_id == 0
drop bad_id

* Generate time-invariant eventual exposure in each constituency 
bysort _ID: egen num_projects_ch_14 = max(cond(year==2014, num_projects_ch, .))
bysort _ID: egen mon_value_ch_14 = max(cond(year==2014, mon_value_ch_million, .))

tabulate wave, generate(wave_)
gen double proj_w2 = num_projects_ch_14 * wave_1
gen double proj_w4 = num_projects_ch_14 * wave_3
gen double proj_w5 = num_projects_ch_14 * wave_4
gen double proj_w6 = num_projects_ch_14 * wave_5

gen double mon_w2 = mon_value_ch_14 * wave_1
gen double mon_w4 = mon_value_ch_14 * wave_3 
gen double mon_w5 = mon_value_ch_14 * wave_4
gen double mon_w6 = mon_value_ch_14 * wave_5


** Good performance & trust

eststo mp_proj: reghdfe good_performance_MP c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo mp_mon: reghdfe good_performance_MP c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_proj: reghdfe trust_MP c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_mon: reghdfe trust_MP c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab mp_proj mp_mon ///
pres_proj pres_mon ///
using "$output_tables/parallel_tr_performance.tex", replace /// 
keep(proj_w2 mon_w2) ///
coeflabels(proj_w2 "Number of Projects X Wave 1" mon_w2 "Monetary Value X Wave 1") ///
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " ", lhs("")) ///
mgroups("Good performance MP" "Trust MP", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Satisfaction 

eststo econ_proj: reghdfe manage_economy c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo econ_mon: reghdfe manage_economy c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo job_proj: reghdfe manage_jobs c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo job_mon: reghdfe manage_jobs c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo corr_proj: reghdfe manage_corruption c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo corr_mon: reghdfe manage_corruption c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo ro_proj: reghdfe manage_roads c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo ro_mon: reghdfe manage_roads c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab econ_proj econ_mon ///
job_proj job_mon ///
corr_proj corr_mon /// 
ro_proj ro_mon ///
using "$output_tables/parallel_tr_satisf.tex", replace /// 
keep(proj_w2 mon_w2) ///
coeflabels(proj_w2 "Number of Projects X Wave 1" mon_w2 "Monetary Value X Wave 1") ///
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Manage Economy" "Create Jobs" "Fighting Corruption" "Maintaining Roads", ///
lhs("") pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Presence of services 

eststo inf_proj: reghdfe tecn_services  c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo inf_mon: reghdfe tecn_services c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_proj: reghdfe road c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_mon: reghdfe road c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab inf_proj inf_mon ///
road_proj road_mon ///
using "$output_tables/parallel_tr_services.tex", replace /// 
keep(proj_w2 mon_w2) ///
coeflabels(proj_w2 "Number of Projects X Wave 1" mon_w2 "Monetary Value X Wave 1") ///
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "county X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " ", lhs("")) ///
mgroups("Utility Access" "Road Presence", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Demand & Supply Democracy  

eststo d_proj: reghdfe demand_democracy c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo d_mon: reghdfe demand_democracy c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s_proj: reghdfe supply_democracy_raw c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s_mon: reghdfe supply_democracy_raw c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab d_proj d_mon ///
s_proj s_mon ///
using "$output_tables/parallel_tr_dem.tex", replace /// 
keep(proj_w2 mon_w2) ///
coeflabels(proj_w2 "Number of Projects X Wave 1" mon_w2 "Monetary Value X Wave 1") ///
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " ", lhs("")) ///
mgroups("Demand for Democracy" "Perceived Extent of Democracy", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Support for Democracy  

eststo d_proj: reghdfe supply_democracy_sat c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo d_mon: reghdfe supply_democracy_sat c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s_proj: reghdfe rulelaw_dem_dummy c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s_mon: reghdfe rulelaw_dem_dummy c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab d_proj d_mon ///
s_proj s_mon ///
using "$output_tables/parallel_tr_dem2.tex", replace /// 
keep(proj_w2 mon_w2) ///
coeflabels(proj_w2 "Number of Projects X Wave 1" mon_w2 "Monetary Value X Wave 1") ///
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " ", lhs("")) ///
mgroups("Satisfaction with Democracy" "Democracy Support", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Economic Conditions  

eststo pres_proj: reghdfe econ_conditions_country c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_mon: reghdfe econ_conditions_country c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_proj: reghdfe improved_econ_conditions_country c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_mon: reghdfe improved_econ_conditions_country c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_proj: reghdfe exp_econ_conditions_country c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_mon: reghdfe exp_econ_conditions_country c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab pres_proj pres_mon ///
past_proj past_mon ///
fut_proj fut_mon ///
using "$output_tables/parallel_tr_econcond.tex", replace /// 
keep(proj_w2 mon_w2) ///
coeflabels(proj_w2 "Number of Projects X Wave 1" mon_w2 "Monetary Value X Wave 1") ///
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good Economic Conditions" "Improved Economy" "Expect Better Economy", ///
lhs("") pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Living Conditions

eststo me_proj: reghdfe econ_conditions_me c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo me_mon: reghdfe econ_conditions_me c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_proj: reghdfe econ_conditions_me_other c.num_projects_ch_14 proj_w2 proj_w4 proj_w5 proj_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend num_projects_wb [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_mon: reghdfe econ_conditions_me_other c.mon_value_ch_14 mon_w2 mon_w4 mon_w5 mon_w6 ib3.wave $controls_dem $controls_const_by_year $controls_trend mon_value_wb_million [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab me_proj me_mon ///
other_proj other_mon ///
using "$output_tables/parallel_tr_livingcond.tex", replace /// 
keep(proj_w2 mon_w2) ///
coeflabels(proj_w2 "Number of Projects X Wave 1" mon_w2 "Monetary Value X Wave 1") ///
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " ", lhs("")) ///
mgroups("Positive Present Living Conditions" "Positive Relative Living Conditions", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


restore 


***************************************************************
*** 			Parallel Trends Leads & Lags  	 			***
***************************************************************

** Performance & trust 

eststo mp_proj: reghdfe good_performance_MP flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo mp_mon: reghdfe good_performance_MP flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_proj: reghdfe trust_MP flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_mon: reghdfe trust_MP flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab mp_proj mp_mon ///
pres_proj pres_mon ///
using "$output_tables/leads_perf.tex", replace /// 
keep(flow_proj_ch_f1 flow_mon_ch_f1) ///
coeflabels(flow_proj_ch_f1 "Lead -1 Projects" flow_mon_ch_f1 "Lead -1 Investment") ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Respondent Controls" "Constituency Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " ", lhs("")) ///
mgroups("Good performance MP" "Trust MP", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Satisfaction 

eststo econ_proj: reghdfe manage_economy flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo econ_mon: reghdfe manage_economy flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year  flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo job_proj: reghdfe manage_jobs flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo job_mon: reghdfe manage_jobs flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo corr_proj: reghdfe manage_corruption flow_proj_ch_f1 flow_proj_ch $controls_dem flow_proj_wb $controls_const_by_year $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo corr_mon: reghdfe manage_corruption flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo ro_proj: reghdfe manage_roads flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year  flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo ro_mon: reghdfe manage_roads flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab econ_proj econ_mon ///
job_proj job_mon ///
corr_proj corr_mon /// 
ro_proj ro_mon ///
using "$output_tables/leads_sat.tex", replace /// 
keep(flow_proj_ch_f1 flow_mon_ch_f1) ///
coeflabels(flow_proj_ch_f1 "Lead -1 Projects" flow_mon_ch_f1 "Lead -1 Investment") ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Respondent Controls" "Constituency Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Manage Economy" "Create Jobs" "Fighting Corruption" "Maintaining Roads", ///
lhs("") pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Presence of services  

eststo tecn_proj: reghdfe tecn_services flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo tecn_mon: reghdfe tecn_services flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_proj: reghdfe road flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_mon: reghdfe road flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab tecn_proj tecn_mon ///
road_proj road_mon ///
using "$output_tables/leads_serv.tex", replace /// 
keep(flow_proj_ch_f1 flow_mon_ch_f1) ///
coeflabels(flow_proj_ch_f1 "Lead -1 Projects" flow_mon_ch_f1 "Lead -1 Investment") ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Respondent Controls" "Constituency Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " ", lhs("")) ///
mgroups("Utility Access" "Road Presence", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear  


** Demand and Supply Democracy 

eststo d_proj: reghdfe demand_democracy flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo d_mon: reghdfe demand_democracy flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s_proj: reghdfe supply_democracy_raw flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s_mon: reghdfe supply_democracy_raw flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo d1_proj: reghdfe supply_democracy_sat flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo d1_mon: reghdfe supply_democracy_sat flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s1_proj: reghdfe rulelaw_dem_dummy flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s1_mon: reghdfe rulelaw_dem_dummy flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab d_proj d_mon ///
s_proj s_mon ///
d1_proj d1_mon ///
s1_proj s1_mon ///
using "$output_tables/leads_dem.tex", replace /// 
keep(flow_proj_ch_f1 flow_mon_ch_f1) ///
coeflabels(flow_proj_ch_f1 "Lead -1 Projects" flow_mon_ch_f1 "Lead -1 Investment") ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Respondent Controls" "Constituency Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Demand for Democracy" "Perceived Extent of Democracy" "Satisfaction with Democracy" "Democracy Support", ///
lhs("") pattern(1 0 1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Support for Democracy 

eststo d1_proj: reghdfe supply_democracy_sat flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo d1_mon: reghdfe supply_democracy_sat flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s1_proj: reghdfe rulelaw_dem_dummy flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo s1_mon: reghdfe rulelaw_dem_dummy flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab d1_proj d1_mon ///
s1_proj s1_mon ///
using "$output_tables/leads_dem2.tex", replace /// 
keep(flow_proj_ch_f1 flow_mon_ch_f1) ///
coeflabels(flow_proj_ch_f1 "Lead -1 Projects" flow_mon_ch_f1 "Lead -1 Investment") ///
stats(mean_depvar sd_depvar r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "County X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " ", lhs("")) ///
mgroups("Satisfaction with Democracy" "Democracy Support", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Economic Conditions  

eststo pres_proj: reghdfe econ_conditions_country flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_mon: reghdfe econ_conditions_country flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_proj: reghdfe improved_econ_conditions_country flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_mon: reghdfe improved_econ_conditions_country flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_proj: reghdfe exp_econ_conditions_country flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_mon: reghdfe exp_econ_conditions_country flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab pres_proj pres_mon ///
past_proj past_mon ///
fut_proj fut_mon ///
using "$output_tables/leads_econcond.tex", replace /// 
keep(flow_proj_ch_f1 flow_mon_ch_f1) ///
coeflabels(flow_proj_ch_f1 "Lead -1 Projects" flow_mon_ch_f1 "Lead -1 Investment") ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Respondent Controls" "Constituency Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good Economic Conditions" "Improved Economy" "Expect Better Economy", ///
lhs("") pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 


** Living Conditions

eststo me_proj: reghdfe econ_conditions_me flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo me_mon: reghdfe econ_conditions_me flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_proj: reghdfe econ_conditions_me_other flow_proj_ch_f1 flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_mon: reghdfe econ_conditions_me_other flow_mon_ch_f1 flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID wave eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab me_proj me_mon ///
other_proj other_mon ///
using "$output_tables/leads_livingcond.tex", replace /// 
keep(flow_proj_ch_f1 flow_mon_ch_f1) ///
coeflabels(flow_proj_ch_f1 "Lead -1 Projects" flow_mon_ch_f1 "Lead -1 Investment") ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Respondent Controls" "Constituency Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " ", lhs("")) ///
mgroups("Positive Present Living Conditions" "Positive Relative Living Conditions", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
star(* 0.10 ** 0.05 *** 0.01) ///
b(3) se(3) se label compress ///
collabels(none) nonotes noobs

eststo clear 

