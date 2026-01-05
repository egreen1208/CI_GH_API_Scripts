import csv
import json


def json_to_csv(json_data, csv_file):
  """
  Converts a JSON object to a CSV file.

  Args:
      json_data: A dictionary or list containing the JSON data.
      csv_file: The path to the output CSV file.
  """
  # Open the CSV file in write mode
  with open(csv_file, 'w', newline='') as csvfile:
    # Create a CSV writer object
    csv_writer = csv.writer(csvfile)

    # Get the keys from the first JSON object (assuming consistent structure)
    headers = list(json_data[0].keys())
    # Write the header row to the CSV file
    csv_writer.writerow(headers)

    # Iterate through each JSON object and write data to a row
    for item in json_data:
      row = [item[key] for key in headers]
      csv_writer.writerow(row)


# Example usage
# Replace 'your_data.json' with the path to your JSON file
# Replace 'output.csv' with the desired name for the output CSV file
json_file = 'artifactory_users.json'
csv_file = 'artifactory_users.csv'

with open(json_file, 'r') as f:
  json_data = json.load(f)

json_to_csv(json_data, csv_file)

print(f"JSON data converted to CSV and saved to: {csv_file}")
