import csv
import json

# Below, you will provide the csv you are converting and create a name for output json file.
csv_file_path = '<your_input.csv>'
json_file_path = '<your_output.json>'

data = []

with open(csv_file_path, 'r', encoding='utf-8') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        data.append(row)

with open(json_file_path, 'w', encoding='utf-8') as json_file:
    json.dump(data, json_file, indent=2, ensure_ascii=False)

print("Conversion complete.")