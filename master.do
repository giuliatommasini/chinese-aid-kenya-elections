********************************************************************************
* MASTER DO-FILE
* Chinese development finance and electoral support in Kenya
*
* Runs the full pipeline: clean -> build -> analysis -> figures.
* How to run: open Stata, cd to the repository folder, then `do master.do`.
********************************************************************************

clear all
set more off
version 18

********************************************************************************
* 1. PATHS: edit these if needed
********************************************************************************

* Repository folder (default: the folder Stata is in when you run this file)
global root "`c(pwd)'"

* Data folder. Put the downloaded data here, following the layout in README.md,
* or point this to wherever your copy of the data lives.
global data "$root/data"

* Where tables and figures are written, and a folder for scratch files
global output "$root/output"
global temp   "$root/output/temp"

* Python used for the spillover and PDF-extraction steps.
* If Stata cannot find it, use the full path (run `which python3` in a terminal).
global python "python3"

global code "$root/code"

********************************************************************************
* 2. WHICH PARTS TO RUN (1 = run, 0 = skip)
********************************************************************************

global run_extract  0   // re-extract election results from the PDFs (needs pdfplumber)
global run_clean    1
global run_build    1
global run_analysis 1
global run_figures  1

********************************************************************************
* 3. PACKAGES: installed once from SSC if missing
********************************************************************************

foreach pkg in reghdfe ftools estout spmap shp2dta geoinpoly {
    capture which `pkg'
    if _rc ssc install `pkg', replace
}

********************************************************************************
* 4. FOLDERS: create output and intermediate folders if missing
********************************************************************************

foreach dir in "$output" "$output/tables" "$output/figures" "$temp" ///
    "$data/Aid/01_Intermediary Data" "$data/Aid/01_Cleaned Data" ///
    "$data/Voting/Elections Results/02_Intermediary Data" ///
    "$data/Electoral Analysis" "$data/Survey Analysis" ///
    "$data/Afrobarometer/01_Intermediary Data" "$data/Geo/spillover" {
    capture mkdir "`dir'"
}

********************************************************************************
* 0. EXTRACT: election results from the IEBC PDFs (optional)
*    The extracted results were then cleaned and saved as
*    data/Voting/Elections Results/01_Cleaned Data/Results_National_Assembly_*.csv,
*    which are included in the repository. Skip this step to use them directly.
********************************************************************************

if $run_extract {
    shell "$python" "$code/00_extract/extract_2013.py" "$data" "$temp"
    shell "$python" "$code/00_extract/extract_2017.py" "$data" "$temp"
}

********************************************************************************
* 1. CLEAN
********************************************************************************

if $run_clean {
    do "$code/01_clean/01_clean_aid.do"
    do "$code/01_clean/02_clean_elections.do"
    do "$code/01_clean/03_clean_geo.do"
    do "$code/01_clean/04_clean_aid_constituencies.do"
    do "$code/01_clean/05_clean_afrobarometer_r2.do"
    do "$code/01_clean/06_clean_afrobarometer_r3.do"
    do "$code/01_clean/07_clean_afrobarometer_r4.do"
    do "$code/01_clean/08_clean_afrobarometer_r5.do"
    do "$code/01_clean/09_clean_afrobarometer_r6.do"
    cd "$root"
}

********************************************************************************
* 2. BUILD
********************************************************************************

if $run_build {
    * Electoral panel (constituency x election)
    do "$code/02_build/01_build_electoral_outcomes.do"
    do "$code/02_build/02_build_aid_electoral.do"
    do "$code/02_build/03_merge_electoral.do"
    shell "$python" "$code/02_build/04_electoral_spillovers.py" "$data"
    do "$code/02_build/05_merge_electoral_spillovers_controls.do"

    * Survey panel (respondent x Afrobarometer round)
    do "$code/02_build/06_build_survey_panel.do"
    do "$code/02_build/07_build_constituency_ids.do"
    do "$code/02_build/08_build_aid_survey.do"
    shell "$python" "$code/02_build/09_survey_spillovers.py" "$data"
    do "$code/02_build/10_merge_survey.do"
    cd "$root"
}

********************************************************************************
* 3. ANALYSIS
********************************************************************************

if $run_analysis {
    * Electoral analysis
    do "$code/03_analysis/01_electoral_main.do"
    do "$code/03_analysis/02_electoral_pretrends_permutation.do"
    do "$code/03_analysis/03_electoral_spillovers.do"

    * Survey analysis
    do "$code/03_analysis/04_survey_coefplots.do"
    * 05 runs after 04 on purpose: both write the Donor_*.tex tables, and the
    * versions used in the thesis are the ones from 05
    do "$code/03_analysis/05_survey_main_tables.do"
    do "$code/03_analysis/06_survey_pretrends.do"
    do "$code/03_analysis/07_survey_restricted_sample.do"
    do "$code/03_analysis/08_survey_placebo_wb.do"
    do "$code/03_analysis/09_survey_spillovers.do"
    cd "$root"
}

********************************************************************************
* 4. FIGURES
********************************************************************************

if $run_figures {
    do "$code/04_figures/01_descriptives.do"
    cd "$root"
}

display as result "Done. Tables and figures are in $output"
