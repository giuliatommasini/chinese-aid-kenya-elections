********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Spillover Effect Survey 

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global electoral_data "$data/Electoral Analysis"
global output_tables "$output/tables"

clear all 

********************************************************************************

use "$electoral_data/electoral_analysis_heter_donor.dta", clear 

********************************************************************************

* Local constituencies controls 
local controls_const interaction_mv interaction_lum interaction_road interaction_den interaction_timetocity interaction_slope 

* Generate interaction variable 
gen int_spillover_proj_het_pre = interaction_proj_ch_pre * interaction_spillover_proj_pre
gen int_spillover_mon_het_pre = interaction_mon_ch_pre * interaction_spillover_mon_pre

gen int_spillover_proj_het = interaction_proj_ch * interaction_spillover_proj
gen int_spillover_mon_het = interaction_mon_ch * interaction_spillover_mon

label var int_spillover_proj_het "Spillover Intensity $\times$ Projects $\times$ Post"
label var int_spillover_mon_het "Spillover Intensity $\times$ Investment $\times$ Post"

gen int_ln_spillover_proj_het_pre = interaction_ln_proj_ch_pre * interaction_ln_spill_proj_pre
gen int_ln_spillover_mon_het_pre = interaction_ln_mon_ch_pre * interaction_ln_spill_mon_pre

gen int_ln_spillover_proj_het = interaction_ln_proj_ch * interaction_ln_spillover_proj
gen int_ln_spillover_mon_het = interaction_ln_mon_ch * interaction_ln_spillover_mon

label var int_ln_spillover_proj_het "log(Spillover Intensity) $\times$ log(Projects) $\times$ Post"
label var int_ln_spillover_mon_het "log(Spillover Intensity) $\times$ log(Investment) $\times$ Post"


*******************************************************************************
*** 		Vote Share of Incumbent Continuous Treatment Full Sample	 	***
*******************************************************************************

** Number of projects 

eststo national: reghdfe Incumbent_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo national_1: reghdfe Incumbent_vote_share interaction_proj_ch_pre interaction_spillover_proj_pre Post interaction_proj_ch interaction_spillover_proj interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo national_2: reghdfe Incumbent_vote_share interaction_proj_ch_pre interaction_spillover_proj_pre int_spillover_proj_het_pre Post interaction_proj_ch interaction_spillover_proj int_spillover_proj_het interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local: reghdfe winning_coalition_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_1: reghdfe winning_coalition_vote_share interaction_proj_ch_pre interaction_spillover_proj_pre Post interaction_proj_ch interaction_spillover_proj interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_2: reghdfe winning_coalition_vote_share interaction_proj_ch_pre interaction_spillover_proj_pre int_spillover_proj_het_pre Post interaction_proj_ch interaction_spillover_proj int_spillover_proj_het interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national national_1 national_2 ///
local local_1 local_2  ///
using "$output_tables/Spillover_proj_winning_coal.tex", replace /// 
keep(interaction_proj_ch interaction_spillover_proj int_spillover_proj_het) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control trends N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Baseline Controls $\times$ Post" "County $\times$ Post" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 


** Monetary Value 

eststo national: reghdfe Incumbent_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo national_1: reghdfe Incumbent_vote_share interaction_mon_ch_pre interaction_spillover_mon_pre Post interaction_mon_ch interaction_spillover_mon interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo national_2: reghdfe Incumbent_vote_share interaction_mon_ch_pre interaction_spillover_mon_pre int_spillover_mon_het_pre Post interaction_mon_ch interaction_spillover_mon int_spillover_mon_het interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local: reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_1: reghdfe winning_coalition_vote_share interaction_mon_ch_pre interaction_spillover_mon_pre Post interaction_mon_ch interaction_spillover_mon interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_2: reghdfe winning_coalition_vote_share interaction_mon_ch_pre interaction_spillover_mon_pre int_spillover_mon_het_pre Post interaction_mon_ch interaction_spillover_mon int_spillover_mon_het interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national national_1 national_2 ///
local local_1 local_2 ///
using "$output_tables/Spillover_mon_winning_coal.tex", replace /// 
keep(interaction_mon_ch interaction_spillover_mon int_spillover_mon_het) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control trends N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Baseline Controls $\times$ Post" "County $\times$ Post" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Log Number of projects 

eststo national: reghdfe Incumbent_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo national_1: reghdfe Incumbent_vote_share interaction_ln_proj_ch_pre interaction_ln_spill_proj_pre Post interaction_ln_proj_ch interaction_ln_spillover_proj interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo national_2: reghdfe Incumbent_vote_share interaction_ln_proj_ch_pre interaction_ln_spill_proj_pre int_ln_spillover_proj_het_pre Post interaction_ln_proj_ch interaction_ln_spillover_proj int_ln_spillover_proj_het interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local: reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_1: reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre interaction_ln_spill_proj_pre Post interaction_ln_proj_ch interaction_ln_spillover_proj interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_2: reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre interaction_ln_spill_proj_pre int_ln_spillover_proj_het_pre Post interaction_ln_proj_ch interaction_ln_spillover_proj int_ln_spillover_proj_het interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national national_1 national_2 ///
local local_1 local_2  ///
using "$output_tables/Spillover_ln_proj_winning_coal.tex", replace /// 
keep(interaction_ln_proj_ch interaction_ln_spillover_proj int_ln_spillover_proj_het) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control trends N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Baseline Controls $\times$ Post" "County $\times$ Post" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 


** Monetary Value 

eststo national: reghdfe Incumbent_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo national_1: reghdfe Incumbent_vote_share interaction_ln_mon_ch_pre interaction_ln_spill_mon_pre Post interaction_ln_mon_ch interaction_ln_spillover_mon interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo national_2: reghdfe Incumbent_vote_share interaction_ln_mon_ch_pre interaction_ln_spill_mon_pre int_ln_spillover_mon_het_pre Post interaction_ln_mon_ch interaction_ln_spillover_mon int_ln_spillover_mon_het interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local: reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_1: reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre interaction_ln_spill_mon_pre Post interaction_ln_mon_ch interaction_ln_spillover_mon interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_2: reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre interaction_ln_spill_mon_pre Post interaction_ln_mon_ch interaction_ln_spillover_mon int_ln_spillover_mon_het interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national national_1 national_2 ///
local local_1 local_2 ///
using "$output_tables/Spillover_ln_mon_winning_coal.tex", replace /// 
keep(interaction_ln_mon_ch interaction_ln_spillover_mon int_ln_spillover_mon_het) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control trends N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Baseline Controls $\times$ Post" "County $\times$ Post" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 

