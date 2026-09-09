#!/usr/bin/env bash

set -euo pipefail

CSV_FILE="repos.csv"
GH_PAT="${GH_PAT:-}"
API_URL="${TARGET_API_URL:-}"

if [[ -z "$GH_PAT" ]]; then
  echo "ERROR: GH_PAT environment variable is not set."
  exit 1
fi

if [[ -z "$API_URL" ]]; then
  echo "ERROR: TARGET_API_URL environment variable is not set. eg: https://api.github.com or https://api.SUBDOMAIN.com"
  exit 1
fi

tail -n +2 "$CSV_FILE" | while IFS=',' read -r \
org teamproject repo github_org github_repo gh_repo_visibility team_name
do

  # Skip empty rows
  [[ -z "${github_org// }" ]] && continue
  [[ -z "${github_repo// }" ]] && continue
  [[ -z "${team_name// }" ]] && continue

  echo "--------------------------------------------------"
  echo "Processing Repo: $github_org/$github_repo"

  # Multiple teams separated by |
  IFS='|' read -ra TEAMS <<< "$team_name"

  for team in "${TEAMS[@]}"
  do

    # Trim spaces
    team=$(echo "$team" | xargs)

    [[ -z "$team" ]] && continue

    echo "Target Team    : $team"

    # Convert team name to GitHub slug
    team_slug=$(echo "$team" \
      | tr '[:upper:]' '[:lower:]' \
      | sed 's/ /-/g')

    echo "Team Slug      : $team_slug"

    response=$(curl -s -o /tmp/gh_response.txt -w "%{http_code}" \
      -X PUT \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer $GH_PAT" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "$API_URL/orgs/$github_org/teams/$team_slug/repos/$github_org/$github_repo" \
      -d '{
        "permission":"push"
      }')

    if [[ "$response" == "204" ]]; then
      echo "SUCCESS: Added repo to team: $team"
    else
      echo "FAILED: Team $team -> HTTP $response"
      cat /tmp/gh_response.txt
    fi

    echo

  done

done
