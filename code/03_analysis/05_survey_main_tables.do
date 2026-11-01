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


*******************************************
*** 		Presence of Services 		*** 
******************************************* 

** Number of projects 

** Panel A: Flow 

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
using "$output_tables/Donor_services_proj.tex", replace fragment ///
keep(flow_proj_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Utility Access" "Road Presence", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A: Flow}} \\")
 

** Number of projects 

** Panel B: Stock

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
using "$output_tables/Donor_services_proj.tex", append fragment ///
keep(num_projects_ch) ///
nonumbers ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 


** Monetary Value Norm 

** Panel A: Flow

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
using "$output_tables/Donor_services_mon.tex", replace fragment /// 
keep(flow_mon_ch) ///
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Utility Access" "Road Presence", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A: Flow}} \\")

eststo clear 


** Monetary Value Norm 

** Panel B: Stock

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
using "$output_tables/Donor_services_mon.tex", append fragment /// 
keep(mon_value_ch_million) ///
nonumbers ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 


*******************************************
*** 		Economic Conditions 		*** 
******************************************* 

** Number of projects 

** Panel A: Flow 

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
using "$output_tables/Donor_econcond_proj.tex", replace fragment /// 
keep(flow_proj_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Good Economic Conditions" "Improved Economy" "Expect Better Economy", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{9}{c}}\hline\hline\multicolumn{10}{c}{\textbf{Panel A: Flow}} \\")

eststo clear 


** Number of projects 

** Panel B: Stock 

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
using "$output_tables/Donor_econcond_proj.tex", append fragment /// 
keep(num_projects_ch) ///
nonumbers ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{10}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 


** Monetary value normalized 

** Panel A: Flow 

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
estadd local control_trend "Yes", replace

eststo past_FE_c2: reghdfe improved_econ_conditions_country flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_FE_c2: reghdfe exp_econ_conditions_country flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_econcond_mon.tex", replace fragment /// 
keep(flow_mon_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("Good Economic Conditions" "Improved Economy" "Expect Better Economy", ///
lhs("") pattern(1 0 0 1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{9}{c}}\hline\hline\multicolumn{10}{c}{\textbf{Panel A: Flow}} \\")

eststo clear 



** Monetary value normalized 

** Panel B: Stock 

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
estadd local control_trend "Yes", replace

eststo past_FE_c2: reghdfe improved_econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum improved_econ_conditions_country [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo fut_FE_c2: reghdfe exp_econ_conditions_country mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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
using "$output_tables/Donor_econcond_mon.tex", append fragment /// 
keep(mon_value_ch_million) ///
nonumbers ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " " " ", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{10}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 


***********************************
*** 	Performance & Trust 	*** 
***********************************

** Number of projects 

** Panel A: Flow 

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
using "$output_tables/Donor_performance_proj.tex", replace fragment /// 
keep(flow_proj_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good Performance MPs" "Trust MPs", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A: Flow}} \\")

eststo clear 


** Number of projects 

** Panel B: Stock 

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
using "$output_tables/Donor_performance_proj.tex", append fragment /// 
keep(num_projects_ch) ///
nonumbers ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 


** Monetary value normalized 

** Panel A: Flow 

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
using "$output_tables/Donor_performance_mon.tex", replace fragment /// 
keep(flow_mon_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Good Performance MPs" "Trust MPs", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{6}{c}}\hline\hline\multicolumn{7}{c}{\textbf{Panel A: Flow}} \\")

eststo clear 


** Monetary value normalized 

** Panel B: Stock 

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
using "$output_tables/Donor_performance_mon.tex", append fragment /// 
keep(mon_value_ch_million) ///
nonumbers ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{7}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 


***********************************
*** 		Satisfaction 		*** 
***********************************

** Number of Projects 

** Panel A: Flow 

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


* Export ONE table (no panels)
esttab ///
econ_r  econ_c  econ_c2 ///
jobs_r  jobs_c  jobs_c2 ///
corr_r  corr_c  corr_c2 ///
road_r  road_FE_c  road_FE_c2 ///
using "$output_tables/Donor_satisf_proj.tex", replace fragment ///
keep(flow_proj_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels("" "" "" "" "" "" "" "" "" "" "" "", lhs("")) ///
mgroups("Manage Economy" "Creating Jobs" "Fighting Corruption" "Maintaining Roads", lhs("") ///
pattern(1 0 0   1 0 0   1 0 0   1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{12}{c}}\hline\hline\multicolumn{13}{c}{\textbf{Panel A: Flow}} \\")

eststo clear 


** Number of Projects 

** Panel B: Stock 

* With respondent controls

eststo econ_FE: reghdfe manage_economy num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace     

eststo job_FE: reghdfe manage_jobs num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace   


* With respondent and constituency controls

eststo econ_FE_c: reghdfe manage_economy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace   

eststo job_FE_c: reghdfe manage_jobs num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year  

eststo econ_FE_c2: reghdfe manage_economy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)      
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace 

eststo job_FE_c2: reghdfe manage_jobs num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)       
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


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


* Export table 
esttab ///
econ_FE econ_FE_c econ_FE_c2 ///
job_FE  job_FE_c  job_FE_c2 ///
price_FE price_FE_c price_FE_c2 ///
road_FE  road_FE_c  road_FE_c2 ///
using "$output_tables/Donor_satisf_proj.tex", append fragment ///
keep(num_projects_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///
nonumbers ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels("" "" "" "" "" "" "" "" "" "" "" "", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{13}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 



** Monetary Value 

** Panel A: Flow 

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

eststo road_c: reghdfe manage_roads flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
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

eststo road_c2: reghdfe manage_roads flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_roads [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

* Export ONE table (no panels)
esttab ///
econ_r econ_c econ_c2 ///
jobs_r  jobs_c  jobs_c2 ///
corr_r corr_c corr_c2 ///
road_r  road_c  road_c2 ///
using "$output_tables/Donor_satisf_mon.tex", replace fragment ///
keep(flow_mon_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels("" "" "" "" "" "" "" "" "" "" "" "", lhs("")) ///
mgroups("Manage Economy" "Creating Jobs" "Fighting Corruption" "Maintaining Roads", lhs("") ///
pattern(1 0 0   1 0 0   1 0 0   1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{12}{c}}\hline\hline\multicolumn{13}{c}{\textbf{Panel A: Flow}} \\")

eststo clear 


** Monetary Value 

** Panel B: Stock 

* With respondent controls

eststo econ_FE: reghdfe manage_economy mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo job_FE: reghdfe manage_jobs mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo econ_FE_c: reghdfe manage_economy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo job_FE_c: reghdfe manage_jobs mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)      
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year  

eststo econ_FE_c2: reghdfe manage_economy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_economy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo job_FE_c2: reghdfe manage_jobs mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum manage_jobs [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)    
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


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


* Export table 
esttab ///
econ_FE econ_FE_c econ_FE_c2 ///
job_FE job_FE_c job_FE_c2 /// 
price_FE price_FE_c price_FE_c2 /// 
road_FE road_FE_c road_FE_c2 /// 
using "$output_tables/Donor_satisf_mon.tex", append fragment ///
keep(mon_value_ch_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///
nonumbers ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels("" "" "" "" "" "" "" "" "" "" "" "", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{13}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 


***************************************************
*** 		Demand & Supply for Democracy  		*** 
*************************************************** 

** Number of Projects 

** Panel A: Flow 

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


* With respondents controls 

eststo demand2_FE: reghdfe supply_democracy_sat flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply2_FE: reghdfe rulelaw_dem_dummy flow_proj_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls

eststo demand2_FE_c: reghdfe supply_democracy_sat flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply2_FE_c: reghdfe rulelaw_dem_dummy flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand2_FE_c2: reghdfe supply_democracy_sat flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply2_FE_c2: reghdfe rulelaw_dem_dummy flow_proj_ch $controls_dem $controls_const_by_year flow_proj_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export table 
esttab demand_FE demand_FE_c demand_FE_c2 ///
supply_FE supply_FE_c supply_FE_c2 ///
demand2_FE demand2_FE_c demand2_FE_c2 ///
supply2_FE supply2_FE_c supply2_FE_c2 ///
using "$output_tables/Donor_dem_proj.tex", replace fragment ///
keep(flow_proj_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels("" "" "" "" "" "" "" "" "" "" "" "", lhs("")) ///
mgroups("Demand for Democracy" "Perceived Extent of Democracy" "Satisfaction with Democracy" "Democracy Support", lhs("") ///
pattern(1 0 0   1 0 0   1 0 0   1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{12}{c}}\hline\hline\multicolumn{13}{c}{\textbf{Panel A: Flow}} \\")

eststo clear 


** Number of Projects 

** Panel B: Stock 

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


* With respondents controls 

eststo demand2_FE: reghdfe supply_democracy_sat num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply2_FE: reghdfe rulelaw_dem_dummy num_projects_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls

eststo demand2_FE_c: reghdfe supply_democracy_sat num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply2_FE_c: reghdfe rulelaw_dem_dummy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand2_FE_c2: reghdfe supply_democracy_sat num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum  supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply2_FE_c2: reghdfe rulelaw_dem_dummy num_projects_ch $controls_dem $controls_const_by_year num_projects_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export table 
esttab demand_FE demand_FE_c demand_FE_c2 ///
supply_FE supply_FE_c supply_FE_c2 ///
demand2_FE demand2_FE_c demand2_FE_c2 ///
supply2_FE supply2_FE_c supply2_FE_c2 ///
using "$output_tables/Donor_dem_proj.tex", append fragment ///
keep(num_projects_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///
nonumbers ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels("" "" "" "" "" "" "" "" "" "" "" "", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{13}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 



** Monetary Value 

** Panel A: Flow 

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


* With constituencies fe

eststo demand2_FE: reghdfe supply_democracy_sat flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply2_FE: reghdfe rulelaw_dem_dummy flow_mon_ch $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo demand2_FE_c: reghdfe supply_democracy_sat flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply2_FE_c: reghdfe rulelaw_dem_dummy flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand2_FE_c2: reghdfe supply_democracy_sat flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply2_FE_c2: reghdfe rulelaw_dem_dummy flow_mon_ch $controls_dem $controls_const_by_year flow_mon_wb $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export table 
esttab demand_FE demand_FE_c demand_FE_c2 ///
supply_FE supply_FE_c supply_FE_c2 ///
demand2_FE demand2_FE_c demand2_FE_c2 ///
supply2_FE supply2_FE_c supply2_FE_c2 ///
using "$output_tables/Donor_dem_mon.tex", replace fragment ///
keep(flow_mon_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean_depvar sd_depvar r2 r2_a N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Obs.")) ///
mlabels("" "" "" "" "" "" "" "" "" "" "" "", lhs("")) ///
mgroups("Demand for Democracy" "Perceived Extent of Democracy" "Satisfaction with Democracy" "Democracy Support", lhs("") ///
pattern(1 0 0   1 0 0   1 0 0   1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\begin{tabular}{l*{12}{c}}\hline\hline\multicolumn{13}{c}{\textbf{Panel A: Flow}} \\")

eststo clear 


** Monetary Value 

** Panel B: Stock 

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


* With respondents controls 

eststo demand2_FE: reghdfe supply_democracy_sat mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace

eststo supply2_FE: reghdfe rulelaw_dem_dummy mon_value_ch_million $controls_dem [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "No", replace
estadd local control_trend "No", replace


* With respondent and constituency controls 

eststo demand2_FE_c: reghdfe supply_democracy_sat mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace

eststo supply2_FE_c: reghdfe rulelaw_dem_dummy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "No", replace


* With respondent and constituency controls + county X year 

eststo demand2_FE_c2: reghdfe supply_democracy_sat mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum supply_democracy_sat [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace

eststo supply2_FE_c2: reghdfe rulelaw_dem_dummy mon_value_ch_million $controls_dem $controls_const_by_year mon_value_wb_million $controls_trend [pw=withinwt], absorb(_ID year eth_FE) vce(cluster _ID)
sum rulelaw_dem_dummy [aw=withinwt] if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control_dem "Yes", replace
estadd local control_c "Yes", replace
estadd local control_trend "Yes", replace


* Export table 
esttab demand_FE demand_FE_c demand_FE_c2 ///
supply_FE supply_FE_c supply_FE_c2 ///
demand2_FE demand2_FE_c demand2_FE_c2 ///
supply2_FE supply2_FE_c supply2_FE_c2 ///
using "$output_tables/Donor_dem_mon.tex", append fragment ///
keep(mon_value_ch_million) ///
star(* 0.10 ** 0.05 *** 0.01) ///
nonumbers ///
stats(mean_depvar sd_depvar r2 r2_a control_dem control_c control_trend N, ///
	fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
	labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Controls: \\ Respondent" "Baseline Controls $\times$ Wave FE" "County $\times$ Wave FE" "\addlinespace Obs.")) ///
mlabels("" "" "" "" "" "" "" "" "" "" "" "", lhs("")) ///
compress b(3) se(3) label ///
collabels(none) nonotes noobs ///
prehead("\hline \multicolumn{13}{c}{\textbf{Panel B: Stock}} \\") ///
postfoot("\hline\hline\end{tabular}")

eststo clear 
