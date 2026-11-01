********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Analysis Electoral: Donor

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

/** Empirical strategy: VS_r,t = Post_t + IntAidC(<2013)*Post_t + Int_AidWB(<2013) + Post_t*Int_AidC(13-17) + Post_t*Int_AidWB(13-17) with dataset of all regions receiving funds. **/

* Local constituencies controls 
local controls_const interaction_mv interaction_lum interaction_road interaction_den interaction_timetocity interaction_slope 


*******************************************************************************
*** 		Vote Share of Incumbent Continuous Treatment Full Sample	 	***
*******************************************************************************

** Number of projects

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_proj_ch_pre Post interaction_proj_ch, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_proj_ch_pre Post interaction_proj_ch, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county x post fe 
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_proj_winning_coal.tex", replace /// 
keep(interaction_proj_ch) ///
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


** Number of projects logarithmic transformation 

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county x post fe  
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_ln_proj_winning_coal.tex", replace /// 
keep(interaction_ln_proj_ch) ///
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


** Monetary value normalized 

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_mon_ch_pre Post interaction_mon_ch, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch, absorb(constituencyname) cluster(constituencyname) 
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county x post fe  
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_mon_winning_coal.tex", replace /// 
keep(interaction_mon_ch) ///
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


** Monetary value logarithmic transformation 

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch, absorb(constituencyname) cluster(constituencyname) 
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects county x post fe  
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_ln_mon_winning_coal.tex", replace /// 
keep(interaction_ln_mon_ch) ///
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


***************************************************************************
*** 	Vote Share of Incumbent Continuous Treatment Reduced Sample	 	***
***************************************************************************

preserve 

keep if ever_china_aid == 1 


** Number of projects

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_proj_ch_pre Post interaction_proj_ch, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_proj_ch_pre Post interaction_proj_ch, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county x post fe 
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_proj_winning_coal_reduced.tex", replace /// 
keep(interaction_proj_ch) ///
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


** Number of projects logarithmic transformation 

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county x post fe  
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_ln_proj_winning_coal_reduced.tex", replace /// 
keep(interaction_ln_proj_ch) ///
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


** Monetary value normalized 

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_mon_ch_pre Post interaction_mon_ch, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch, absorb(constituencyname) cluster(constituencyname) 
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county x post fe  
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_mon_winning_coal_reduced.tex", replace /// 
keep(interaction_mon_ch) ///
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


** Monetary value logarithmic transformation 

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch, absorb(constituencyname) cluster(constituencyname) 
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects county x post fe  
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_ln_mon_winning_coal_reduced.tex", replace /// 
keep(interaction_ln_mon_ch) ///
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

restore 


*******************************************************************
*** 		Vote Share of Incumbent Binary Treatment	 		***
*******************************************************************

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_treat_ch_pre Post interaction_treat_ch, absorb(constituencyname) cluster(constituencyname) 
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_treat_ch_pre Post interaction_treat_ch, absorb(constituencyname) cluster(constituencyname) 
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_treat_ch_pre Post interaction_treat_ch `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_treat_ch_pre Post interaction_treat_ch interaction_treat_wb_pre interaction_treat_wb `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county x post fe  
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_treat_ch_pre Post interaction_treat_ch `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_treat_ch_pre Post interaction_treat_ch interaction_treat_wb_pre interaction_treat_wb `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_binary.tex", replace /// 
keep(Post interaction_treat_ch) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a fe_note control trends N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Constituency FE" "Baseline Controls" "County X Post" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


***************************************************
*** 		PLACEBO CHECKS: WORLD BANK 			***
***************************************************

***********************************************************************
*** 			Local Incumbent Continuous Treatment	 			***
***********************************************************************

** Number of projects

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_proj_wb_pre Post interaction_proj_wb, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_proj_wb_pre Post interaction_proj_wb, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_proj_wb_pre Post interaction_proj_wb interaction_proj_ch_pre interaction_proj_ch `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_proj_wb_pre Post interaction_proj_wb interaction_proj_ch_pre interaction_proj_ch `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county X post 
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_proj_wb_pre Post interaction_proj_wb interaction_proj_ch_pre interaction_proj_ch `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_proj_wb_pre Post interaction_proj_wb interaction_proj_ch_pre interaction_proj_ch `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_proj_winning_coal_wb.tex", replace /// 
keep(interaction_proj_wb) ///
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


** Monetary value normalized 

* With constituency fixed effects
eststo national_vs_FE: reghdfe Incumbent_vote_share interaction_mon_wb_pre Post interaction_mon_wb, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 

eststo local_vs_FE: reghdfe winning_coalition_vote_share interaction_mon_wb_pre Post interaction_mon_wb, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "No", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe Incumbent_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const', absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county X post 
eststo national_vs_FE_c2: reghdfe Incumbent_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum Incumbent_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/Donor_DiD_mon_winning_coal_wb.tex", replace /// 
keep(interaction_mon_wb) ///
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


