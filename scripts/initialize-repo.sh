#!/bin/bash

set -e

# Inputs
REPO_OWNER="$1"
REPO_NAME="$2"
GITHUB_TOKEN="$3"
DATOCMS_DRAFT="$4"
DATOCMS_PUBLISHED="$5"
DATOCMS_CMA="$6"
SITE_URL="$7"

# Make GH token available to gh CLI
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

# Helper function to set both repo + dependabot secrets
set_secret() {
  local secret_name=$1
  local secret_value=$2

  echo "🔐 Setting repository secret: $secret_name"
  gh secret set "$secret_name" --body "$secret_value" --repo "$REPO_OWNER/$REPO_NAME"

  echo "🤖 Setting Dependabot secret: $secret_name"
  gh secret set "$secret_name" --body "$secret_value" --repo "$REPO_OWNER/$REPO_NAME" --app dependabot
}

set_secret DATOCMS_DRAFT_CONTENT_CDA_TOKEN "$DATOCMS_DRAFT"
set_secret DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN "$DATOCMS_PUBLISHED"
set_secret DATOCMS_CMA_TOKEN "$DATOCMS_CMA"
set_secret SITE_URL "$SITE_URL"

echo "✅ All secrets set successfully."