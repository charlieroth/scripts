#!/bin/bash

# Function to check for required tools
check_tools() {
  required_tools=("gh" "awk")
  for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
      echo "Error: $tool is not installed or not in your PATH."
      exit 1
    fi
  done
}

# Step 1: Ensure required tools are installed
check_tools

# Step 2: Check if a URL is passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <repository_url>"
  exit 1
fi

# Step 3: Extract repository owner and name from the URL
repo_url="$1"
repo_owner=$(echo "$repo_url" | awk -F '/' '{print $(NF-1)}')
repo_name=$(echo "$repo_url" | awk -F '/' '{print $NF}')

# Step 4: Validate extracted values
if [ -z "$repo_owner" ] || [ -z "$repo_name" ]; then
  echo "Invalid repository URL. Please provide a valid GitHub repository URL."
  exit 1
fi

# Step 5: Confirm with the user before making the repository private
echo "Repository: $repo_name (Owner: $repo_owner)"
read -p "Do you want to make this repository private? (y/n): " choice

# Step 6: Execute `gh repo edit` to make the repository private
if [[ $choice == "y" ]]; then
  echo "Making $repo_name private..."
  gh repo edit "$repo_owner/$repo_name" --visibility private --accept-visibility-change-consequences
  if [ $? -eq 0 ]; then
    echo "$repo_name has been successfully made private."
  else
    echo "Failed to update repository visibility. Ensure you have the necessary permissions."
  fi
else
  echo "$repo_name remains public."
fi
