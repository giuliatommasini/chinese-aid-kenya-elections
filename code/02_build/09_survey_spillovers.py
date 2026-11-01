"""
Identify Bordering Constituencies and Calculate Spillover Exposure Measures
For Kenya Chinese Aid Projects Analysis

This script:
1. Loads the cleaned shapefile with constituency boundaries
2. Identifies which constituencies border each other
3. Calculates continuous spillover exposure measures
4. Accounts for the ID cleaning that was done (dropped unknowns, renamed Webuye West)

Requirements: geopandas, pandas, numpy
Date: February 9, 2026
"""

import pandas as pd
import geopandas as gpd
import numpy as np
import os
import sys

# Data folder: pass it as the first argument (master.do does this).
DATA = sys.argv[1] if len(sys.argv) > 1 else "data"
SPILLOVER_DIR = os.path.join(DATA, "Geo", "spillover")
os.makedirs(SPILLOVER_DIR, exist_ok=True)

print("="*80)
print("SPILLOVER EXPOSURE ANALYSIS FOR KENYA CHINESE AID PROJECTS")
print("="*80)

# ============================================================================
# STEP 1: Load Data
# ============================================================================
print("\n[STEP 1] Loading data...")

# Load project data
df = pd.read_stata(os.path.join(DATA, 'Survey Analysis/aid_survey_final_combined.dta'))
print(f"  ✓ Project data: {len(df)} observations, {df['_ID'].nunique()} constituencies")

# Load shapefile
gdf = gpd.read_file(os.path.join(DATA, 'Geo/gadm36_KEN_shp/gadm36_KEN_2.shp'))
print(f"  ✓ Shapefile: {len(gdf)} features loaded")
print(f"    Columns: {', '.join(gdf.columns[:5])}...")

# ============================================================================
# STEP 2: Clean Shapefile to Match Your Data
# ============================================================================
print("\n[STEP 2] Cleaning shapefile to match your constituency definitions...")

# Filter out the constituencies you dropped
drop_names = ["805", "unknown 1", "unknown 2", "unknown 3", "unknown 4",
              "unknown 5", "unknown 6", "unknown 7", "unknown 8"]
gdf = gdf[~gdf['NAME_2'].isin(drop_names)].copy()
print(f"  ✓ Dropped {len(drop_names)} constituencies")

# Fix the typo
gdf.loc[gdf['NAME_2'] == "Webute West", 'NAME_2'] = "Webuye West"
print(f"  ✓ Fixed Webuye West name")

# Sort and create ID matching your egen id_diss = group(NAME_2)
gdf = gdf.sort_values('NAME_2').reset_index(drop=True)
gdf['_ID'] = range(1, len(gdf) + 1)
print(f"  ✓ Created _ID (1 to {len(gdf)}) in alphabetical order by NAME_2")

# Verify alignment
print(f"  ✓ Final shapefile: {len(gdf)} constituencies")
print(f"    First few: {gdf['NAME_2'].head(3).tolist()}")
print(f"    Last few: {gdf['NAME_2'].tail(3).tolist()}")

# ============================================================================
# STEP 3: Identify Spatial Neighbors
# ============================================================================
print("\n[STEP 3] Identifying spatial neighbors...")
print("  (This may take 1-2 minutes...)")

# Create dictionary to store neighbors for each constituency
neighbor_dict = {}
border_pairs = []

# For each constituency
for idx, row in gdf.iterrows():
    const_id = row['_ID']
    const_name = row['NAME_2']
    const_geom = row.geometry
    
    # Find all constituencies that share a border (touch)
    neighbors = gdf[gdf.geometry.touches(const_geom)]
    neighbors = neighbors[neighbors['_ID'] != const_id]  # Exclude self
    
    neighbor_ids = neighbors['_ID'].tolist()
    neighbor_names = neighbors['NAME_2'].tolist()
    neighbor_dict[const_id] = neighbor_ids
    
    # Store each border pair
    for nid, nname in zip(neighbor_ids, neighbor_names):
        border_pairs.append({
            'constituency_id': const_id,
            'constituency_name': const_name,
            'neighbor_id': nid,
            'neighbor_name': nname
        })
    
    if (idx + 1) % 50 == 0:
        print(f"    Processed {idx + 1}/{len(gdf)} constituencies...")

print(f"  ✓ Identified {len(border_pairs)} border relationships")
print(f"  ✓ Average neighbors per constituency: {len(border_pairs)/len(gdf):.1f}")

# Save border relationships
borders_df = pd.DataFrame(border_pairs)
borders_df.to_csv(os.path.join(SPILLOVER_DIR, 'constituency_borders_detailed.csv'), index=False)
borders_df.to_stata(os.path.join(SPILLOVER_DIR, 'constituency_borders_detailed.dta'), write_index=False)
print(f"  ✓ Saved: constituency_borders_detailed.csv/.dta")

# ============================================================================
# STEP 4: Calculate Treatment Status
# ============================================================================
print("\n[STEP 4] Identifying treated constituencies...")

# Aggregate project counts by constituency across all years
treatment = df.groupby('_ID').agg({
    'num_projects_ch': 'sum',
    'mon_value_ch': 'sum'
}).reset_index()

treatment['treated'] = (treatment['num_projects_ch'] > 0).astype(int)
n_treated = treatment['treated'].sum()
print(f"  ✓ Treated constituencies: {n_treated} out of {len(treatment)}")
print(f"  ✓ Total Chinese projects: {treatment['num_projects_ch'].sum():.0f}")
print(f"  ✓ Total value: ${treatment['mon_value_ch'].sum():,.0f}")

# ============================================================================
# STEP 5: Create Spillover Measures by Year
# ============================================================================
print("\n[STEP 5] Creating continuous spillover exposure measures...")

# Get project counts by constituency-year
projects_by_year = df.copy()

# Initialize spillover measures
spillover_measures = []

years = sorted(df['year'].unique())
print(f"  Years analyzed: {years}")

for year in years:
    # Get this year's data
    year_data = projects_by_year[projects_by_year['year'] == year].set_index('_ID')
    
    # For each constituency
    for const_id in range(1, 291):  # 1 to 290
        # Get neighbors
        neighbors = neighbor_dict.get(const_id, [])
        total_neighbors = len(neighbors)
        
        if total_neighbors == 0:
            # Island constituency (no neighbors)
            spillover_measures.append({
                '_ID': const_id,
                'year': year,
                'total_neighbors': 0,
                'num_treated_neighbors': 0,
                'pct_treated_neighbors': 0,
                'spillover_num_projects': 0,
                'spillover_mon_value': 0,
                'avg_neighbor_projects': 0,
                'max_neighbor_projects': 0,
                'spillover_intensity': 0
            })
            continue
        
        # Get neighbor data for this year
        neighbor_data = year_data.loc[year_data.index.isin(neighbors)]
        
        # Calculate spillover measures
        spillover_projects = neighbor_data['num_projects_ch'].sum()
        spillover_value = neighbor_data['mon_value_ch'].sum()
        num_treated_neighbors = (neighbor_data['num_projects_ch'] > 0).sum()
        
        # Various intensity measures
        avg_projects = spillover_projects / total_neighbors
        max_projects = neighbor_data['num_projects_ch'].max() if len(neighbor_data) > 0 else 0
        pct_treated = num_treated_neighbors / total_neighbors
        
        # Combined intensity measure (you can customize this)
        # This is: average projects per neighbor
        intensity = avg_projects
        
        spillover_measures.append({
            '_ID': const_id,
            'year': year,
            'total_neighbors': total_neighbors,
            'num_treated_neighbors': num_treated_neighbors,
            'pct_treated_neighbors': pct_treated,
            'spillover_num_projects': spillover_projects,
            'spillover_mon_value': spillover_value,
            'avg_neighbor_projects': avg_projects,
            'max_neighbor_projects': max_projects,
            'spillover_intensity': intensity
        })

spillover_df = pd.DataFrame(spillover_measures)
print(f"  ✓ Created {len(spillover_df)} constituency-year spillover observations")

# Summary statistics
print(f"\n  Spillover Summary Statistics:")
print(f"    Constituencies with at least 1 treated neighbor: {(spillover_df['num_treated_neighbors'] > 0).sum()}")
print(f"    Max treated neighbors: {spillover_df['num_treated_neighbors'].max():.0f}")
print(f"    Avg projects in neighbors (when > 0): {spillover_df[spillover_df['spillover_num_projects'] > 0]['avg_neighbor_projects'].mean():.2f}")

# ============================================================================
# STEP 6: Merge with Original Data
# ============================================================================
print("\n[STEP 6] Merging spillover measures with original dataset...")

final_df = df.merge(spillover_df, on=['_ID', 'year'], how='left')

# Verify merge
print(f"  ✓ Final dataset: {len(final_df)} rows")
print(f"  ✓ All rows matched: {final_df['spillover_intensity'].notna().all()}")

# ============================================================================
# STEP 7: Create Additional Classification Variables
# ============================================================================
print("\n[STEP 7] Creating treatment classification variables...")

# Add treatment status
final_df = final_df.merge(
    treatment[['_ID', 'treated']],
    on='_ID',
    how='left'
)

# Create spillover treatment indicator
final_df['borders_treated'] = (final_df['num_treated_neighbors'] > 0).astype(int)

# Create three-way classification
def classify_constituency(row):
    if row['treated'] == 1:
        return 'treated'
    elif row['borders_treated'] == 1:
        return 'spillover'
    else:
        return 'control'

final_df['treatment_group'] = final_df.apply(classify_constituency, axis=1)

# Summary
group_counts = final_df.groupby('treatment_group')['_ID'].nunique()
print(f"  ✓ Treatment groups created:")
print(f"      Treated: {group_counts.get('treated', 0)} constituencies")
print(f"      Spillover (borders treated): {group_counts.get('spillover', 0)} constituencies")
print(f"      Pure control: {group_counts.get('control', 0)} constituencies")

# ============================================================================
# STEP 8: Save All Outputs
# ============================================================================
print("\n[STEP 8] Saving results...")

# Save spillover measures only
spillover_df.to_csv(os.path.join(SPILLOVER_DIR, 'spillover_measures_byyear.csv'), index=False)
spillover_df.to_stata(os.path.join(SPILLOVER_DIR, 'spillover_measures_byyear.dta'), write_index=False)
print(f"  ✓ Saved: spillover_measures_byyear.csv/.dta")

# Save complete dataset
final_df.to_csv(os.path.join(SPILLOVER_DIR, 'aid_data_with_spillovers.csv'), index=False)
final_df.to_stata(os.path.join(SPILLOVER_DIR, 'aid_data_with_spillovers.dta'), write_index=False)
print(f"  ✓ Saved: aid_data_with_spillovers.csv/.dta")

# Create a constituency-level summary
const_summary = final_df.groupby('_ID').agg({
    'num_projects_ch': 'sum',
    'mon_value_ch': 'sum',
    'spillover_num_projects': 'mean',
    'spillover_mon_value': 'mean',
    'total_neighbors': 'first',
    'treated': 'first',
    'treatment_group': 'first'
}).reset_index()

# Add constituency names
const_summary = const_summary.merge(
    gdf[['_ID', 'NAME_2', 'NAME_1']],
    on='_ID',
    how='left'
)

const_summary.to_csv(os.path.join(SPILLOVER_DIR, 'constituency_summary.csv'), index=False)
const_summary.to_stata(os.path.join(SPILLOVER_DIR, 'constituency_summary.dta'), write_index=False)
print(f"  ✓ Saved: constituency_summary.csv/.dta")

# ============================================================================
# STEP 9: Generate Summary Report
# ============================================================================
print("\n" + "="*80)
print("ANALYSIS COMPLETE - SUMMARY REPORT")
print("="*80)

print(f"\nDATA STRUCTURE:")
print(f"  Total constituencies: {len(gdf)}")
print(f"  Years: {', '.join(map(str, years))}")
print(f"  Total observations: {len(final_df)}")

print(f"\nTREATMENT:")
print(f"  Treated constituencies: {n_treated}")
print(f"  Total Chinese projects: {treatment['num_projects_ch'].sum():.0f}")

print(f"\nSPILLOVER:")
print(f"  Constituencies bordering treated areas: {group_counts.get('spillover', 0)}")
print(f"  Pure control constituencies: {group_counts.get('control', 0)}")
print(f"  Avg neighbors per constituency: {spillover_df['total_neighbors'].mean():.1f}")

print(f"\nVARIABLES CREATED:")
print(f"  total_neighbors - Number of bordering constituencies")
print(f"  num_treated_neighbors - Count of neighbors with Chinese projects")
print(f"  pct_treated_neighbors - Proportion of neighbors that are treated")
print(f"  spillover_num_projects - Total Chinese projects in neighbor constituencies")
print(f"  spillover_mon_value - Total monetary value of projects in neighbors")
print(f"  avg_neighbor_projects - Average projects per neighbor")
print(f"  max_neighbor_projects - Maximum projects in any single neighbor")
print(f"  spillover_intensity - Continuous measure (= avg_neighbor_projects)")
print(f"  borders_treated - Binary indicator for any treated neighbor")
print(f"  treatment_group - Three-way classification (treated/spillover/control)")

print(f"\nOUTPUT FILES:")
print(f"  1. aid_data_with_spillovers.dta - Main analysis file")
print(f"  2. spillover_measures_byyear.dta - Spillover measures only")
print(f"  3. constituency_borders_detailed.dta - All border relationships")
print(f"  4. constituency_summary.dta - Constituency-level summary")

print("\n" + "="*80)
print("READY FOR ANALYSIS!")
print("="*80)
print("\nSuggested next steps:")
print("  1. Load aid_data_with_spillovers.dta in Stata")
print("  2. Explore spillover_intensity distribution")
print("  3. Run regressions with spillover measures as treatment")
print("  4. Consider interaction terms: treated × spillover_intensity")
print("\n")
