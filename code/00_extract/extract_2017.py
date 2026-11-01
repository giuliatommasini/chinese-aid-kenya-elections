import pandas as pd
import extract_pdf
import re
import os
import sys

# Usage: python extract_YEAR.py <data folder> [output folder]
DATA = sys.argv[1] if len(sys.argv) > 1 else "data"
OUT = sys.argv[2] if len(sys.argv) > 2 else "."
RAW = os.path.join(DATA, "Voting", "Elections Results", "00_Raw Data")

# National Assembly 2017 
pdf_file = os.path.join(RAW, "siEABKREDq.pdf")
start_page = 28
end_page = 127  # inclusive
expected_col_count = 10

df = extract_pdf.extract_table(pdf_file, start_page, end_page, expected_col_count)

# Remove commas in the dataframe
df = df.map(
   lambda x: x.replace(',', '') if isinstance(x, str) else x
)

# Replace newlines with underscores in the dataframe
df = df.map(
    lambda x: re.sub(r'\s*\n\s*', '_', x) if isinstance(x, str) else x
 )

# Count datapoints where the 8th column is empty (NaN or empty string)
empty_7th_column_count = df[df.iloc[:, 7].isna() | (df.iloc[:, 7] == '')].shape[0]

# Print the count of datapoints where the 8th column is empty
print(f"Number of datapoints with an empty 8th column: {empty_7th_column_count}") # 0

# Remove rows where all values are empty or NaN
df = df[~df.apply(lambda row: row.astype(str).str.strip().eq('').all() or row.isna().all(), axis=1)]

df.to_csv(os.path.join(OUT, "Results_National_Assembly_2017.csv"), index=False)


# County Assembly 2017 
pdf_file = os.path.join(RAW, "siEABKREDq.pdf")
start_page = 167
end_page = 685  # inclusive
expected_col_count = 13

df = extract_pdf.extract_table(pdf_file, start_page, end_page, expected_col_count)

# Count datapoints where the 11th column is empty (NaN or empty string)
empty_7th_column_count = df[df.iloc[:, 10].isna() | (df.iloc[:, 10] == '')].shape[0]

# Print the count of datapoints where the 11th column is empty
print(f"Number of datapoints with an empty 11th column: {empty_7th_column_count}") # 1302

# Remove rows where all values are empty or NaN
df = df[~df.apply(lambda row: row.astype(str).str.strip().eq('').all() or row.isna().all(), axis=1)]

# Save the DataFrame to a CSV file
df.to_csv(os.path.join(OUT, "Results_County_Assembly_2017.csv"), index=False)