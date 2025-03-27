#!/bin/bash

set -e

# Inputs
REPO_OWNER="$1"
REPO_NAME="$2"
SECRET_NAME="MY_SECRET"
SECRET_VALUE="super_secret_value"
GITHUB_TOKEN="$3"

if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) is not installed. Please install it to configure repo settings."
  exit 1
fi

echo "⚙️ Configuring repository settings via GitHub CLI..."

gh api "repos/${REPO_OWNER}/${REPO_NAME}" \
  --method PATCH \
  --silent \
  --field allow_auto_merge=true \
  --field allow_merge_commit=false \
  --field allow_rebase_merge=false \
  --field allow_squash_merge=true \
  --field delete_branch_on_merge=true \
  --field has_issues=true \
  --field has_projects=false \
  --field has_wiki=false \
  --field squash_merge_commit_message=PR_BODY \
  --field squash_merge_commit_title=PR_TITLE

echo "✅ Repository configuration applied."
