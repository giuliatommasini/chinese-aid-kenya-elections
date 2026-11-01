# The Local Political Impact of Chinese Development Assistance: Evidence from Kenyan Constituencies

Replication code for my master's thesis (Giulia Tommasini).

## Research question

How does exposure to Chinese-financed development projects shape local politics in Kenya? The thesis uses constituency-level variation in the number and value of Chinese projects in two continuous difference-in-differences designs:

1. **Electoral analysis (2013 → 2017 parliamentary elections).** Does Chinese project exposure change the vote share of locally incumbent coalitions?
2. **Survey analysis (Afrobarometer rounds 2–6, 2003–2014).** Is exposure associated with perceived public services, economic evaluations, trust in institutions and attitudes toward democracy?

World Bank projects serve as a comparison donor and as a placebo. Robustness checks include pre-trend tests, permutation inference, a restricted sample and spatial spillovers to neighbouring constituencies.

## Repository structure

```
master.do                 runs the whole pipeline
code/
  00_extract/             Python: extract election results from the IEBC PDFs (optional)
  01_clean/               clean raw aid, election, shapefile and Afrobarometer data
  02_build/               build the electoral and survey panels, spillover measures, merges
  03_analysis/            regressions, tables and coefficient plots
  04_figures/             descriptive figures and maps
data/                     not included, except the extracted election results (see below)
output/                   created when you run the code (tables/, figures/, temp/)
requirements.txt          Python packages
```

## Data

The raw data is **not** included in this repository. Most sources have their own terms of use, so download each one from its provider and place it in `data/` using the paths below.

| Source | What it is used for | Where to get it | Place it in |
|---|---|---|---|
| **GODAD**, Geocoded Official Development Assistance Dataset (University of Göttingen) | Project-level Chinese and World Bank projects in Kenya, with locations and commitments | [godad.uni-goettingen.de](https://godad.uni-goettingen.de/home) (data page) | `data/Aid/00_Raw Data/GODAD/projectlevel_china_wb.csv` |
| **Afrobarometer, geocoded** (Kenya, rounds 2–6) | Survey outcomes; respondent coordinates are used to assign respondents to constituencies | Respondent-level coordinates are restricted; request access from [Afrobarometer](https://www.afrobarometer.org/geocoded-data/) (geocoding by [AidData](https://aiddata.org/data/geocoded-afrobarometer-data-v1)) | `data/Afrobarometer/00_Raw Data/KEN_r2.xlsx` … `KEN_r6.xlsx` (sheet `Sheet1`, with `latitude` and `longitude`) |
| **IEBC election results**, 2013 and 2017 (Independent Electoral and Boundaries Commission of Kenya) | National Assembly results by constituency and candidate | Public PDFs from [iebc.or.ke](https://www.iebc.or.ke/). The files used are `EIqEo3LuiB.pdf` (2013) and `siEABKREDq.pdf` (2017) | `data/Voting/Elections Results/00_Raw Data/` (only needed to re-run the extraction) |
| **GADM 3.6**, Kenya | Constituency (level 2) boundaries, used to map projects and respondents and to find neighbours | [gadm.org](https://gadm.org/download_country36.html) (shapefile) | `data/Geo/gadm36_KEN_shp/gadm36_KEN_2.shp` (and the other shapefile parts) |
| **Kenya constituency boundaries** (290 constituencies) | Maps of the winning coalition by constituency, 2013 and 2017 | *(source to be added)* | `data/Geo/Kenya_Constituencies/Constituencies.shp` |
| **AidData GeoQuery** extract, Kenya ADM2 ([Goodman et al. 2019](https://www.aiddata.org/geoquery)) | Baseline controls: political leader birthplace (PLAD), population density (GPW v4), night-time lights, travel time to cities, slope, distance to roads | [geoquery.org](https://www.aiddata.org/geoquery), Kenya at ADM2 level | `data/Controls/controls.csv` |

**Included in the repository:** `data/Voting/Elections Results/01_Cleaned Data/Results_National_Assembly_2013.csv` and `..._2017.csv`. These are the constituency-level National Assembly results that I extracted from the public IEBC PDFs (`code/00_extract`) and then cleaned. The analysis starts from these files.

## How to run

**Requirements**
- Stata 18 or later. `master.do` installs the SSC packages it needs if they are missing: `reghdfe`, `ftools`, `estout`, `spmap`, `shp2dta`, `geoinpoly`.
- Python 3.10+ with `pip install -r requirements.txt`. This is used for the spillover measures and, optionally, the PDF extraction.

**Steps**
1. Download the data above into `data/`.
2. Open Stata, `cd` to this folder and run:
   ```stata
   do master.do
   ```
3. Tables are written to `output/tables/` and figures to `output/figures/`.

At the top of `master.do` you can change the data folder (`$data`) and the Python executable (`$python`, for example the full path from `which python3`), and choose which parts to run.

## What each script does

### 00_extract (Python, optional)
| Script | Description |
|---|---|
| `extract_pdf.py` | Reads the result tables from the IEBC PDFs with `pdfplumber`, drops repeated headers and logs rows it cannot parse cleanly |
| `extract_2013.py`, `extract_2017.py` | Extract the 2013 and 2017 National and County Assembly results |

### 01_clean
| Script | Description |
|---|---|
| `01_clean_aid.do` | Imports GODAD project data (China and World Bank) |
| `02_clean_elections.do` | Imports and stacks the 2013 and 2017 National Assembly results; list of constituencies |
| `03_clean_geo.do` | Converts the GADM shapefile, fixes constituency names and builds the constituency skeletons |
| `04_clean_aid_constituencies.do` | Assigns projects to constituencies and prepares the control variables |
| `05`–`09_clean_afrobarometer_r*.do` | Clean each Afrobarometer round, harmonise the outcomes and locate respondents in constituencies |

### 02_build
| Script | Description |
|---|---|
| `01_build_electoral_outcomes.do` | Incumbent and winning-coalition vote shares by constituency and election |
| `02_build_aid_electoral.do` | Chinese and World Bank projects and commitments before and after 2013, by constituency |
| `03_merge_electoral.do` | Merges electoral outcomes with aid exposure |
| `04_electoral_spillovers.py` | Finds neighbouring constituencies and computes neighbours' exposure (electoral panel) |
| `05_merge_electoral_spillovers_controls.do` | Adds spillover measures and controls: the final electoral dataset |
| `06_build_survey_panel.do` | Stacks the Afrobarometer rounds and builds the constituency × round skeleton |
| `07_build_aid_survey.do` | Cumulative (stock) and inter-round (flow) project exposure by constituency and round |
| `08_survey_spillovers.py` | Neighbours' exposure for the survey panel |
| `09_merge_survey.do` | Merges survey responses, aid exposure, spillovers and controls: the final survey dataset |

### 03_analysis
| Script | Thesis output |
|---|---|
| `01_electoral_main.do` | Main electoral DiD tables (projects, value, logs) and World Bank / restricted-sample tables |
| `02_electoral_pretrends_permutation.do` | Leader-birthplace allocation test, placebo tables and permutation-test figures |
| `03_electoral_spillovers.do` | Electoral spillover tables |
| `04_survey_coefplots.do` | Survey coefficient plots (living conditions, political perceptions, democracy) |
| `05_survey_main_tables.do` | Full survey tables in the appendix (flow and stock panels) |
| `06_survey_pretrends.do` | Survey pre-trend (leads) tables and birthplace test |
| `07_survey_restricted_sample.do` | Survey results on the restricted sample |
| `08_survey_placebo_wb.do` | World Bank placebo for the survey outcomes |
| `09_survey_spillovers.do` | Survey spillover tables |

### 04_figures
| Script | Description |
|---|---|
| `01_descriptives.do` | Projects and commitments over time, sector and size comparisons (China vs World Bank), winning-coalition maps |

### Not produced by the code
The flagship-projects table (`Descriptive_main_proj.tex`) was written by hand. The project-location maps (`china_kenya_map_v4`, `wb_kenya_map-2`) and the ethnicity map (`kenya_ethnicity_constituencies_v2`) were made outside this pipeline. The ethnicity map uses the *Kenya Ethnic Tribes and Languages* dataset from the IGAD Climate Prediction and Applications Centre (ICPAC) GeoPortal.
