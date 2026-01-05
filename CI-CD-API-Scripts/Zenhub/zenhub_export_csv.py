import requests
import csv
import os

# Replace with your Zenhub personal access token
personal_access_token = "Your_Token_Here"

# Replace with the ID of your workspace
workspace_id = "Workspace_ID_Here"

# Output filenames - Replace with your desired filenames
open_issues_filename = "workspace_name_open_issues.csv"
closed_issues_filename = "workspace_name_closed_issues.csv"

# GraphQL endpoint URL
graphql_url = "https://DOMAIN_NAME/public/graphql"

query = """
query getBoardInfoForWorkspace($workspaceId: ID!, $after: String) {
  workspace(id: $workspaceId) {
    id
    name
    pipelinesConnection(first: 25) {
      nodes {
        id
        name
        issues(first: 100, after: $after) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            id
            title
            number
            body
            state
            estimate {
              value
            }
            labels(first: 25) {
              nodes {
                name
              }
            }
          }
        }
      }
    }
  }
}
"""


# Set headers with authorization token
headers = {"Authorization": f"Bearer {personal_access_token}"}



# Function to write data to CSV file
def write_to_csv(data, filename):
  with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
    fieldnames = ["Pipeline ID", "Pipeline Name", "Issue ID", "Issue Title", "Issue Number", "Issue Body", "Issue State", "Estimate", "Labels"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    for row in data:
      writer.writerow(row)

# Function to fetch all issues with pagination
def fetch_all_issues():
  all_issues = []
  pipelines_fetched = 0
  response = requests.post(graphql_url, json={"query": query, "variables": {"workspaceId": workspace_id}}, headers=headers)
  data = response.json()
  if 'errors' in data:
    print("Errors in response:", data['errors'])
    return []
  for pipeline in data['data']['workspace']['pipelinesConnection']['nodes']:
    pipelines_fetched += 1
    has_next_page = True
    after = None
    while has_next_page:
      variables = {"workspaceId": workspace_id, "after": after}
      response = requests.post(graphql_url, json={"query": query, "variables": variables}, headers=headers)
      data = response.json()
      if 'errors' in data:
        print("Errors in response:", data['errors'])
        return []
      pipeline_data = next(p for p in data['data']['workspace']['pipelinesConnection']['nodes'] if p['id'] == pipeline['id'])
      issues = pipeline_data['issues']
      for issue in issues['nodes']:
        issue_data = {
          "Pipeline ID": pipeline['id'],
          "Pipeline Name": pipeline['name'],
          "Issue ID": issue['id'],
          "Issue Title": issue['title'],
          "Issue Number": issue['number'],
          "Issue Body": issue['body'],
          "Issue State": issue['state'],
          "Estimate": issue['estimate']['value'] if issue['estimate'] else None,
          "Labels": ", ".join([label['name'] for label in issue['labels']['nodes']])
        }
        all_issues.append(issue_data)
      has_next_page = issues['pageInfo']['hasNextPage']
      after = issues['pageInfo']['endCursor']
      print(f"Pipeline {pipeline['name']} - Fetched {len(issues['nodes'])} issues, has_next_page: {has_next_page}, after: {after}")
  print(f"Total pipelines fetched: {pipelines_fetched}")
  return all_issues

# Fetch all issues
all_issues = fetch_all_issues()

# Separate open and closed issues
open_issues = [issue for issue in all_issues if issue['Issue State'] == 'OPEN']
closed_issues = [issue for issue in all_issues if issue['Issue State'] == 'CLOSED']

# Write open issues to CSV file
write_to_csv(open_issues, open_issues_filename)

# Write closed issues to CSV file
write_to_csv(closed_issues, closed_issues_filename)

print(f"Data exported to {open_issues_filename} and {closed_issues_filename}")
