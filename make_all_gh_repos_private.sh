#!/bin/bash

# Function to check for required tools
check_tools() {
  required_tools=("gh" "jq")
  for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null && [[ ! -x "$tool" ]]; then
      echo "Error: $tool is not installed, not in your PATH, or not executable."
      exit 1
    fi
  done
}

# Step 1: Ensure required tools are installed
check_tools

# Step 2: Fetch all public repositories
echo "Fetching all public repositories..."
public_repos=$(gh api graphql -f query='
query {
  viewer {
    repositories(first: 100, privacy: PUBLIC, isFork: false) {
      nodes {
        name
        owner {
          login
        }
        url
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}' | jq -c '.data.viewer.repositories.nodes[]')

if [ -z "$public_repos" ]; then
  echo "No public repositories found or failed to fetch repositories."
  exit 0
fi

# Step 3: Iterate over the repositories and prompt for each one
echo "Processing repositories..."
for repo in $public_repos; do
  repo_url=$(echo "$repo" | jq -r '.url')

  # Call the existing make_repo_private.sh script for each repository
  ./make_gh_repo_private.sh "$repo_url"
done

echo "Finished processing repositories."
