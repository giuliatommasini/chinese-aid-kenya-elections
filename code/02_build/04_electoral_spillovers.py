"""
Spillover Analysis for Electoral Data - STOCK MEASURES ONLY
Creates spillover intensity for both project counts and monetary value

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
print("ELECTORAL SPILLOVER ANALYSIS - STOCK MEASURES")
print("="*80)

# ============================================================================
# STEP 1: Load and Prepare Electoral Data
# ============================================================================
print("\n[STEP 1] Loading electoral data...")

df = pd.read_stata(os.path.join(DATA, 'Electoral Analysis/electoral_analysis_heter_donor.dta'))
print(f"  ✓ Loaded: {len(df)} observations")
print(f"  Constituencies: {df['constituencyname'].nunique()}")
print(f"  Periods: {df['period'].unique()}")

# Standardize constituency names for matching
df['constituencyname_clean'] = df['constituencyname'].str.upper().str.strip()

# ============================================================================
# STEP 2: Load and Clean Shapefile
# ============================================================================
print("\n[STEP 2] Loading and cleaning shapefile...")

gdf = gpd.read_file(os.path.join(DATA, 'Geo/gadm36_KEN_shp/gadm36_KEN_2.shp'))
print(f"  ✓ Loaded: {len(gdf)} features")

# Clean shapefile (same as your Stata code)
drop_names = ["805", "unknown 1", "unknown 2", "unknown 3", "unknown 4",
              "unknown 5", "unknown 6", "unknown 7", "unknown 8"]
gdf = gdf[~gdf['NAME_2'].isin(drop_names)].copy()
gdf.loc[gdf['NAME_2'] == "Webute West", 'NAME_2'] = "Webuye West"
print(f"  ✓ Dropped/fixed: {len(gdf)} constituencies remaining")

# Create _ID in ALPHABETICAL order (matching your egen id_diss = group(NAME_2))
gdf = gdf.sort_values('NAME_2').reset_index(drop=True)
gdf['_ID'] = range(1, len(gdf) + 1)
gdf['NAME_2_clean'] = gdf['NAME_2'].str.upper().str.strip()
print(f"  ✓ Created _ID: 1 to {gdf['_ID'].max()} (alphabetical by NAME_2)")

# ============================================================================
# STEP 3: Match Electoral Data to Shapefile _ID
# ============================================================================
print("\n[STEP 3] Matching constituency names to assign _ID...")

# Create name-to-_ID mapping from shapefile
name_to_id = dict(zip(gdf['NAME_2_clean'], gdf['_ID']))

# Assign _ID to electoral data based on name match
df['_ID'] = df['constituencyname_clean'].map(name_to_id)

# Check for unmatched constituencies
unmatched = df[df['_ID'].isna()]['constituencyname'].unique()
if len(unmatched) > 0:
    print(f"  WARNING: {len(unmatched)} constituencies could not be matched:")
    for name in unmatched[:10]:
        print(f"    - {name}")
    # Remove unmatched
    df = df[df['_ID'].notna()].copy()
    print(f"  Removed unmatched constituencies")

df['_ID'] = df['_ID'].astype(int)
print(f"  ✓ Matched: {df['_ID'].nunique()} constituencies have _ID")
print(f"  ✓ _ID range: {df['_ID'].min()} to {df['_ID'].max()}")

# Verify we have the right number
if df['_ID'].nunique() != len(gdf):
    print(f"  WARNING: Electoral data has {df['_ID'].nunique()} constituencies")
    print(f"           Shapefile has {len(gdf)} constituencies")
else:
    print(f"  ✓ Perfect match: {df['_ID'].nunique()} constituencies in both files")

# ============================================================================
# STEP 4: Identify Spatial Neighbors
# ============================================================================
print("\n[STEP 4] Identifying spatial neighbors...")

neighbor_dict = {}
border_pairs = []

for idx, row in gdf.iterrows():
    const_id = row['_ID']
    const_name = row['NAME_2']
    const_geom = row.geometry
    
    # Find neighbors that share a border
    neighbors = gdf[gdf.geometry.touches(const_geom)]
    neighbors = neighbors[neighbors['_ID'] != const_id]
    
    neighbor_ids = neighbors['_ID'].tolist()
    neighbor_names = neighbors['NAME_2'].tolist()
    neighbor_dict[const_id] = neighbor_ids
    
    for nid, nname in zip(neighbor_ids, neighbor_names):
        border_pairs.append({
            'constituency_id': const_id,
            'constituency_name': const_name,
            'neighbor_id': nid,
            'neighbor_name': nname
        })
    
    if (idx + 1) % 50 == 0:
        print(f"    Processed {idx + 1}/{len(gdf)}...")

print(f"  ✓ Identified {len(border_pairs)} border relationships")

# Save borders
borders_df = pd.DataFrame(border_pairs)
borders_df.to_csv(os.path.join(SPILLOVER_DIR, 'electoral_borders.csv'), index=False)
borders_df.to_stata(os.path.join(SPILLOVER_DIR, 'electoral_borders.dta'), write_index=False)

# ============================================================================
# STEP 5: Calculate Spillover Measures (STOCK ONLY)
# ============================================================================
print("\n[STEP 5] Calculating spillover measures...")

spillover_measures = []

for period in ['pre', 'post']:
    period_data = df[df['period'] == period].set_index('_ID')
    
    print(f"  Processing {period} period...")
    
    for const_id in range(1, gdf['_ID'].max() + 1):
        neighbors = neighbor_dict.get(const_id, [])
        total_neighbors = len(neighbors)
        
        if total_neighbors == 0:
            # No neighbors (island)
            spillover_measures.append({
                '_ID': const_id,
                'period': period,
                'total_neighbors': 0,
                'num_treated_neighbors': 0,
                'pct_treated_neighbors': 0,
                'spillover_num_projects': 0,
                'spillover_mon_value': 0,
                'spillover_intensity_projects': 0,
                'spillover_intensity_value': 0
            })
            continue
        
        # Get neighbor data for this period
        neighbor_data = period_data.loc[period_data.index.isin(neighbors)]
        
        if len(neighbor_data) == 0:
            # Neighbors exist but no data for them
            spillover_measures.append({
                '_ID': const_id,
                'period': period,
                'total_neighbors': total_neighbors,
                'num_treated_neighbors': 0,
                'pct_treated_neighbors': 0,
                'spillover_num_projects': 0,
                'spillover_mon_value': 0,
                'spillover_intensity_projects': 0,
                'spillover_intensity_value': 0
            })
            continue
        
        # Calculate spillover measures
        spillover_projects = neighbor_data['num_projects_china'].sum()
        spillover_value = neighbor_data['mon_value_ch'].sum()
        num_treated_neighbors = (neighbor_data['num_projects_china'] > 0).sum()
        
        # Intensity measures (average per neighbor)
        intensity_projects = spillover_projects / total_neighbors
        intensity_value = spillover_value / total_neighbors
        
        spillover_measures.append({
            '_ID': const_id,
            'period': period,
            'total_neighbors': total_neighbors,
            'num_treated_neighbors': num_treated_neighbors,
            'pct_treated_neighbors': num_treated_neighbors / total_neighbors,
            'spillover_num_projects': spillover_projects,
            'spillover_mon_value': spillover_value,
            'spillover_intensity_projects': intensity_projects,
            'spillover_intensity_value': intensity_value
        })

spillover_df = pd.DataFrame(spillover_measures)
print(f"  ✓ Created {len(spillover_df)} spillover observations")

# ============================================================================
# STEP 6: Merge with Original Data
# ============================================================================
print("\n[STEP 6] Merging with original data...")

final_df = df.merge(spillover_df, on=['_ID', 'period'], how='left')
print(f"  ✓ Merged: {len(final_df)} rows")

# Verify merge
missing = final_df['spillover_intensity_projects'].isna().sum()
if missing > 0:
    print(f"  WARNING: {missing} rows with missing spillover data")
else:
    print(f"  ✓ All rows have spillover data")

# ============================================================================
# STEP 7: Create Treatment Classification
# ============================================================================
print("\n[STEP 7] Creating treatment groups...")

# Overall treatment (ever received Chinese aid)
treatment = df.groupby('_ID')['num_projects_china'].sum().reset_index()
treatment['treated'] = (treatment['num_projects_china'] > 0).astype(int)

final_df = final_df.merge(treatment[['_ID', 'treated']], on='_ID', how='left')

# Spillover indicator
final_df['borders_treated'] = (final_df['num_treated_neighbors'] > 0).astype(int)

# Three-way classification
def classify(row):
    if row['treated'] == 1:
        return 'treated'
    elif row['borders_treated'] == 1:
        return 'spillover'
    else:
        return 'control'

final_df['treatment_group'] = final_df.apply(classify, axis=1)

# Summary
for period in ['pre', 'post']:
    pdata = final_df[final_df['period'] == period]
    counts = pdata.groupby('treatment_group')['_ID'].nunique()
    print(f"\n  {period.upper()} period:")
    print(f"    Treated: {counts.get('treated', 0)}")
    print(f"    Spillover: {counts.get('spillover', 0)}")
    print(f"    Control: {counts.get('control', 0)}")

# ============================================================================
# STEP 8: Save Outputs
# ============================================================================
print("\n[STEP 8] Saving outputs...")

# Spillover measures only
spillover_df.to_csv(os.path.join(SPILLOVER_DIR, 'electoral_spillover_measures.csv'), index=False)
spillover_df.to_stata(os.path.join(SPILLOVER_DIR, 'electoral_spillover_measures.dta'), write_index=False)
print("  ✓ Saved: electoral_spillover_measures.csv/.dta")

# Complete dataset
final_df.to_csv(os.path.join(SPILLOVER_DIR, 'electoral_with_spillovers.csv'), index=False)
final_df.to_stata(os.path.join(SPILLOVER_DIR, 'electoral_with_spillovers.dta'), write_index=False)
print("  ✓ Saved: electoral_with_spillovers.csv/.dta")

# Constituency summary
const_summary = final_df.groupby('_ID').agg({
    'constituencyname': 'first',
    'num_projects_china': 'first',
    'mon_value_ch': 'first',
    'spillover_intensity_projects': 'mean',
    'spillover_intensity_value': 'mean',
    'total_neighbors': 'first',
    'treated': 'first',
    'treatment_group': 'first'
}).reset_index()

const_summary = const_summary.merge(
    gdf[['_ID', 'NAME_2', 'NAME_1']],
    on='_ID',
    how='left'
)

const_summary.to_csv(os.path.join(SPILLOVER_DIR, 'electoral_constituency_summary.csv'), index=False)
const_summary.to_stata(os.path.join(SPILLOVER_DIR, 'electoral_constituency_summary.dta'), write_index=False)
print("  ✓ Saved: electoral_constituency_summary.csv/.dta")

# ============================================================================
# STEP 9: Summary Report
# ============================================================================
print("\n" + "="*80)
print("ANALYSIS COMPLETE")
print("="*80)

print(f"\nDATA:")
print(f"  Constituencies: {final_df['_ID'].nunique()}")
print(f"  Observations: {len(final_df)} (2 periods × constituencies)")

print(f"\nTREATMENT:")
n_treated = treatment['treated'].sum()
print(f"  Treated constituencies: {n_treated}")
print(f"  Total Chinese projects: {treatment['num_projects_china'].sum():.0f}")

print(f"\nSPILLOVER:")
overall_counts = final_df.groupby('treatment_group')['_ID'].nunique()
print(f"  With spillover exposure: {overall_counts.get('spillover', 0)}")
print(f"  Pure control: {overall_counts.get('control', 0)}")
print(f"  Avg neighbors: {spillover_df['total_neighbors'].mean():.1f}")

print(f"\nVARIABLES CREATED:")
print(f"  spillover_intensity_projects - Avg projects per neighbor (MAIN)")
print(f"  spillover_intensity_value - Avg $ value per neighbor (MAIN)")
print(f"  spillover_num_projects - Total projects in all neighbors")
print(f"  spillover_mon_value - Total $ value in all neighbors")
print(f"  num_treated_neighbors - Count of neighbors with Chinese aid")
print(f"  pct_treated_neighbors - Proportion of neighbors treated")
print(f"  total_neighbors - Number of bordering constituencies")
print(f"  borders_treated - Binary: any treated neighbor")
print(f"  treatment_group - Classification: treated/spillover/control")

print(f"\nOUTPUT FILES:")
print(f"  1. electoral_with_spillovers.dta - MAIN FILE FOR ANALYSIS")
print(f"  2. electoral_spillover_measures.dta - Spillover measures only")
print(f"  3. electoral_borders.dta - Border relationships")
print(f"  4. electoral_constituency_summary.dta - Constituency-level summary")

print("\n" + "="*80)
print("READY FOR ANALYSIS!")
print("="*80)
print("\nExample usage in Stata:")
print("  use electoral_with_spillovers.dta, clear")
print("  ")
print("  * Using project spillover:")
print("  reg Incumbent_vote_share c.num_projects_china##i.Post \\")
print("      c.spillover_intensity_projects##i.Post \\")
print("      controls, cluster(_ID)")
print("  ")
print("  * Using value spillover:")
print("  reg Incumbent_vote_share c.num_projects_china##i.Post \\")
print("      c.spillover_intensity_value##i.Post \\")
print("      controls, cluster(_ID)")
print("\n")
