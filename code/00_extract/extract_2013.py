import pandas as pd
import extract_pdf
import re
import os
import sys

# Usage: python extract_YEAR.py <data folder> [output folder]
DATA = sys.argv[1] if len(sys.argv) > 1 else "data"
OUT = sys.argv[2] if len(sys.argv) > 2 else "."
RAW = os.path.join(DATA, "Voting", "Elections Results", "00_Raw Data")

# National Assembly 2013
pdf_file = os.path.join(RAW, "EIqEo3LuiB.pdf")
start_page = 90
end_page = 194 # inclusive
expected_col_count = 8

df = extract_pdf.extract_table(pdf_file, start_page, end_page, expected_col_count)

# unique_parties = df[df.columns[7]].unique()

# Remove commas in the dataframe
df = df.map(
   lambda x: x.replace(',', '') if isinstance(x, str) else x
)

# Replace newlines with underscores in the dataframe
df = df.map(
    lambda x: re.sub(r'\s*\n\s*', '_', x) if isinstance(x, str) else x
 )

# Filter the dataframe to exclude rows where the 4th column equals "TOTAL VALID VOTES"
df = df[df.iloc[:, 3] != "TOTAL VALID_VOTES"]


# Saving a data for datapoints with 5th column empty (checking problematic datapoints)
df_filtered = df[df.iloc[:, 4].isnull() & (df.iloc[:, 3] != "TOTAL VALID VOTES")]

df_filtered.to_csv(os.path.join(OUT, "Results_problematic_National_Assembly_2013.csv"), index=False)


# Remove rows where the 5th column is empty (NaN or empty strings)
df = df[df.iloc[:, 4].notna() & (df.iloc[:, 4] != '')]  


# Count datapoints where the 7th column is empty (NaN or empty string)
empty_7th_column_count = df[df.iloc[:, 6].isna() | (df.iloc[:, 6] == '')].shape[0]

# Print the count of datapoints where the 7th column is empty
print(f"Number of datapoints with an empty 7th column: {empty_7th_column_count}")

# Filter the rows where the 7th column is empty (NaN or empty string)
rows_with_empty_7th_column = df[df.iloc[:, 6].isna() | (df.iloc[:, 6] == '')]

# Display the first few rows in the console
print(rows_with_empty_7th_column) 


# Save the cleaned dataframe to a CSV file
df.to_csv(os.path.join(OUT, "Results_National_Assembly_2013.csv"), index=False) 


# County Assembly 2013 
pdf_file = os.path.join(RAW, "EIqEo3LuiB.pdf")
start_page = 245
end_page = 766 # inclusive
expected_col_count = 10

df = extract_pdf.extract_table(pdf_file, start_page, end_page, expected_col_count)

# Remove commas in the dataframe
df = df.map(
   lambda x: re.sub(r',', '', x) if isinstance(x, str) else x
)

# Replace newlines with underscores in the dataframe
df = df.map(
    lambda x: re.sub(r'\s*\n\s*', '_', x) if isinstance(x, str) else x
)

# Filter the dataframe to exclude rows where the 3th column equals "TOTAL"
df = df[df.iloc[:, 2] != "TOTAL"]


# Saving a data for datapoints with 10th column empty or 1st column empty (checking problematic datapoints)
df_filtered = df[df.iloc[:, 9].isnull() | (df.iloc[:, 3] .isnull())]

print(df_filtered[df_filtered.apply(lambda row: row.astype(str).str.strip().eq('').all() or row.isna().all(), axis=1)])

# Removing rows where all values are NaN or empty strings
df_filtered = df_filtered[~df_filtered.apply(lambda row: row.astype(str).str.strip().eq('').all() or row.isna().all(), axis=1)]

df_filtered.to_csv(os.path.join(OUT, "Results_problematic_County_Assembly_2013.csv"), index=False)


# Remove rows where the 10th column or 1st column are empty (NaN or empty strings)
df = df[(df.iloc[:, 9].notna() & (df.iloc[:, 9] != '')) | (df.iloc[:, 9].notna() & (df.iloc[:, 0] != ''))] 


# Count datapoints where the 9th column is empty (NaN or empty string)
empty_9th_column_count = df[df.iloc[:, 8].isna() | (df.iloc[:, 8] == '')].shape[0]

# Print the count of datapoints where the 9th column is empty
print(f"Number of datapoints with an empty 9th column: {empty_9th_column_count}")

# Filter the rows where the 9th column is empty (NaN or empty string)
df_empty_9th_column = df[df.iloc[:, 8].isna() | (df.iloc[:, 8] == '')]

# Save the filtered dataframe (rows with empty 9th column) to a new CSV file
df_empty_9th_column.to_csv(os.path.join(OUT, "Results_emptypolparty_County_2013.csv"), index=False)

# Remove rows where the 9th column is empty (NaN or empty strings)
df = df[df.iloc[:, 8].notna() & (df.iloc[:, 8] != '')] 


# Save the cleaned dataframe to a CSV file
df.to_csv(os.path.join(OUT, "Results_County_Assembly_2013.csv"), index=False)