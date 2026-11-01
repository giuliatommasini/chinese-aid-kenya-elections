********************************************************************************

* Author: Giulia 
* Date Created: April 2025 
* Purpose: Exogeneity tests Electoral Analysis

********************************************************************************

clear all
set more off
capture log close

* Folder paths ($data, $output, $temp) are set in master.do

global electoral_data "$data/Electoral Analysis"
global output_tables "$output/tables"
global output_figures "$output/figures"

********************************************************************************

use "$electoral_data/electoral_analysis_heter_donor.dta", clear 

********************************************************************************

/** Testing whether aid received between 2013-2017 has an effect on the vote share of the incumbent in 2013 **/ 

* Local constituencies controls 
local controls_const interaction_mv interaction_lum interaction_road interaction_den interaction_timetocity interaction_slope 

local controls_const_base margin_victory_pre interaction_lum interaction_road interaction_den interaction_timetocity interaction_slope


***************************************************************
*** 			Exogeneity Political Targeting  	 		***
***************************************************************

gen interaction_birthplace = presence_leader_birthplace2012 * Post
label var interaction_birthplace "Political Leader's Birthplace $\times$ Post"

* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe num_projects_china interaction_birthplace num_projects_wb `controls_const', absorb(constituencyname) cluster(constituencyname)
sum num_projects_china if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe mon_value_ch_million interaction_birthplace mon_value_wb_million `controls_const', absorb(constituencyname) cluster(constituencyname)
sum mon_value_ch_million if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo dum_vs_FE_c: reghdfe ever_china_aid interaction_birthplace ever_wb_aid `controls_const', absorb(county_id) cluster(constituencyname)
sum ever_china_aid if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county x post fe 
eststo national_vs_FE_c2: reghdfe num_projects_china interaction_birthplace num_projects_wb `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum num_projects_china if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe mon_value_ch_million interaction_birthplace mon_value_wb_million `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum mon_value_ch_million if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo dum_vs_FE_c2: reghdfe ever_china_aid interaction_birthplace ever_wb_aid `controls_const' interaction_county, absorb(county_id) cluster(constituencyname)
sum ever_china_aid if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab national_vs_FE_c national_vs_FE_c2 ///
local_vs_FE_c local_vs_FE_c2 ///
dum_vs_FE_c dum_vs_FE_c2 ///
using "$output_tables/birthplace_test_el.tex", replace /// 
keep(interaction_birthplace) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control trends N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Baseline Controls $\times$ Post" "County $\times$ Post" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("Number of Projects" "Monetary Value" "Received Funds", ///
lhs("") pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


preserve

* Drop projects above the 99th percentile
summ mon_value_ch, detail
local p99 = r(p99)
drop if mon_value_ch > `p99'

* With controls & constituency fixed effects
eststo national_vs_FE_c: reghdfe num_projects_china interaction_birthplace num_projects_wb `controls_const', absorb(constituencyname) cluster(constituencyname)
sum num_projects_china if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo local_vs_FE_c: reghdfe mon_value_ch_million interaction_birthplace mon_value_wb_million `controls_const', absorb(constituencyname) cluster(constituencyname)
sum mon_value_ch_million if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 

eststo dum_vs_FE_c: reghdfe ever_china_aid interaction_birthplace ever_wb_aid `controls_const', absorb(county_id) cluster(constituencyname)
sum ever_china_aid if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "No", replace 


* With controls & constituency fixed effects + county x post fe 
eststo national_vs_FE_c2: reghdfe num_projects_china interaction_birthplace num_projects_wb `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum num_projects_china if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo local_vs_FE_c2: reghdfe mon_value_ch_million interaction_birthplace mon_value_wb_million `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)
sum mon_value_ch_million if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 

eststo dum_vs_FE_c2: reghdfe ever_china_aid interaction_birthplace ever_wb_aid `controls_const' interaction_county, absorb(county_id) cluster(constituencyname)
sum ever_china_aid if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)     
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 
estadd local trends "Yes", replace 


* Export all results table 
esttab local_vs_FE_c local_vs_FE_c2 ///
using "$output_tables/birthplace_test_el_app.tex", replace /// 
keep(interaction_birthplace) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar r2 r2_a control trends N, ///
      fmt(%9.3f %9.3f %9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace R$^{2}$" "Adj. R$^{2}$" "\addlinespace \hline \addlinespace Baseline Controls $\times$ Post" "County $\times$ Post" "\addlinespace Obs.")) ///
mlabels(" " " ", lhs("")) ///
mgroups("Monetary Value", ///
lhs("") pattern(1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 

restore 


*******************************************************
*** 			Anticipation Effects 	 			***
*******************************************************

preserve

* Keep only pre period outcomes 
keep if Post==0


** Number of projects 

* Baseline
eststo national_vs: reghdfe Incumbent_vote_share num_proj_ch_pre num_proj_ch_post, absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "No", replace 

eststo local_vs: reghdfe winning_coalition_vote_share num_proj_ch_pre num_proj_ch_post, absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "No", replace 


* With controls 
eststo national_vs_c: reghdfe Incumbent_vote_share num_proj_ch_pre num_proj_ch_post num_proj_wb_pre num_proj_wb_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 

eststo local_vs_c: reghdfe winning_coalition_vote_share num_proj_ch_pre num_proj_ch_post num_proj_wb_pre num_proj_wb_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 


* Export all results table 
esttab national_vs national_vs_c ///
local_vs local_vs_c ///
using "$output_tables/placebo_proj.tex", replace /// 
keep(num_proj_ch_post) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar fe_note control N, ///
      fmt(%9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace \hline \addlinespace County FE" "Baseline Controls" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Number of projects logarithmic transformation 

* Baseline
eststo national_vs: reghdfe Incumbent_vote_share ln_num_proj_ch_pre ln_num_proj_ch_post, absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "No", replace 

eststo local_vs: reghdfe winning_coalition_vote_share ln_num_proj_ch_pre ln_num_proj_ch_post, absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "No", replace 


* With controls 
eststo national_vs_c: reghdfe Incumbent_vote_share ln_num_proj_ch_pre ln_num_proj_ch_post ln_num_proj_wb_pre ln_num_proj_wb_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 

eststo local_vs_c: reghdfe winning_coalition_vote_share ln_num_proj_ch_pre ln_num_proj_ch_post ln_num_proj_wb_pre ln_num_proj_wb_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 


* Export all results table 
esttab national_vs national_vs_c ///
local_vs local_vs_c ///
using "$output_tables/placebo_ln_proj.tex", replace /// 
keep(ln_num_proj_ch_post) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar fe_note control N, ///
      fmt(%9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace \hline \addlinespace County FE" "Baseline Controls" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear 


** Monetary value normalized 

* Baseline
eststo national_vs: reghdfe Incumbent_vote_share mon_value_ch_million_pre mon_value_ch_million_post, absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "No", replace 

eststo local_vs: reghdfe winning_coalition_vote_share mon_value_ch_million_pre mon_value_ch_million_post, absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "No", replace 


* With controls 
eststo national_vs_c: reghdfe Incumbent_vote_share mon_value_ch_million_pre mon_value_ch_million_post mon_value_wb_million_pre mon_value_wb_million_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 

eststo local_vs_c: reghdfe winning_coalition_vote_share mon_value_ch_million_pre mon_value_ch_million_post mon_value_wb_million_pre mon_value_wb_million_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace      


* Export all results table 
esttab national_vs national_vs_c ///
local_vs local_vs_c ///
using "$output_tables/placebo_mon.tex", replace /// 
keep(mon_value_ch_million_post) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar fe_note control N, ///
      fmt(%9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace \hline \addlinespace County FE" "Baseline Controls" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear


** Monetary value logarithmic transformation 

* Baseline
eststo national_vs: reghdfe Incumbent_vote_share ln_mon_value_ch_pre ln_mon_value_ch_post, absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "No", replace 

eststo local_vs: reghdfe winning_coalition_vote_share ln_mon_value_ch_pre ln_mon_value_ch_post, absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "No", replace 


* With controls 
eststo national_vs_c: reghdfe Incumbent_vote_share ln_mon_value_ch_pre ln_mon_value_ch_post ln_mon_value_wb_pre ln_mon_value_wb_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 

eststo local_vs_c: reghdfe winning_coalition_vote_share ln_mon_value_ch_pre ln_mon_value_ch_post ln_mon_value_wb_pre ln_mon_value_wb_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace      


* Export all results table 
esttab national_vs national_vs_c ///
local_vs local_vs_c ///
using "$output_tables/placebo_ln_mon.tex", replace /// 
keep(ln_mon_value_ch_post) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar fe_note control N, ///
      fmt(%9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace \hline \addlinespace County FE" "Baseline Controls" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear


** Binary treatment  

* Baseline
eststo national_vs: reghdfe Incumbent_vote_share treat_ch_pre treat_ch_post, absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "No", replace 

eststo local_vs: reghdfe winning_coalition_vote_share treat_ch_pre treat_ch_post, absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "No", replace 


* With controls 
eststo national_vs_c: reghdfe Incumbent_vote_share treat_ch_pre treat_ch_post treat_wb_pre treat_wb_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum margin_victory if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)  
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace 

eststo local_vs_c: reghdfe winning_coalition_vote_share treat_ch_pre treat_ch_post treat_wb_pre  treat_wb_post `controls_const_base', absorb(county_id) cluster(constituencyname)
sum winning_coalition_vote_share if e(sample)       
estadd scalar mean_depvar = r(mean) 
estadd scalar sd_depvar = r(sd)   
estadd local fe_note "Yes", replace 
estadd local control "Yes", replace      


* Export all results table 
esttab national_vs national_vs_c ///
local_vs local_vs_c ///
using "$output_tables/placebo_binary.tex", replace /// 
keep(treat_ch_pre treat_ch_post) ///
star(* 0.10 ** 0.05 *** 0.01) ///       
stats(mean_depvar sd_depvar fe_note control N, ///
      fmt(%9.3f %9.3f %3s %3s %9.0fc) ///
      labels("\addlinespace Outcome Mean" "Outcome SD" "\addlinespace \hline \addlinespace Controls \\ County FE" "Baseline Controls" "\addlinespace Obs.")) ///
mlabels(" " " " " " " " " " " ", lhs("")) ///
mgroups("National Incumbent Vote Share" "Local Incumbent Vote Share", ///
lhs("") pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
compress se b(3) se(3) label ///         
collabels(none) nonotes ///               
sfmt(%9.3fc %9.3fc %9.3fc %9.3fc %9.0fc) noobs 

eststo clear

restore


*******************************************************************
*** 		Permutation / randomization inference placebo		***
*******************************************************************

*** Create a constituency-level file of exposure: Number of Projects ***

set seed 12345
local B = 2000

* Store actual results 
reghdfe winning_coalition_vote_share interaction_proj_ch_pre Post interaction_proj_ch interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)

scalar b_actual = _b[interaction_proj_ch]
di "Actual beta on interaction_proj_ch = " %9.5f b_actual

* Build constituency level post aid file
preserve

keep constituencyname num_proj_ch_post `controls_const' `controls_const_base'
duplicates drop constituencyname, force

* Create an index of "suitability" using controls (continuous index)
reg num_proj_ch_post ``controls_const_base''
predict double suit_index, xb

* Make strata (e.g., 10 bins)
egen suit_rank = rank(suit_index), unique
xtile stratum = suit_rank, nq(10)

tempfile postaid
save `postaid', replace
restore

* Permutation loop 
tempname betas
postfile `betas' b using "$temp/perm_betas.dta", replace

* Keep a unique id to restore original order after shuffling
gen long orig_order = _n

forvalues r = 1/`B' {
	
	preserve
	
	use `postaid', clear
	
	* Random order WITHIN each stratum
    gen double u = runiform()
    sort stratum u
    by stratum: gen long rk = _n

    keep stratum rk num_proj_ch_post
    rename num_proj_ch_post postaid_perm
    tempfile donors
    save `donors', replace
	
	restore

	preserve
	
    use `postaid', clear

    * Fixed recipient order WITHIN each stratum
    sort stratum constituencyname
    by stratum: gen long rk = _n
	
	merge 1:1 stratum rk using `donors', nogen
    keep constituencyname postaid_perm
    tempfile perm_map
    save `perm_map', replace
	
	restore
	
	*---- merge permuted post aid back to full panel and build variables ----
    preserve
        merge m:1 constituencyname using `perm_map', nogen

        * china_perm: permuted aid in Post==1, actual pre aid in Post==0
        gen double china_perm = cond(Post==1, postaid_perm, num_projects_china_flow)

        * interaction with Post
        gen double china_perm_post = china_perm * Post

        quietly reghdfe winning_coalition_vote_share interaction_proj_ch_pre china_perm_post Post interaction_proj_wb interaction_proj_wb_pre `controls_const' interaction_county, ///
            absorb(constituencyname) cluster(constituencyname) 

        * IMPORTANT: china_perm may be omitted due to constituency FE (fine).
        * We store the coefficient on the interaction term:
        post `betas' (_b[china_perm_post])

        drop postaid_perm china_perm china_perm_post
    restore
}

postclose `betas'

use "$temp/perm_betas.dta", clear

* drop any missing (check)
drop if missing(b)

* One-sided permutation p-value (correct sign-aware version)
gen extreme_one = (sign(b_actual) * b >= sign(b_actual) * b_actual)
summ extreme_one, meanonly
di "Permutation p-value (one-sided) = " %6.4f r(mean)

* Two-sided permutation p-value
gen extreme_two = (abs(b) >= abs(b_actual))
summ extreme_two, meanonly
scalar p_perm_two = r(mean)
di "Permutation p-value (two-sided) = " %6.4f r(mean)

local bfmt : display %6.3f b_actual

** Visualization 
twoway ///
    (kdensity b, lcolor(navy) lwidth(medthick)) ///
	, xline(`=b_actual', lcolor(red) lpattern(dash) lwidth(medthick)) ///
      title("{bf:Permutation Distribution of Projects × Post Coefficient}", color(black) size(medium) margin(b=5)) ///
      xtitle("Exposure × Post") ///
	  note("Vertical dashed line denotes baseline estimate (beta = `bfmt').", size(small)) ///
      ytitle("Density") ///
      legend(off) ///
      scheme(s2color) ///
      graphregion(color(white)) ///
      plotregion(color(white))

graph export "$output_figures/permutation_proj.pdf", replace 

/* Old code: 
	preserve
        use `postaid', clear

        * Random order to create donors
        gen double u = runiform()
        sort u
        gen long rk = _n
		
		* Save permuted values in a temp file keyed by rank
        keep rk num_proj_ch_post
        rename num_proj_ch_post postaid_perm
        tempfile donors
        save `donors', replace
    restore
	
	preserve
        use `postaid', clear

        * Fixed (original) order gives recipients
        sort constituencyname
        gen long rk = _n

        merge 1:1 rk using `donors', nogen
        keep constituencyname postaid_perm
        tempfile perm_map
        save `perm_map', replace
    restore  */


*** Create a constituency-level file of exposure: Log Number of Projects ***

clear all 

use "$electoral_data/electoral_analysis_heter_donor.dta", clear 

set seed 12345
local B = 2000

* Store actual results 
reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre Post interaction_ln_proj_ch interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)

scalar b_actual = _b[interaction_ln_proj_ch]
di "Actual beta on interaction_proj_ch = " %9.5f b_actual

* Build constituency level post aid file
preserve

keep constituencyname ln_num_proj_ch_post num_proj_ch_post `controls_const' `controls_const_base' 
duplicates drop constituencyname, force

* Create an index of "suitability" using controls (continuous index)
reg ln_num_proj_ch_post `controls_const_base'
predict double suit_index, xb

* Make strata (e.g., 10 bins)
egen suit_rank = rank(suit_index), unique
xtile stratum = suit_rank, nq(10)

tempfile postaid
save `postaid', replace
restore

* Permutation loop 
tempname ln_betas
postfile `ln_betas' b using "$temp/perm_ln_betas.dta", replace

* Keep a unique id to restore original order after shuffling
gen long orig_order = _n

forvalues r = 1/`B' {
	
	preserve
	
	use `postaid', clear
	
	* Random order WITHIN each stratum
    gen double u = runiform()
    sort stratum u
    by stratum: gen long rk = _n

    keep stratum rk num_proj_ch_post
    rename num_proj_ch_post postaid_perm
    tempfile donors
    save `donors', replace
	
	restore

	preserve
	
    use `postaid', clear

    * Fixed recipient order WITHIN each stratum
    sort stratum constituencyname
    by stratum: gen long rk = _n
	
	merge 1:1 stratum rk using `donors', nogen
    keep constituencyname postaid_perm
    tempfile perm_map
    save `perm_map', replace
	
	restore
	
	*---- merge permuted post aid back to full panel and build variables ----
    preserve
        merge m:1 constituencyname using `perm_map', nogen

        * china_perm: permuted aid in Post==1, actual pre aid in Post==0
        gen double china_perm = cond(Post==1, postaid_perm, num_projects_china_flow)
		gen ln_china_perm = ln(china_perm+1)

        * interaction with Post
        gen double ln_china_perm_post = ln_china_perm * Post

        quietly reghdfe winning_coalition_vote_share interaction_ln_proj_ch_pre ln_china_perm_post Post interaction_ln_proj_wb interaction_ln_proj_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)

        * IMPORTANT: china_perm may be omitted due to constituency FE (fine).
        * We store the coefficient on the interaction term:
        post `ln_betas' (_b[ln_china_perm_post])

        drop postaid_perm china_perm ln_china_perm ln_china_perm_post
    restore
}

postclose `ln_betas'


use "$temp/perm_ln_betas.dta", clear

* drop any missing (check)
drop if missing(b)

* One-sided permutation p-value (correct sign-aware version)
gen extreme_one = (sign(b_actual) * b >= sign(b_actual) * b_actual)
summ extreme_one, meanonly
di "Permutation p-value (one-sided) = " %6.4f r(mean)

* Two-sided permutation p-value
gen extreme_two = (abs(b) >= abs(b_actual))
summ extreme_two, meanonly
di "Permutation p-value (two-sided) = " %6.4f r(mean)

local bfmt : display %6.3f b_actual

** Visualization 
twoway ///
    (kdensity b, lcolor(navy) lwidth(medthick)) ///
	, xline(`=b_actual', lcolor(red) lpattern(dash) lwidth(medthick)) ///
      title("{bf:Permutation Distribution of log(Projects) × Post Coefficient}", color(black) size(medium) margin(b=5)) ///
      xtitle("Exposure × Post") ///
	  note("Vertical dashed line denotes baseline estimate (beta = `bfmt').", size(small)) ///
      ytitle("Density") ///
      legend(off) ///
      scheme(s2color) ///
      graphregion(color(white)) ///
      plotregion(color(white))

graph export "$output_figures/permutation_ln_proj.pdf", replace 



*** Create a constituency-level file of exposure: Monetary Value ***

clear all 

use "$electoral_data/electoral_analysis_heter_donor.dta", clear 

set seed 12345
local B = 2000

* Store actual results 
reghdfe winning_coalition_vote_share interaction_mon_ch_pre Post interaction_mon_ch interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)

scalar b_actual = _b[interaction_mon_ch]
di "Actual beta on interaction_mon_ch = " %9.5f b_actual

* Build constituency level post aid file
preserve

keep constituencyname mon_value_ch_million_post `controls_const' `controls_const_base'
duplicates drop constituencyname, force

* Create an index of "suitability" using controls (continuous index)
reg mon_value_ch_million_post `controls_const_base'
predict double suit_index, xb

* Make strata (e.g., 10 bins)
egen suit_rank = rank(suit_index), unique
xtile stratum = suit_rank, nq(10)

tempfile postaid_mon
save `postaid_mon', replace
restore

* Permutation loop 
tempname betas_mon
postfile `betas_mon' b using "$temp/perm_betas_mon.dta", replace

* Keep a unique id to restore original order after shuffling
gen long orig_order = _n

forvalues r = 1/`B' {
	
	preserve
	
	use `postaid_mon', clear
	
	* Random order WITHIN each stratum
    gen double u = runiform()
    sort stratum u
    by stratum: gen long rk = _n

    keep stratum rk mon_value_ch_million_post
    rename mon_value_ch_million_post postaid_perm
    tempfile donors
    save `donors', replace
	
	restore

	preserve
	
    use `postaid_mon', clear

    * Fixed recipient order WITHIN each stratum
    sort stratum constituencyname
    by stratum: gen long rk = _n
	
	merge 1:1 stratum rk using `donors', nogen
    keep constituencyname postaid_perm
    tempfile perm_map_mon
    save `perm_map_mon', replace
	
	restore
	
	*---- merge permuted post aid back to full panel and build variables ----
    preserve
        merge m:1 constituencyname using `perm_map_mon', nogen

        * china_perm: permuted aid in Post==1, actual pre aid in Post==0
        gen double china_perm = cond(Post==1, postaid_perm, mon_value_ch_flow)

        * interaction with Post
        gen double china_perm_post = china_perm * Post

        quietly reghdfe winning_coalition_vote_share interaction_mon_ch_pre china_perm_post Post interaction_mon_wb interaction_mon_wb_pre `controls_const' interaction_county, ///
            absorb(constituencyname) cluster(constituencyname)

        * IMPORTANT: china_perm may be omitted due to constituency FE (fine).
        * We store the coefficient on the interaction term:
        post `betas_mon' (_b[china_perm_post])

        drop postaid_perm china_perm china_perm_post
    restore
}

postclose `betas_mon' 


use "$temp/perm_betas_mon.dta", clear

* drop any missing (check)
drop if missing(b)

* One-sided permutation p-value (correct sign-aware version)
gen extreme_one = (sign(b_actual) * b >= sign(b_actual) * b_actual)
summ extreme_one, meanonly
di "Permutation p-value (one-sided) = " %6.4f r(mean)

* Two-sided permutation p-value
gen extreme_two = (abs(b) >= abs(b_actual))
summ extreme_two, meanonly
di "Permutation p-value (two-sided) = " %6.4f r(mean)

local bfmt : display %6.3f b_actual

** Visualization 
twoway ///
    (kdensity b, lcolor(navy) lwidth(medthick)) ///
	, xline(`=b_actual', lcolor(red) lpattern(dash) lwidth(medthick)) ///
      title("{bf:Permutation Distribution of Investment × Post Coefficient}", color(black) size(medium) margin(b=5)) ///
      xtitle("Exposure × Post") ///
	  note("Vertical dashed line denotes baseline estimate (beta = `bfmt').", size(small)) ///
      ytitle("Density") ///
      legend(off) ///
      scheme(s2color) ///
      graphregion(color(white)) ///
      plotregion(color(white))
	  
graph export "$output_figures/permutation_mon.pdf", replace 


*** Create a constituency-level file of exposure: Log Monetary Value ***

clear all 

use "$electoral_data/electoral_analysis_heter_donor.dta", clear 

set seed 12345
local B = 2000

* Store actual results 
reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre Post interaction_ln_mon_ch interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)

scalar b_actual = _b[interaction_ln_mon_ch]
di "Actual beta on interaction_ln_mon_ch = " %9.5f b_actual

* Build constituency level post aid file
preserve

keep constituencyname mon_value_ch_million_post ln_mon_value_ch_post `controls_const' `controls_const_base'
duplicates drop constituencyname, force

* Create an index of "suitability" using controls (continuous index)
reg ln_mon_value_ch_post `controls_const_base'
predict double suit_index, xb

* Make strata (e.g., 10 bins)
egen suit_rank = rank(suit_index), unique
xtile stratum = suit_rank, nq(10)

tempfile postaid_mon
save `postaid_mon', replace
restore

* Permutation loop 
tempname betas_mon
postfile `betas_mon' b using "$temp/perm_betas_mon.dta", replace

* Keep a unique id to restore original order after shuffling
gen long orig_order = _n

forvalues r = 1/`B' {
	
	preserve
	
	use `postaid_mon', clear
	
	* Random order WITHIN each stratum
    gen double u = runiform()
    sort stratum u
    by stratum: gen long rk = _n

    keep stratum rk mon_value_ch_million_post
    rename mon_value_ch_million_post postaid_perm
    tempfile donors
    save `donors', replace
	
	restore

	preserve
	
    use `postaid_mon', clear

    * Fixed recipient order WITHIN each stratum
    sort stratum constituencyname
    by stratum: gen long rk = _n
	
	merge 1:1 stratum rk using `donors', nogen
    keep constituencyname postaid_perm
    tempfile perm_map_mon
    save `perm_map_mon', replace
	
	restore
	
	*---- merge permuted post aid back to full panel and build variables ----
    preserve
        merge m:1 constituencyname using `perm_map_mon', nogen

        * china_perm: permuted aid in Post==1, actual pre aid in Post==0
        gen double china_perm = cond(Post==1, postaid_perm, ln_mon_value_ch_flow)
		gen ln_china_perm = ln(china_perm+1)

        * interaction with Post
        gen double china_perm_post = china_perm * Post
		gen ln_china_perm_post = ln_china_perm * Post 

        quietly reghdfe winning_coalition_vote_share interaction_ln_mon_ch_pre ln_china_perm_post Post interaction_ln_mon_wb interaction_ln_mon_wb_pre `controls_const' interaction_county, ///
            absorb(constituencyname) cluster(constituencyname)

        * IMPORTANT: china_perm may be omitted due to constituency FE (fine).
        * We store the coefficient on the interaction term:
        post `betas_mon' (_b[ln_china_perm_post])

        drop postaid_perm china_perm ln_china_perm china_perm_post ln_china_perm_post
    restore
}

postclose `betas_mon' 


use "$temp/perm_betas_mon.dta", clear

* drop any missing (check)
drop if missing(b)

* One-sided permutation p-value (correct sign-aware version)
gen extreme_one = (sign(b_actual) * b >= sign(b_actual) * b_actual)
summ extreme_one, meanonly
di "Permutation p-value (one-sided) = " %6.4f r(mean)

* Two-sided permutation p-value
gen extreme_two = (abs(b) >= abs(b_actual))
summ extreme_two, meanonly
di "Permutation p-value (two-sided) = " %6.4f r(mean)

local bfmt : display %6.3f b_actual

** Visualization 
twoway ///
    (kdensity b, lcolor(navy) lwidth(medthick)) ///
	, xline(`=b_actual', lcolor(red) lpattern(dash) lwidth(medthick)) ///
      title("{bf:Permutation Distribution of log(Investment) × Post Coefficient}", color(black) size(medium) margin(b=5)) ///
      xtitle("Exposure × Post") ///
	  note("Vertical dashed line denotes baseline estimate (beta = `bfmt').", size(small)) ///
      ytitle("Density") ///
      legend(off) ///
      scheme(s2color) ///
      graphregion(color(white)) ///
      plotregion(color(white))

graph export "$output_figures/permutation_ln_mon.pdf", replace 


* ---- End of the code used for the thesis. The code below was exploratory
* ---- and is not run (exit returns control to master.do).
exit
*** Create a constituency-level file of exposure: Binary Exposure ***

clear all 

use "$electoral_data/electoral_analysis_heter_donor.dta", clear 

set seed 12345
local B = 2000

* Store actual results 
reghdfe winning_coalition_vote_share interaction_treat_ch_pre Post interaction_treat_ch interaction_treat_wb_pre interaction_treat_wb `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)

scalar b_actual = _b[interaction_treat_ch]
di "Actual beta on interaction_treat_ch = " %9.5f b_actual

* Build constituency level post aid file
preserve

keep constituencyname treat_ch_post `controls_const' `controls_const_base'
duplicates drop constituencyname, force

* Create an index of "suitability" using controls (continuous index)
reg treat_ch_post `controls_const_base'
predict double suit_index, xb

* Make strata (e.g., 10 bins)
egen suit_rank = rank(suit_index), unique
xtile stratum = suit_rank, nq(10)

tempfile postaid_binary
save `postaid_binary', replace
restore

* Permutation loop 
tempname betas_binary
postfile `betas_binary' b using "$temp/perm_betas_binary.dta", replace

* Keep a unique id to restore original order after shuffling
gen long orig_order = _n

forvalues r = 1/`B' {
	
	preserve
	
	use `postaid_binary', clear
	
	* Random order WITHIN each stratum
    gen double u = runiform()
    sort stratum u
    by stratum: gen long rk = _n

    keep stratum rk treat_ch_post
    rename treat_ch_post postaid_perm
    tempfile donors
    save `donors', replace
	
	restore

	preserve
	
    use `postaid_binary', clear

    * Fixed recipient order WITHIN each stratum
    sort stratum constituencyname
    by stratum: gen long rk = _n
	
	merge 1:1 stratum rk using `donors', nogen
    keep constituencyname postaid_perm
    tempfile perm_map_binary
    save `perm_map_binary', replace
	
	restore
	
	*---- merge permuted post aid back to full panel and build variables ----
    preserve
        merge m:1 constituencyname using `perm_map_binary', nogen

        * china_perm: permuted aid in Post==1, actual pre aid in Post==0
        gen double china_perm = cond(Post==1, postaid_perm, treat_ch_flow)

        * interaction with Post
        gen double china_perm_post = china_perm * Post

        quietly reghdfe  winning_coalition_vote_share interaction_treat_ch_pre Post china_perm_post interaction_treat_wb_pre interaction_treat_wb `controls_const' interaction_county, absorb(constituencyname) cluster(constituencyname)

        * IMPORTANT: china_perm may be omitted due to constituency FE (fine).
        * We store the coefficient on the interaction term:
        post `betas_binary' (_b[china_perm_post])

        drop postaid_perm china_perm china_perm_post
    restore
}

postclose `betas_binary' 


use "$temp/perm_betas_binary.dta", clear

* drop any missing (check)
drop if missing(b)

* one-sided (>= actual)
gen extreme_ge = (b >= b_actual)
summ extreme_ge, meanonly
di "Permutation p-value (one-sided, >= actual) = " %6.4f r(mean) /// 0.0060

* two-sided (|b| >= |actual|)
gen extreme_abs = (abs(b) >= abs(b_actual))
summ extreme_abs, meanonly
di "Permutation p-value (two-sided) = " %6.4f r(mean) /// 0.0115

** Visualization 
twoway ///
    (kdensity b, lcolor(navy) lwidth(medthick)) ///
    , xline(`=b_actual', lcolor(red) lwidth(medthick) lpattern(dash)) ///
      title("Permutation Density of Binary Exposure Effect", size(medium)) ///
      xtitle("Coefficient") ///
      ytitle("Density") ///
      legend(off) ///
      scheme(s2color) ///
      graphregion(color(white)) ///
      plotregion(color(white))

graph export "$output_figures/permutation_binary.png", replace 
