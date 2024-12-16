#!/bin/bash

# Step 1: Take user inputs
read -p "Enter the name of the deployment: " DEPLOYMENT_NAME
read -p "Enter the namespace of the deployment: " NAMESPACE
read -p "Enter the input file name (keys to search): " INPUT_FILE

# Output files
OUTPUT_FILE_YAML="result.yaml"        # Temporary YAML file for extracted keys and values
OUTPUT_FILE_CSV="result.csv"          # Final CSV output file
TEMP_DEPLOYMENT_YAML="deployment.yaml" # Temporary file for exported YAML

# Step 2: Validate input file
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: Input file '$INPUT_FILE' does not exist."
  exit 1
fi

# Step 3: Export the YAML from the running deployment
echo "Exporting YAML for deployment '$DEPLOYMENT_NAME' in namespace '$NAMESPACE'..."
kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" -o yaml > "$TEMP_DEPLOYMENT_YAML"

if [[ $? -ne 0 ]]; then
  echo "Error: Failed to export deployment YAML. Please check the deployment name and namespace."
  exit 1
fi
echo "YAML successfully exported to '$TEMP_DEPLOYMENT_YAML'."

# Step 4: Extract keys from input file and match them in the deployment YAML
echo "---" > "$OUTPUT_FILE_YAML"  # Initialize YAML result file
echo "Extracting keys and values from deployment YAML using input file '$INPUT_FILE'..."

while IFS= read -r key; do
  # Clean up key (remove leading/trailing spaces)
  key=$(echo "$key" | sed 's/^[ ]*//;s/[ ]*$//')

  # Search for key and extract value
  value=$(awk -v key="$key" '
    $1 == key ":" { 
      sub(key ":", "", $0); 
      gsub(/^[ \t]+|[ \t]+$/, "", $0); 
      print $0 
    }' "$TEMP_DEPLOYMENT_YAML")

  # Append to YAML output
  if [[ -n "$value" ]]; then
    echo "$key: $value" >> "$OUTPUT_FILE_YAML"
    echo "Found: $key -> $value"
  else
    echo "$key: Key not found" >> "$OUTPUT_FILE_YAML"
    echo "Not Found: $key"
  fi
done < "$INPUT_FILE"

echo "Extraction complete. YAML result saved to '$OUTPUT_FILE_YAML'."

# Step 5: Convert YAML result to CSV
echo "Converting YAML to CSV..."
echo "Key,Value" > "$OUTPUT_FILE_CSV"  # Add CSV header

awk -F ': ' '/:/ { 
  key=$1; 
  value=$2; 
  gsub(/^[ \t]+|[ \t]+$/, "", key); 
  gsub(/^[ \t]+|[ \t]+$/, "", value); 
  print key "," value 
}' "$OUTPUT_FILE_YAML" >> "$OUTPUT_FILE_CSV"

if [[ $? -eq 0 ]]; then
  echo "CSV successfully created at '$OUTPUT_FILE_CSV'."
else
  echo "Error: Failed to convert YAML to CSV."
fi

# Optional: Clean up temporary YAML file
rm -f "$TEMP_DEPLOYMENT_YAML"






