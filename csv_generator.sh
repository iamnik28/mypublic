#!/bin/bash

# Input and output file paths
input_excel="demo.xlsx"  # Path to the Excel file
output_csv="demo.csv"   # Path to save the CSV file

# Check if csvkit is installed
if ! command -v in2csv &> /dev/null; then
  echo "Error: 'in2csv' command not found. Install it using 'apt install csvkit'."
  exit 1
fi

# Check if the input Excel file exists
if [ ! -f "$input_excel" ]; then
  echo "Error: The file '$input_excel' does not exist."
  exit 1
fi

# Convert Excel to CSV
echo "Converting '$input_excel' to CSV format..."
in2csv "$input_excel" > "$output_csv"

if [ $? -eq 0 ]; then
  echo "Conversion successful! Data saved in '$output_csv'."
else
  echo "Error: Failed to convert the Excel file to CSV."
fi
