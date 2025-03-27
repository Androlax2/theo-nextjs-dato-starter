#!/bin/bash

set -e

# Inputs
REPO_OWNER="$1"
REPO_NAME="$2"
GITHUB_TOKEN="$3"
ENV_STRING_RAW="$4"
WEBSITE_URL="$5"

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
  --field squash_merge_commit_title=PR_TITLE \
  --field homepage="$WEBSITE_URL"

echo "✅ Repository configuration applied."

# Declare expected secret keys
declare -A expected_keys=(
  [DATOCMS_DRAFT_CONTENT_CDA_TOKEN]=1
  [DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN]=1
  [DATOCMS_CMA_TOKEN]=1
  [SITE_URL]=1
)

# Normalize input string: convert spaces to newlines, remove comments
env_lines=$(echo "$ENV_STRING_RAW" | tr ' ' '\n' | grep -E '^[A-Z_]+=.*')

echo "🔐 Setting expected secrets..."

while IFS='=' read -r raw_key raw_value; do
  key=$(echo "$raw_key" | xargs)
  value=$(echo "$raw_value" | xargs)

  [[ -z "$key" || -z "$value" ]] && continue
  [[ -z "${expected_keys[$key]}" ]] && continue

  echo "::add-mask::$value"
  echo "→ Setting secret: $key = [REDACTED]"

  gh secret set "$key" --body "$value" --repo "$REPO_OWNER/$REPO_NAME"
  gh secret set "$key" --body "$value" --repo "$REPO_OWNER/$REPO_NAME" --app dependabot

done <<< "$env_lines"

echo "✅ Secrets applied."

# Fetch DatoCMS admin URL
echo "🌐 Querying DatoCMS for project info..."

admin_url=""
if [[ -n "${expected_keys[DATOCMS_CMA_TOKEN]}" ]]; then
  project_info=$(curl -s -H "Authorization: Bearer $DATOCMS_CMA_TOKEN" https://site-api.datocms.com/site)

  # Try to validate it
  if echo "$project_info" | jq -e '.data.id' &>/dev/null; then
    project_id=$(echo "$project_info" | jq -r '.data.id')
    admin_url="https://dashboard.datocms.com/projects/$project_id"
    echo "📎 Found DatoCMS admin URL: $admin_url"

    gh api "repos/${REPO_OWNER}/${REPO_NAME}" \
      --method PATCH \
      --silent \
      --field homepage="$admin_url"
  else
    echo "⚠️ Failed to retrieve DatoCMS project ID. Full response:"
    echo "$project_info" | jq
  fi
else
  echo "⚠️ No CMA token provided, skipping DatoCMS project lookup"
fi