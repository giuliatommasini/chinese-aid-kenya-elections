********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Spillover Effect Survey 

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

* Generate interaction variable 
gen int_spillover_proj = spillover_intensity_proj * num_projects_ch
gen int_spillover_mon = spillover_intensity_mon * mon_value_ch_million

label var int_spillover_proj "Spillover Intensity $\times$ Projects"
label var int_spillover_mon "Spillover Intensity $\times$ Investment"


***********************************
*** 	Performance & Trust 	*** 
***********************************

** Number of Projects 

eststo performance_mp: reghdfe good_performance_MP num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_mp_1: reghdfe good_performance_MP num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_mp_2: reghdfe good_performance_MP num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo trust_mp: reghdfe trust_MP num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo trust_mp_1: reghdfe trust_MP num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo trust_mp_2: reghdfe trust_MP num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export all results table 
esttab performance_mp performance_mp_1 performance_mp_2 ///
trust_mp trust_mp_1 trust_mp_2  ///
using "$output_tables/Spillover_perf_proj.tex", replace /// 
keep(num_projects_ch spillover_intensity_proj int_spillover_proj) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good Performance MPs" "Trust MPs", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary Value 

eststo performance_mp: reghdfe good_performance_MP mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_mp_1: reghdfe good_performance_MP mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo performance_mp_2: reghdfe good_performance_MP mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum good_performance_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo trust_mp: reghdfe trust_MP mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo trust_mp_1: reghdfe trust_MP mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo trust_mp_2: reghdfe trust_MP mon_value_ch_million spillover_intensity_mon int_spillover_mon  $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum trust_MP [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab performance_mp performance_mp_1 performance_mp_2 ///
trust_mp trust_mp_1 trust_mp_2  ///
using "$output_tables/Spillover_perf_mon.tex", replace /// 
keep(mon_value_ch_million spillover_intensity_mon int_spillover_mon) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good Performance MPs" "Trust MPs", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


***********************************
*** 		Satisfaction 		*** 
***********************************

** Number of Projects 

* Panel A

eststo econ: reghdfe manage_economy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID) 
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   

eststo econ_1: reghdfe manage_economy num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  

eststo econ_2: reghdfe manage_economy num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)   
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   

eststo job: reghdfe manage_jobs num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   

eststo job_1: reghdfe manage_jobs num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  

eststo job_2: reghdfe manage_jobs num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  


* Export all results table 
esttab econ econ_1 econ_2 ///
job job_1 job_2  ///
using "$output_tables/Spillover_satisf_proj.tex", replace fragment /// 
keep(num_projects_ch spillover_intensity_proj int_spillover_proj) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) /// 
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Manage Economy" "Creating Jobs", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A}} \\")

eststo clear 


* Panel B

eststo price: reghdfe manage_corruption num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID) 
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo price_1: reghdfe manage_corruption num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID) 
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo price_2: reghdfe manage_corruption num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID) 
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road: reghdfe manage_roads num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_1: reghdfe manage_roads num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_2: reghdfe manage_roads num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab price price_1 price_2 ///
road road_1 road_2  ///
using "$output_tables/Spillover_satisf_proj.tex", append fragment /// 
keep(num_projects_ch spillover_intensity_proj int_spillover_proj) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Fighting Corruption" "Mantaining Roads", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B}} \\") postfoot("\hline\hline\end{tabular}")

eststo clear 


** Monatry Value Normalized 

* Panel A

eststo econ: reghdfe manage_economy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   

eststo econ_1: reghdfe manage_economy mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)   
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   

eststo econ_2: reghdfe manage_economy mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)   
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     

eststo job: reghdfe manage_jobs mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   

eststo job_1: reghdfe manage_jobs mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  

eststo job_2: reghdfe manage_jobs mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  


* Export all results table 
esttab econ econ_1 econ_2 ///
job job_1 job_2  ///
using "$output_tables/Spillover_satisf_mon.tex", replace fragment /// 
keep(mon_value_ch_million spillover_intensity_mon int_spillover_mon) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) /// 
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Manage Economy" "Creating Jobs", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A}} \\")

eststo clear 


* Panel B

eststo price: reghdfe manage_corruption mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID) 
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo price_1: reghdfe manage_corruption mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID) 
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo price_2: reghdfe manage_corruption mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID) 
sum manage_corruption [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road: reghdfe manage_roads mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_1: reghdfe manage_roads mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_2: reghdfe manage_roads mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab price price_1 price_2 ///
road road_1 road_2  ///
using "$output_tables/Spillover_satisf_mon.tex", append fragment /// 
keep(mon_value_ch_million spillover_intensity_mon int_spillover_mon) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Fighting Corruption" "Mantaining Roads", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B}} \\") postfoot("\hline\hline\end{tabular}")

eststo clear 


*******************************************
*** 		Presence of Services 		*** 
******************************************* 

** Number of Projects 

eststo tecn: reghdfe tecn_services num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo tecn_1: reghdfe tecn_services num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo tecn_2: reghdfe tecn_services num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road: reghdfe road num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_1: reghdfe road num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd) 
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_2: reghdfe road num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd) 
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab tecn tecn_1 tecn_2  ///
road road_1 road_2  ///
using "$output_tables/Spillover_serv_proj.tex", replace /// 
keep(num_projects_ch spillover_intensity_proj int_spillover_proj) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Utility Access" "Road Presence", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary Value Normalized 

eststo tecn: reghdfe tecn_services mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd) 
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo tecn_1: reghdfe tecn_services mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd) 
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo tecn_2: reghdfe tecn_services mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum tecn_services [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd) 
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road: reghdfe road mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd) 
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_1: reghdfe road mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd) 
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo road_2: reghdfe road mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)  
sum road [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd) 
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab tecn tecn_1 tecn_2  ///
road road_1 road_2  ///
using "$output_tables/Spillover_serv_mon.tex", replace /// 
keep(mon_value_ch_million spillover_intensity_mon int_spillover_mon) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Utility Access" "Road Presence", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


***************************************************
*** 		Demand & Supply for Democracy  		*** 
*************************************************** 

** Panel A 

** Number of Projects 

eststo demand: reghdfe demand_democracy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo demand_1: reghdfe demand_democracy num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo demand_2: reghdfe demand_democracy num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply: reghdfe supply_democracy_raw num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_1: reghdfe supply_democracy_raw num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_2: reghdfe supply_democracy_raw num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab demand demand_1 demand_2  ///
supply supply_1 supply_2  ///
using "$output_tables/Spillover_dem_proj.tex", replace fragment /// 
keep(num_projects_ch spillover_intensity_proj int_spillover_proj) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) /// 
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Demand for Democracy" "Perceived Extent of Democracy", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A}} \\")

eststo clear 


** Panel B 

** Number of Projects 

eststo demand: reghdfe supply_democracy_sat num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo demand_1: reghdfe supply_democracy_sat num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo demand_2: reghdfe supply_democracy_sat num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply: reghdfe rulelaw_dem_dummy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_1: reghdfe rulelaw_dem_dummy num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_2: reghdfe rulelaw_dem_dummy num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab demand demand_1 demand_2  ///
supply supply_1 supply_2  ///
using "$output_tables/Spillover_dem_proj.tex", append fragment /// 
keep(num_projects_ch spillover_intensity_proj int_spillover_proj) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Satisfaction with Democracy" "Democracy Support", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B}} \\") postfoot("\hline\hline\end{tabular}")

eststo clear 


** Monetary Value Normalized 

eststo demand: reghdfe demand_democracy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo demand_1: reghdfe demand_democracy mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo demand_2: reghdfe demand_democracy mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum demand_democracy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply: reghdfe supply_democracy_raw mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_1: reghdfe supply_democracy_raw mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_2: reghdfe supply_democracy_raw mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_raw [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab demand demand_1 demand_2  ///
supply supply_1 supply_2  ///
using "$output_tables/Spillover_dem_mon.tex", replace fragment /// 
keep(mon_value_ch_million spillover_intensity_mon int_spillover_mon) ///
star(* 0.10 ** 0.05 *** 0.01) ///   
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///    
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Demand for Democracy" "Perceived Extent of Democracy", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A}} \\")

eststo clear 


** Panel B 

** Monetary Value Normalized 

eststo demand: reghdfe supply_democracy_sat mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo demand_1: reghdfe supply_democracy_sat mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo demand_2: reghdfe supply_democracy_sat mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply: reghdfe rulelaw_dem_dummy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_1: reghdfe rulelaw_dem_dummy mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply_2: reghdfe rulelaw_dem_dummy mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab demand demand_1 demand_2  ///
supply supply_1 supply_2  ///
using "$output_tables/Spillover_dem_mon.tex", append fragment /// 
keep(mon_value_ch_million spillover_intensity_mon int_spillover_mon) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Satisfaction with Democracy" "Democracy Support", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B}} \\") postfoot("\hline\hline\end{tabular}")

eststo clear 


*******************************************
*** 		Economic Conditions 		*** 
******************************************* 

** Number of Projects

eststo pres: reghdfe econ_conditions_country num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_1: reghdfe econ_conditions_country num_projects_ch spillover_intensity_proj  $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_2: reghdfe econ_conditions_country num_projects_ch spillover_intensity_proj int_spillover_proj  $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past: reghdfe improved_econ_conditions_country num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_1: reghdfe improved_econ_conditions_country num_projects_ch spillover_intensity_proj  $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_2: reghdfe improved_econ_conditions_country num_projects_ch spillover_intensity_proj int_spillover_proj  $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut: reghdfe exp_econ_conditions_country num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_1: reghdfe exp_econ_conditions_country num_projects_ch spillover_intensity_proj  $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_2: reghdfe exp_econ_conditions_country num_projects_ch spillover_intensity_proj int_spillover_proj  $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab pres pres_1 pres_2 ///
past past_1 past_2 /// 
fut fut_1 fut_2 ///
using "$output_tables/Spillover_econcond_proj.tex", replace /// 
keep(num_projects_ch spillover_intensity_proj int_spillover_proj) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Good Economic Conditions" "Improved Economy" "Expect Better Economy", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary Value Normalized 

eststo pres: reghdfe econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_1: reghdfe econ_conditions_country mon_value_ch_million spillover_intensity_mon  $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo pres_2: reghdfe econ_conditions_country mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past: reghdfe improved_econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_1: reghdfe improved_econ_conditions_country mon_value_ch_million spillover_intensity_mon  $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo past_2: reghdfe improved_econ_conditions_country mon_value_ch_million spillover_intensity_mon int_spillover_mon  $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut: reghdfe exp_econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_1: reghdfe exp_econ_conditions_country mon_value_ch_million spillover_intensity_mon  $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_2: reghdfe exp_econ_conditions_country mon_value_ch_million spillover_intensity_mon int_spillover_mon  $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum exp_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab pres pres_1 pres_2 ///
past past_1 past_2 /// 
fut fut_1 fut_2 ///
using "$output_tables/Spillover_econcond_mon.tex", replace /// 
keep(mon_value_ch_million spillover_intensity_mon int_spillover_mon) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Good Economic Conditions" "Improved Economy" "Expect Better Economy", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


***************************************
*** 		Living Conditions 		*** 
*************************************** 

** Number of Projects 

eststo me: reghdfe econ_conditions_me num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo me_1: reghdfe econ_conditions_me num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo me_2: reghdfe econ_conditions_me num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other: reghdfe econ_conditions_me_other num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_1: reghdfe econ_conditions_me_other num_projects_ch spillover_intensity_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_2: reghdfe econ_conditions_me_other num_projects_ch spillover_intensity_proj int_spillover_proj $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab me me_1 me_2  ///
other other_1 other_2  ///
using "$output_tables/Spillover_livingcond_proj.tex", replace /// 
keep(num_projects_ch spillover_intensity_proj int_spillover_proj) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "Country X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Positive Present Living Conditions" "Positive Relative Living Conditions", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary Value Normalized  

eststo me: reghdfe econ_conditions_me mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo me_1: reghdfe econ_conditions_me mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo me_2: reghdfe econ_conditions_me mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other: reghdfe econ_conditions_me_other mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_1: reghdfe econ_conditions_me_other mon_value_ch_million spillover_intensity_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo other_2: reghdfe econ_conditions_me_other mon_value_ch_million spillover_intensity_mon int_spillover_mon $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum econ_conditions_me_other [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export all results table 
esttab me me_1 me_2  ///
other other_1 other_2  ///
using "$output_tables/Spillover_livingcond_mon.tex", replace /// 
keep(mon_value_ch_million spillover_intensity_mon int_spillover_mon) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(r2 r2_a fe_note control_dem control_c control_trend N, ///
      fmt(%9.3f %9.3f %3s %3s %3s %3s %9.0fc) ///
      labels("\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Controls \\ Respondent" "Constituency" "Country X Year" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Positive Present Living Conditions" "Positive Relative Living Conditions", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 
