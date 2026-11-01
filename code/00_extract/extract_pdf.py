import os
import pdfplumber
import pandas as pd
import warnings



tables_settings = {
        "vertical_strategy": "lines",  # Use text alignment for vertical lines
        "horizontal_strategy": "lines",  # Use lines for horizontal boundaries
        "edge_min_length": 200,  # Minimum length for detected lines
        "min_words_vertical": 3,
        "min_words_horizontal": 1,
#       "intersection_tolerance": 5,  # Adjust tolerance for intersections
#      "snap_tolerance": 3,  # Snap text to nearby lines
#        "join_tolerance": 2,  # Join nearby lines
    }

def extract_table(pdf_path, start_page, end_page, expected_col_count=10):
    rows = []
    header = None
    dirty_rows = []
    clean_rows = []

    with pdfplumber.open(pdf_path) as pdf:
        for i in range(start_page - 1, end_page):  # 0-based indexing
            page = pdf.pages[i]

            tables = page.extract_tables(table_settings=tables_settings)

            if not tables or len(tables) == 0:
                continue
            
            tables = tables[0] if tables and len(tables) > 0 else None

            # Capture the header from the first page only
            if header is None:
                header = tables[0]
                table_rows = tables[1:]  # skip header row
            else:
                # Check if first row is a repeated header
                if tables[0] == header:
                    table_rows = tables[1:]  # skip repeated header
                else:
                    table_rows = tables  # keep all rows

            for row in table_rows:
                if len(row) == expected_col_count:
                    clean_rows.append(row)
                else:
                    dirty_rows.append(row)
        
        # save the dirty rows to a file
        os.makedirs("debug", exist_ok=True)
        with open("debug/dirty_rows.txt", "w") as f:
            for row in dirty_rows:
                f.write(str(row) + "\n")
        
        return pd.DataFrame(clean_rows, columns=header)
