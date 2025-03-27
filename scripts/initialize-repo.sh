#!/bin/bash

set -e

# Inputs
REPO_OWNER="$1"
REPO_NAME="$2"
GITHUB_TOKEN="$3"
ENV_STRING_RAW="$4"
WEBSITE_URL="$5"

# Auto-commit changes 
# TODO: Put main when it's done
GIT_BRANCH="test-init-repo-auto-update"

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

echo "🔐 Setting expected secrets..."

DATOCMS_CMA_TOKEN_EXTRACTED=""

# Normalize and parse .env string: space-separated or newline-separated
env_lines=$(echo "$ENV_STRING_RAW" | tr ' ' '\n' | grep -E '^[A-Z_]+=.*')

while IFS='=' read -r raw_key raw_value; do
  key=$(echo "$raw_key" | xargs)
  value=$(echo "$raw_value" | xargs)

  [[ -z "$key" || -z "$value" ]] && continue
  [[ -z "${expected_keys[$key]}" ]] && continue

  echo "::add-mask::$value"
  echo "→ Setting secret: $key = [REDACTED]"

  gh secret set "$key" --body "$value" --repo "$REPO_OWNER/$REPO_NAME"
  gh secret set "$key" --body "$value" --repo "$REPO_OWNER/$REPO_NAME" --app dependabot

  if [[ "$key" == "DATOCMS_CMA_TOKEN" ]]; then
    DATOCMS_CMA_TOKEN_EXTRACTED="$value"
  fi
done <<< "$env_lines"

echo "✅ Secrets applied."

# Fetch DatoCMS admin URL and update homepage
echo "🌐 Querying DatoCMS for project info..."

admin_url=""
if [[ -n "$DATOCMS_CMA_TOKEN_EXTRACTED" ]]; then
  project_info=$(curl -s \
  -H "Authorization: Bearer $DATOCMS_CMA_TOKEN_EXTRACTED" \
  -H "Accept: application/vnd.api+json" \
  -H "Content-Type: application/vnd.api+json" \
  -H "X-Api-Version: 3" \
  https://site-api.datocms.com/site)

  # Extract DatoCMS internal domain and update README.md
  internal_domain=$(echo "$project_info" | jq -r '.data.attributes.internal_domain')
  if [[ "$internal_domain" != "null" ]]; then
    admin_url="https://$internal_domain"
    echo "📎 Found internal DatoCMS admin domain: $admin_url"

    # Replace fake DatoCMS URL in README.md
    if [[ -f "README.md" && -n "$internal_domain" ]]; then
      actual_url="https://$internal_domain"
      echo "✏️ Replacing fake DatoCMS URL with real one: $actual_url"

      sed -i.bak "s|https://your-datocms-project.admin.datocms.com|$actual_url|g" README.md
      rm README.md.bak
    else
      echo "⚠️ README.md not found or DatoCMS domain missing — skipping link replacement."
    fi
  fi
else
  echo "⚠️ No DATOCMS_CMA_TOKEN found in env_file input"
fi

# === Enable GitHub Pages ===
echo "📘 Enabling GitHub Pages..."

gh api "repos/${REPO_OWNER}/${REPO_NAME}/pages" \
  --method PUT \
  --silent \
  --input - <<EOF
{
  "source": {
    "branch": "gh-pages",
    "path": "/"
  }
}
EOF

echo "✅ GitHub Pages enabled for branch gh-pages"

# === Inject Storybook URL into README ===
PAGES_URL="https://${REPO_OWNER}.github.io/${REPO_NAME}"

if [[ -f "README.md" ]]; then
  echo "✏️ Replacing placeholder Storybook URL in README.md with: $PAGES_URL"
  sed -i.bak "s|https://your-storybook-url.com|$PAGES_URL|g" README.md
  rm -f README.md.bak
fi

# === Commit the changes ===
echo "📦 Preparing to commit and push changes to branch: $GIT_BRANCH"

git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"

git checkout -b "$GIT_BRANCH"

# Check for changes in the working directory
if [[ -n $(git status --porcelain) ]]; then
  git add .
  git commit -m "chore: initialize project configuration"

  git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${REPO_OWNER}/${REPO_NAME}.git"
  git push origin "$GIT_BRANCH"

  echo "✅ Changes pushed to branch '$GIT_BRANCH'"
else
  echo "ℹ️ No changes to commit — skipping push."
fi