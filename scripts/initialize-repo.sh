#!/bin/bash

set -e

# Git identity (before any commits!)
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Inputs
REPO_OWNER="$1"
REPO_NAME="$2"
GITHUB_TOKEN="$3"
ENV_STRING_RAW="$4"
WEBSITE_URL="$5"

# Auto-commit changes
GIT_BRANCH="test-init-repo-auto-update"
export GH_TOKEN="$GITHUB_TOKEN"

function check_gh_cli_installed() {
  if ! command -v gh &> /dev/null; then
    echo "\n❌ GitHub CLI (gh) is not installed."
    exit 1
  fi
}

function configure_repository_settings() {
  echo "\n⚙️ Configuring repository settings via GitHub CLI..."
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
}

function set_secrets() {
  echo "\n🔐 Setting expected secrets..."

  declare -A expected_keys=(
    [DATOCMS_DRAFT_CONTENT_CDA_TOKEN]=1
    [DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN]=1
    [DATOCMS_CMA_TOKEN]=1
    [SITE_URL]=1
  )

  DATOCMS_CMA_TOKEN_EXTRACTED=""

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
}

function update_readme_with_datocms_url() {
  echo "\n🌐 Querying DatoCMS for project info..."

  if [[ -n "$DATOCMS_CMA_TOKEN_EXTRACTED" ]]; then
    project_info=$(curl -s \
      -H "Authorization: Bearer $DATOCMS_CMA_TOKEN_EXTRACTED" \
      -H "Accept: application/vnd.api+json" \
      -H "Content-Type: application/vnd.api+json" \
      -H "X-Api-Version: 3" \
      https://site-api.datocms.com/site)

    internal_domain=$(echo "$project_info" | jq -r '.data.attributes.internal_domain')
    if [[ "$internal_domain" != "null" ]]; then
      actual_url="https://$internal_domain"
      echo "📎 Found internal DatoCMS admin domain: $actual_url"

      if [[ -f "README.md" ]]; then
        echo "✏️ Replacing fake DatoCMS URL with real one: $actual_url"
        sed -i.bak "s|https://your-datocms-project.admin.datocms.com|$actual_url|g" README.md
        rm README.md.bak

        git add README.md
        git commit -m "docs(readme): inject DatoCMS admin URL"
      fi
    fi
  else
    echo "⚠️ No DATOCMS_CMA_TOKEN found in env_file input"
  fi
}

function ensure_working_branch() {
  echo "\n🔀 Preparing working branch..."
  ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  git fetch origin
  git checkout -b "$GIT_BRANCH" origin/main || git checkout -b "$GIT_BRANCH"
}

function ensure_gh_pages_branch() {
  if ! git ls-remote --exit-code origin gh-pages &>/dev/null; then
    echo "\n🔧 Creating gh-pages branch (empty)"

    git checkout --orphan gh-pages
    git reset --hard

    echo "# GitHub Pages placeholder" > index.html
    git add index.html
    git commit -m "chore: initialize gh-pages branch"
    git push origin gh-pages

    git checkout "$GIT_BRANCH"
  fi
}

function enable_github_pages() {
  echo "\n📘 Enabling GitHub Pages..."

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

  echo "✅ GitHub Pages is now configured for branch gh-pages"
}

function update_readme_with_storybook_url() {
  echo "\n📗 Updating README with Storybook URL..."
  PAGES_URL="https://${REPO_OWNER}.github.io/${REPO_NAME}"

  if [[ -f "README.md" ]]; then
    echo "✏️ Replacing placeholder Storybook URL in README.md with: $PAGES_URL"
    sed -i.bak "s|https://your-storybook-url.com|$PAGES_URL|g" README.md
    rm -f README.md.bak

    git add README.md
    git commit -m "docs(readme): insert GitHub Pages Storybook link"
  fi
}

function final_push() {
  echo "\n📤 Pushing to branch $GIT_BRANCH..."

  if [[ -n $(git log origin/"$GIT_BRANCH"..HEAD) ]]; then
    git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${REPO_OWNER}/${REPO_NAME}.git"
    git push origin "$GIT_BRANCH"
    echo "✅ All changes pushed to branch '$GIT_BRANCH'"
  else
    echo "ℹ️ No new commits to push."
  fi
}

# Run all steps
check_gh_cli_installed
configure_repository_settings
set_secrets
update_readme_with_datocms_url
ensure_working_branch
ensure_gh_pages_branch
enable_github_pages
update_readme_with_storybook_url
final_push
