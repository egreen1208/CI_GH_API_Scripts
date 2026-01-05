import openpyxl
import os
import csv  # Import the csv module
# Define the input CSV file path (replace with your actual file)
csv_file = os.path.join(os.getcwd(), "C:\\Users\\ercellgreen\\OneDrive - USDA\\scripts\\fs_repo_admins\\fs_repo_admins.csv")

# Define the output Excel file path (replace with your desired filename)
excel_file = "fs_repo_admins.xlsx"

# Open the workbook and worksheet
wb = openpyxl.Workbook()
ws = wb.active

# Read the CSV data
with open(csv_file, 'r', newline='') as f:
    reader = csv.reader(f)
    for row in reader:
        ws.append(row)

# Save the workbook as Excel
wb.save(excel_file)

print(f"Successfully converted {csv_file} to {excel_file}")