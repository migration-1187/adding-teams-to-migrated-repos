# Adding Teams to Migrated Repos

A shell script utility to automatically add GitHub teams to migrated repositories with the specified permissions.

## Overview

This repository contains a bash script that processes a CSV file containing repository and team information, then uses the GitHub API to add teams to repositories with push access permissions.

## Prerequisites

- **Bash** (version 4.0+)
- **curl** - for making HTTP requests to the GitHub API
- **GitHub Personal Access Token (PAT)** - with appropriate permissions to manage teams and repositories
- **GitHub Organization Admin Access** - to add teams to repositories

## Environment Variables

Before running the script, set the following environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `GH_PAT` | GitHub Personal Access Token for API authentication | `ghp_xxxxxxxxxxxxxxxxxxxx` |
| `TARGET_API_URL` | GitHub API base URL | `https://api.github.com` (GitHub.com) or `https://api.SUBDOMAIN.com` (GHES) |

### Setting Environment Variables

```bash
export GH_PAT="your_github_personal_access_token"
export TARGET_API_URL="https://api.github.com"
```

## CSV File Format

The input CSV file (`repos.csv`) should contain the following columns:

| Column | Description | Example |
|--------|-------------|---------|
| `org` | Source organization (e.g., ADO org name) | `v-biradarm` |
| `teamproject` | Team project from source system | `TestRepo2` |
| `repo` | Repository name | `fixpipelineTag` |
| `github_org` | GitHub organization name | `ADO-migration-test` |
| `github_repo` | GitHub repository name | `fixpipelineTag` |
| `gh_repo_visibility` | Repository visibility | `private` or `public` |
| `team_name` | Team name(s) to add (pipe-separated for multiple) | `team-testing\|team-2\|team-3` |

### Example CSV:

```csv
org,teamproject,repo,github_org,github_repo,gh_repo_visibility,team-name
v-biradarm,TestRepo2,fixpipelineTag,ADO-migration-test,fixpipelineTag,private,team-testing|team-2|team-3
```

**Note:** Multiple teams can be specified using the pipe (`|`) character as a delimiter.

## Usage

1. **Prepare the CSV file** with the repositories and teams to be added.

2. **Set environment variables:**
   ```bash
   export GH_PAT="your_github_pat"
   export TARGET_API_URL="https://api.github.com"
   ```

3. **Run the script:**
   ```bash
   ./repos-to-teams.sh
   ```

## How It Works

1. Reads the CSV file line by line (skipping the header row)
2. Validates required fields (`github_org`, `github_repo`, `team_name`)
3. For each team in the `team_name` field:
   - Converts the team name to a GitHub-compatible slug (lowercase, spaces to hyphens)
   - Makes a PUT request to the GitHub API to add the team to the repository
   - Sets permissions to `push` access
   - Displays success or failure messages with HTTP status codes

## Output

The script provides detailed output for each repository processed:

```
--------------------------------------------------
Processing Repo: ADO-migration-test/fixpipelineTag
Target Team    : team-testing
Team Slug      : team-testing
SUCCESS: Added repo to team: team-testing

Target Team    : team-2
Team Slug      : team-2
SUCCESS: Added repo to team: team-2
```

## Error Handling

- **Missing GH_PAT:** Script exits if the GitHub Personal Access Token is not set
- **Missing TARGET_API_URL:** Script exits if the API URL is not provided
- **Empty rows:** Rows with missing critical fields are skipped
- **API failures:** HTTP errors are displayed with response details

## GitHub API Endpoint

The script uses the GitHub API endpoint:

```
PUT /orgs/{org}/teams/{team_slug}/repos/{org}/{repo}
```

- **Permission:** `push` - Allows team members to push to the repository
- **API Version:** `2022-11-28`

## Security Considerations

- **Protect your GitHub PAT:** Never commit your token to version control
- **Use a secure method** to store and pass environment variables (e.g., GitHub Secrets, vault systems)
- **Limit PAT scope:** Grant only necessary permissions to the token
- **Audit access:** Monitor team access to repositories

## Troubleshooting

### Script not executing
```bash
chmod +x repos-to-teams.sh
```

### "GH_PAT environment variable is not set"
Ensure the environment variable is exported before running the script.

### "TARGET_API_URL environment variable is not set"
Provide the GitHub API URL (e.g., `https://api.github.com` or your GHES instance URL).

### API errors (HTTP 401, 403)
- Verify your GitHub PAT has the required permissions
- Ensure you have organization admin access
- Check that the token has not expired

### Team not found (HTTP 404)
- Verify the team exists in the GitHub organization
- Confirm the team slug is correct
- Check team name formatting

## Contributing

For issues or improvements, please create an issue or pull request in this repository.

## License

This project is provided as-is for GitHub repository management purposes.
