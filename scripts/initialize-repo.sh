#!/bin/bash

set -e

# Inputs
REPO_OWNER="$1"
REPO_NAME="$2"
GITHUB_TOKEN="$3"
ENV_FILE_STRING="$4"

# Export token for gh CLI
export GH_TOKEN="$GITHUB_TOKEN"

if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) is not installed."
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

# Parse .env string into secrets
echo "🔐 Parsing provided .env content..."
while IFS='=' read -r key value; do
  # Skip comments and empty lines
  [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue

  # Remove possible surrounding quotes
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | sed -e 's/^["'\'']//;s/["'\'']$//' | xargs)

  echo "→ Setting secret: $key"

  gh secret set "$key" --body "$value" --repo "$REPO_OWNER/$REPO_NAME"
  gh secret set "$key" --body "$value" --repo "$REPO_OWNER/$REPO_NAME" --app dependabot
done <<< "$ENV_FILE_STRING"

echo "✅ All secrets set successfully from .env."