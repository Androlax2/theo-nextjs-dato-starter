#!/bin/bash

set -e

echo ""
echo "🚀 Initializing Vercel + GitHub + DatoCMS project"
echo "-----------------------------------------------"

##############################
# 🔧 Utility Functions
##############################

generate_secret_token() {
  echo "🔐 Generating secret token..."
  SECRET_TOKEN=$(openssl rand -hex 32)
  echo "✅ Generated secret token: $SECRET_TOKEN"
}

ensure_vercel_cli_installed() {
  echo ""
  echo "🔍 Checking for Vercel CLI..."
  if ! command -v vercel &> /dev/null; then
    echo "⚠️  Vercel CLI not found. Installing it globally using npm..."
    npm install -g vercel
    if command -v vercel &> /dev/null; then
      echo "✅ Vercel CLI installed successfully."
    else
      echo "❌ Failed to install Vercel CLI. Please install it manually and rerun this script."
      exit 1
    fi
  else
    echo "✅ Vercel CLI is already installed."
  fi
}

link_vercel_project() {
  echo ""
  echo "🔗 Checking if project is already linked to Vercel..."

  if [ -f ".vercel/project.json" ]; then
    PROJECT_ID=$(jq -r '.projectId' .vercel/project.json 2>/dev/null)

    if [[ -n "$PROJECT_ID" && "$PROJECT_ID" != "null" ]]; then
      echo "✅ Project is already linked to Vercel (projectId: $PROJECT_ID)"
      return
    fi
  fi

  echo "🔗 Project not linked. Running vercel link..."
  vercel link
}

get_vercel_site_url() {
  echo ""
  echo "🌐 Getting latest production deployment..."
  DEPLOYMENT_URL=$(vercel ls --prod | grep -m1 -Eo 'https://[a-z0-9\-]+\.vercel\.app')

  if [ -z "$DEPLOYMENT_URL" ]; then
    echo "❌ Could not find a recent production deployment. Deploy your project first."
    exit 1
  fi

  PROJECT_NAME=$(echo "$DEPLOYMENT_URL" | sed -E 's|https://([a-z0-9\-]+)-[a-z0-9]+-[a-z0-9]+\.vercel\.app|\1|')
  [ -z "$PROJECT_NAME" ] && PROJECT_NAME=$(basename "$DEPLOYMENT_URL" | cut -d. -f1)

  SITE_URL="https://${PROJECT_NAME}.vercel.app"

  echo "✅ Detected project name: $PROJECT_NAME"
  echo "✅ SITE_URL: $SITE_URL"
}

set_vercel_env_variables() {
  echo ""
  echo "📦 Setting Vercel environment variables..."

  vercel env rm SITE_URL --yes || true
  echo "$SITE_URL" | vercel env add SITE_URL production

  vercel env rm SECRET_API_TOKEN --yes || true
  echo "$SECRET_TOKEN" | vercel env add SECRET_API_TOKEN production
}

fetch_and_write_datocms_tokens_to_env() {
  echo ""
  echo "🔑 Fetching DatoCMS API tokens from /access_tokens..."

  tokens_response=$(curl -s -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/json" \
    -H "X-Api-Version: 3" \
    https://site-api.datocms.com/access_tokens)

  DRAFT_TOKEN=$(echo "$tokens_response" | jq -r '.data[] | select(.attributes.name == "CDA Only (Draft)") | .attributes.token')
  PUBLISHED_TOKEN=$(echo "$tokens_response" | jq -r '.data[] | select(.attributes.name == "CDA Only (Published)") | .attributes.token')
  CMA_TOKEN="$DATOCMS_CMA_TOKEN"

  if [[ -z "$DRAFT_TOKEN" || -z "$PUBLISHED_TOKEN" ]]; then
    echo ""
    echo "❌ Missing one or more expected tokens:"
    echo "   - CDA Only (Draft)"
    echo "   - CDA Only (Published)"
    echo ""
    echo "👉 Make sure these exist in your DatoCMS project under API Tokens."
    exit 1
  fi

  echo "✅ Retrieved tokens from DatoCMS."

  echo ""
  echo "📝 Writing environment variables to .env.local..."

  cp .env.local.example .env.local

  sed -i '' -e "s|^DATOCMS_DRAFT_CONTENT_CDA_TOKEN=.*|DATOCMS_DRAFT_CONTENT_CDA_TOKEN=$DRAFT_TOKEN|" .env.local
  sed -i '' -e "s|^DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN=.*|DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN=$PUBLISHED_TOKEN|" .env.local
  sed -i '' -e "s|^DATOCMS_CMA_TOKEN=.*|DATOCMS_CMA_TOKEN=$CMA_TOKEN|" .env.local
  sed -i '' -e "s|^SECRET_API_TOKEN=.*|SECRET_API_TOKEN=$SECRET_TOKEN|" .env.local

  echo "✅ .env.local updated successfully."
}

set_datocms_tokens_on_vercel() {
  echo ""
  echo "☁️ Syncing DatoCMS tokens to Vercel (skipping if already set)..."

  vercel_env_list=$(vercel env ls 2>/dev/null)

  for token_var in \
    DATOCMS_DRAFT_CONTENT_CDA_TOKEN \
    DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN \
    DATOCMS_CMA_TOKEN
  do
    value=$(grep "^$token_var=" .env.local | cut -d '=' -f2-)

    if [[ -z "$value" ]]; then
      echo "❌ Missing value for $token_var in .env.local — skipping."
      continue
    fi

    if echo "$vercel_env_list" | grep -q "$token_var"; then
      echo "⚠️  $token_var already exists — skipping."
      continue
    fi

    for env in production preview development; do
      echo "➕ Adding $token_var to $env..."
      if echo "$value" | vercel env add "$token_var" "$env" > /dev/null 2>&1; then
        echo "✅  Added $token_var to $env"
      else
        echo "❌ Failed to add $token_var to $env"
      fi
    done
  done

  echo "✅ DatoCMS tokens sync complete."
}

prompt_datocms_token() {
  echo ""
  echo "📁 Enter your DatoCMS CMA token (DATOCMS_CMA_TOKEN):"
  echo "---------------------------------------------------"
  echo "You can find it in your DatoCMS project:"
  echo "Go to → Project Settings → API tokens → 'CMA Only (Admin)'"
  echo ""
  read -rsp "🔐 Paste DATOCMS_CMA_TOKEN here: " DATOCMS_CMA_TOKEN
  echo ""

  if [ -z "$DATOCMS_CMA_TOKEN" ]; then
    echo "❌ No token entered. Aborting."
    exit 1
  fi
}

fetch_datocms_plugin_data() {
  PLUGIN_LIST=$(curl -s -X GET "https://site-api.datocms.com/plugins" \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/json" \
    -H "X-Api-Version: 3")

  WEBHOOK_LIST=$(curl -s -X GET "https://site-api.datocms.com/webhooks" \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/json" \
    -H "X-Api-Version: 3")
}

install_or_update_plugin() {
  local PACKAGE_NAME="$1"
  local PAYLOAD_JSON="$2"
  local PRETTY_NAME="$3"

  echo ""
  echo "🔄 Installing or updating DatoCMS plugin: $PRETTY_NAME..."

  PLUGIN_ID=$(echo "$PLUGIN_LIST" | jq -r --arg name "$PACKAGE_NAME" '.data[] | select(.attributes.package_name == $name) | .id')

  if [ -z "$PLUGIN_ID" ] || [[ "$PLUGIN_ID" == "null" ]]; then
    echo "⚠️  Plugin '$PACKAGE_NAME' not found — installing..."

    plugin_create_response=$(curl -s -w "%{http_code}" -o /tmp/plugin_create.json \
      -X POST "https://site-api.datocms.com/plugins" \
      -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
      -H "Accept: application/vnd.api+json" \
      -H "Content-Type: application/vnd.api+json" \
      -H "X-Api-Version: 3" \
      -d @- <<EOF
{
  "data": {
    "type": "plugin",
    "attributes": {
      "package_name": "$PACKAGE_NAME"
    }
  }
}
EOF
    )

    if [[ "$plugin_create_response" == "201" ]]; then
      PLUGIN_ID=$(cat /tmp/plugin_create.json | jq -r '.data.id')
      echo "✅ Plugin installed (ID: $PLUGIN_ID)"
    else
      echo "❌ Failed to install plugin '$PACKAGE_NAME'. Response:"
      cat /tmp/plugin_create.json | jq .
      return
    fi
  else
    echo "✅ Plugin '$PACKAGE_NAME' already exists (ID: $PLUGIN_ID)"
  fi

  echo "🔧 Updating plugin parameters..."
  plugin_update_response=$(curl -s -w "%{http_code}" -o /tmp/plugin_update.json \
    -X PATCH "https://site-api.datocms.com/plugins/${PLUGIN_ID}" \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/vnd.api+json" \
    -H "Content-Type: application/vnd.api+json" \
    -H "X-Api-Version: 3" \
    -d "$PAYLOAD_JSON"
  )

  if [[ "$plugin_update_response" == "200" ]]; then
    echo "✅ Plugin '$PRETTY_NAME' updated successfully."
  else
    echo "❌ Failed to update plugin '$PRETTY_NAME'. Response:"
    cat /tmp/plugin_update.json | jq .
  fi
}

function update_readme_urls() {
  echo "🌐 Updating README URLs..."

  if [[ -f "README.md" ]]; then
    # Project title replacement
    sed -i.bak "s/# \[__PROJECT_TITLE__\]/# ${PROJECT_NAME}/g" README.md

    # DatoCMS URL replacement
    if [[ -n "$DATOCMS_CMA_TOKEN" ]]; then
      if [[ "$INTERNAL_DOMAIN" != "null" && -n "$INTERNAL_DOMAIN" ]]; then
        actual_datocms_url="https://$INTERNAL_DOMAIN"
        sed -i.bak "s|https://your-datocms-project.admin.datocms.com|$actual_datocms_url|g" README.md
      fi
    else
      sed -i.bak "s|https://your-datocms-project.admin.datocms.com|https://placeholder-datocms-url.admin.datocms.com|g" README.md
    fi

    # Storybook URL replacement (only if GitHub integration is enabled)
    if [[ "$SKIP_GITHUB" != true ]]; then
      PAGES_URL="https://${REPO_OWNER}.github.io/${REPO_NAME}"
      sed -i.bak "s|https://your-storybook-url.com|$PAGES_URL|g" README.md
    fi

    rm -f README.md.bak
    git add README.md
  fi
}

update_webhook() {
  echo ""
  echo "🔄 Updating DatoCMS webhook URL with secret token..."
  WEBHOOK_URL="${SITE_URL}/api/invalidate-cache?token=${SECRET_TOKEN}"

  WEBHOOK_ID=$(echo "$WEBHOOK_LIST" | jq -r '.data[] | select(.attributes.name == "🔄 Invalidate Next.js Cache") | .id')

  if [ -z "$WEBHOOK_ID" ]; then
    echo "⚠️  Webhook not found, creating it..."

    webhook_create_response=$(curl -s -w "%{http_code}" -o /tmp/webhook_response.json \
      -X POST "https://site-api.datocms.com/webhooks" \
      -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
      -H "Accept: application/vnd.api+json" \
      -H "Content-Type: application/vnd.api+json" \
      -H "X-Api-Version: 3" \
      -d @- <<EOF
    {
      "data": {
        "type": "webhook",
        "attributes": {
          "name": "🔄 Invalidate Next.js Cache",
          "url": "${WEBHOOK_URL}",
          "custom_payload": null,
          "headers": {},
          "events": [{
            "entity_type": "cda_cache_tags",
            "event_types": ["invalidate"],
            "filters": []
          }],
          "http_basic_user": null,
          "http_basic_password": null
        }
      }
    }
EOF
    )

    if [[ "$webhook_create_response" == "201" ]]; then
      echo "✅ Webhook created successfully."
    else
      echo "❌ Failed to create webhook. Response:"
      cat /tmp/webhook_response.json | jq .
      exit 1
    fi

    return
  fi

  echo "🔁 Webhook already exists — updating it..."

  update_response=$(curl -s -w "%{http_code}" -o /tmp/webhook_update.json \
    -X PATCH "https://site-api.datocms.com/webhooks/${WEBHOOK_ID}" \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/vnd.api+json" \
    -H "Content-Type: application/vnd.api+json" \
    -H "X-Api-Version: 3" \
    -d @- <<EOF
{
  "data": {
    "id": "${WEBHOOK_ID}",
    "type": "webhook",
    "attributes": {
      "url": "${WEBHOOK_URL}"
    }
  }
}
EOF
  )

  if [[ "$update_response" == "200" ]]; then
    echo "✅ DatoCMS webhook updated."
  else
    echo "❌ Failed to update webhook. Response:"
    cat /tmp/webhook_update.json | jq .
    exit 1
  fi
}

install_or_update_web_previews_plugin() {
  local PREVIEW_URL="${SITE_URL}/api/preview-links?token=${SECRET_TOKEN}"

  install_or_update_plugin "datocms-plugin-web-previews" "$(cat <<EOF
{
  "data": {
    "id": "temp",
    "type": "plugin",
    "attributes": {
      "parameters": {
        "frontends": [
          {
            "name": "Production",
            "previewWebhook": "$PREVIEW_URL"
          }
        ],
        "startOpen": true
      }
    }
  }
}
EOF
)" "Web Previews"
}

install_or_update_seo_plugin() {
  local SEO_URL="${SITE_URL}/api/seo-analysis?token=${SECRET_TOKEN}"

  install_or_update_plugin "datocms-plugin-seo-readability-analysis" "$(cat <<EOF
{
  "data": {
    "id": "temp",
    "type": "plugin",
    "attributes": {
      "parameters": {
        "htmlGeneratorUrl": "$SEO_URL",
        "autoApplyToFieldsWithApiKey": "seo_analysis",
        "setSeoReadabilityAnalysisFieldExtensionId": true
      }
    }
  }
}
EOF
)" "SEO Analysis"
}

configure_slug_with_collections_plugin() {
  echo ""
  echo "🔄 Configuring 'Slug With Collections' plugin..."

  SLUG_PLUGIN_ID=$(echo "$PLUGIN_LIST" | jq -r '.data[] | select(.attributes.package_name == "datocms-plugin-slug-with-collections") | .id')

  if [[ -z "$SLUG_PLUGIN_ID" || "$SLUG_PLUGIN_ID" == "null" ]]; then
    echo "⚠️  Plugin 'slug-with-collections' not installed — skipping."
    return
  fi

  echo "🔍 Fetching API tokens to find a readonly token..."
  TOKENS_RESPONSE=$(curl -s \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/vnd.api+json" \
    -H "Content-Type: application/vnd.api+json" \
    -H "X-Api-Version: 3" \
    https://site-api.datocms.com/access_tokens)

  READ_TOKEN=$(echo "$TOKENS_RESPONSE" | jq -r '.data[] | select(.attributes.hardcoded_type == "readonly") | .attributes.token' | head -n 1)

  if [[ -z "$READ_TOKEN" || "$READ_TOKEN" == "null" ]]; then
    echo "❌ No readonly token found — skipping plugin configuration."
    return
  fi

  echo "✅ Readonly token found. Updating plugin..."

  update_response=$(curl -s -w "%{http_code}" -o /tmp/slug_plugin_update.json \
    -X PATCH "https://site-api.datocms.com/plugins/${SLUG_PLUGIN_ID}" \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/vnd.api+json" \
    -H "Content-Type: application/vnd.api+json" \
    -H "X-Api-Version: 3" \
    -d @- <<EOF
{
  "data": {
    "id": "${SLUG_PLUGIN_ID}",
    "type": "plugin",
    "attributes": {
      "parameters": {
        "readAPIToken": "${READ_TOKEN}"
      }
    }
  }
}
EOF
  )

  if [[ "$update_response" == "200" ]]; then
    echo "✅ Slug With Collections plugin updated with readonly token."
  else
    echo "❌ Failed to update Slug With Collections plugin. Response:"
    cat /tmp/slug_plugin_update.json | jq .
  fi
}

restore_workflows() {
  echo ""
  echo "🔁 Restoring GitHub Actions workflows (if needed)..."

  if [ -d ".github/_workflows" ]; then
    mv .github/_workflows .github/workflows
    rm -rf .github/_workflows
    git add .github/workflows
    git commit -m "Restore GitHub Actions workflows"
    git push
    echo "✅ Workflows restored and pushed to the repo."
  else
    echo "⚠️  .github/_workflows not found. Skipping workflow restore."
  fi
}

trigger_vercel_deploy() {
  echo ""
  echo "🚀 Redeploying the project (production)..."
  echo "⏳ This might take a few seconds... please wait until deployment is complete."
  vercel --prod --yes
  echo ""
  echo "🎉 Setup complete!"
}

function extract_datocms_project_info() {
  echo "🔍 Extracting DatoCMS project information..."

  if [[ -n "$DATOCMS_CMA_TOKEN" ]]; then
    project_info=$(curl -s \
      -H "Authorization: Bearer $DATOCMS_CMA_TOKEN" \
      -H "Accept: application/vnd.api+json" \
      -H "Content-Type: application/vnd.api+json" \
      -H "X-Api-Version: 3" \
      https://site-api.datocms.com/site)

    # Extract project name
    PROJECT_NAME=$(echo "$project_info" | jq -r '.data.attributes.name')

    # Extract internal domain
    INTERNAL_DOMAIN=$(echo "$project_info" | jq -r '.data.attributes.internal_domain')

    # You can add more extractions as needed

    echo "✅ Extracted project info:"
    echo "   Project Name: $PROJECT_NAME"
    echo "   Internal Domain: $INTERNAL_DOMAIN"
  else
    echo "⚠️ No DatoCMS CMA token found"
  fi
}

##############################
# 🛠️ GitHub Configuration (optional)
##############################

prompt_github_tokens() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔐  (Optional) GitHub Personal Access Token"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔸 This token is *optional*, but highly recommended if you want:"
  echo "    - GitHub secrets set automatically"
  echo "    - GitHub Pages enabled"
  echo "    - Repo settings configured (merge rules, homepage, etc.)"
  echo ""
  echo "📎 Generate a token here: https://github.com/settings/personal-access-tokens"
  echo "→ Click 'Generate new token (classic)' or create a fine-grained token"
  echo ""
  echo "✅ Required permissions (with Read & Write access):"
  echo "   - Repository → Administration"
  echo "   - Repository → Dependabot secrets"
  echo "   - Repository → Environments"
  echo "   - Repository → Pages"
  echo "   - Repository → Secrets"
  echo ""
  echo "📌 If you're creating this token for a repository under an *organization*,"
  echo "   an admin may need to approve it before it becomes usable."
  echo ""

  read -rsp "🔐 Paste your GitHub personal access token (or press Enter to skip): " GITHUB_TOKEN
  echo ""

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊  (Optional) Lighthouse CI Token (Step 3 in README)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🧪 Only needed if you want to enable Lighthouse CI reports in GitHub Actions"
  echo "→ Get it from: https://github.com/apps/lighthouse-ci"
  echo "→ Click 'Configure', choose your repo, and copy the project token"
  echo ""

  read -rsp "🔐 Paste your Lighthouse CI project token (optional): " LHCI_GITHUB_APP_TOKEN
  echo ""

  if [[ -z "$GITHUB_TOKEN" ]]; then
    echo ""
    echo "⚠️  GitHub token not provided. Skipping GitHub integration steps."
    SKIP_GITHUB=true
  else
    export GH_TOKEN="$GITHUB_TOKEN"
    SKIP_GITHUB=false
  fi
}

install_gh_cli_if_missing() {
  echo ""
  echo "🔍 Checking for GitHub CLI..."

  if ! command -v gh &> /dev/null; then
    echo "⚠️ GitHub CLI not found. Attempting to install..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      if command -v brew &> /dev/null; then
        brew install gh
      else
        echo "❌ Homebrew not found. Please install GitHub CLI manually: https://cli.github.com"
        exit 1
      fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # Linux
      if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y gh
      elif command -v yum &> /dev/null; then
        sudo yum install -y gh
      else
        echo "❌ Package manager not supported. Please install GitHub CLI manually: https://cli.github.com"
        exit 1
      fi
    else
      echo "❌ Unsupported OS. Please install GitHub CLI manually: https://cli.github.com"
      exit 1
    fi

    if command -v gh &> /dev/null; then
      echo "✅ GitHub CLI installed successfully."
    else
      echo "❌ Failed to install GitHub CLI. Please install it manually: https://cli.github.com"
      exit 1
    fi
  else
    echo "✅ GitHub CLI is already installed."
  fi
}

configure_github_repo() {
  echo ""
  echo "🔧 Configuring GitHub repository settings..."

  REPO_URL=$(git config --get remote.origin.url)
  echo "🔗 Raw REPO_URL: $REPO_URL"

  # Extract REPO_OWNER and REPO_NAME (works for both HTTPS and SSH remotes)
  REPO_OWNER=$(echo "$REPO_URL" | sed -E 's#.*[:/]([^/]+)/[^/]+\.git#\1#')
  REPO_NAME=$(echo "$REPO_URL" | sed -E 's#.*[:/][^/]+/([^/]+)\.git#\1#')

  echo "👤 REPO_OWNER: $REPO_OWNER"
  echo "📁 REPO_NAME: $REPO_NAME"

  echo "📡 Sending PATCH request to update repository settings..."
  set +e
  gh_response=$(gh api "repos/${REPO_OWNER}/${REPO_NAME}" \
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
    --field homepage="$SITE_URL" 2>&1)
  exit_code=$?
  set -e

  if [[ $exit_code -ne 0 ]]; then
    echo "❌ Failed to configure GitHub repo."
    echo "🔐 GitHub CLI error:"
    echo "$gh_response"

    if echo "$gh_response" | grep -q "Bad credentials"; then
      echo ""
      echo "🚫 The GitHub token provided is invalid or expired."
    elif echo "$gh_response" | grep -q "Resource not accessible by personal access token"; then
      echo ""
      echo "🚫 Your token does not have permission to access this repository."
    fi

    echo ""
    echo "🔐 Required token permissions (with Read & Write access)"
    echo "   - Repository → Administration"
    echo "   - Repository → Dependabot secrets"
    echo "   - Repository → Environments"
    echo "   - Repository → Pages"
    echo "   - Repository → Secrets"
    echo ""
    echo "📌 If this repository belongs to an *organization*,"
    echo "   an admin may need to approve the token for access."
    echo ""
    echo "💡 Generate a new token here:"
    echo "   → https://github.com/settings/personal-access-tokens"
    echo ""
    echo "🔁 Then re-run the setup script."

    exit 1
  else
    echo "✅ GitHub repository settings updated."
  fi
}

set_github_secrets() {
  echo ""
  echo "🔐 Setting GitHub secrets..."

  for key in DATOCMS_DRAFT_CONTENT_CDA_TOKEN DATOCMS_PUBLISHED_CONTENT_CDA_TOKEN DATOCMS_CMA_TOKEN SITE_URL; do
    value=$(grep "^$key=" .env.local | cut -d '=' -f2-)

    if [[ -n "$value" ]]; then
      echo "::add-mask::$value"
      echo "→ Setting secret: $key = [REDACTED]"

      # Set regular GitHub secret
      set +e
      gh_output=$(gh secret set "$key" --body "$value" 2>&1)
      exit_code=$?
      set -e

      if [[ $exit_code -ne 0 ]]; then
        echo "❌ Failed to set GitHub secret '$key'"
        echo "🔐 GitHub CLI error:"
        echo "$gh_output"
        echo ""
        echo "💡 Double-check your GitHub token permissions (Read & Write required):"
        echo "   - Repository → Secrets"
        echo "   - Repository → Administration"
        echo ""
        echo "📌 If this is an organization repo, your token might need admin approval."
        echo ""
        exit 1
      fi

      # Attempt to set Dependabot secret — FAIL if it doesn't work
      echo "→ Setting Dependabot secret: $key = [REDACTED]"
      set +e
      gh_output_dependabot=$(gh secret set "$key" --body "$value" --app dependabot 2>&1)
      exit_code_dependabot=$?
      set -e

      if [[ $exit_code_dependabot -ne 0 ]] || echo "$gh_output_dependabot" | grep -qiE "resource not accessible|403|saml enforcement"; then
        echo "❌ Failed to set Dependabot secret '$key'"
        echo "🔐 GitHub CLI error:"
        echo "$gh_output_dependabot"
        echo ""
        echo "💡 Ensure your token includes:"
        echo "   - Repository → Dependabot secrets (Read & Write)"
        echo ""
        echo "📌 Organization tokens may require admin approval for Dependabot access."
        echo ""
        exit 1
      fi
    fi
  done

  if [[ -n "$LHCI_GITHUB_APP_TOKEN" ]]; then
    echo "::add-mask::$LHCI_GITHUB_APP_TOKEN"
    echo "→ Setting secret: LHCI_GITHUB_APP_TOKEN = [REDACTED]"

    # Main secret
    set +e
    gh_output=$(gh secret set "LHCI_GITHUB_APP_TOKEN" --body "$LHCI_GITHUB_APP_TOKEN" 2>&1)
    exit_code=$?
    set -e

    if [[ $exit_code -ne 0 ]]; then
      echo "❌ Failed to set LHCI_GITHUB_APP_TOKEN"
      echo "🔐 GitHub CLI error:"
      echo "$gh_output"
      echo ""
      echo "💡 Make sure your GitHub token has permission to write secrets."
      echo "🔁 Then re-run the setup script."
      exit 1
    fi

    # Dependabot
    echo "→ Setting Dependabot secret: LHCI_GITHUB_APP_TOKEN = [REDACTED]"
    set +e
    gh_output_dependabot=$(gh secret set "LHCI_GITHUB_APP_TOKEN" --body "$LHCI_GITHUB_APP_TOKEN" --app dependabot 2>&1)
    exit_code_dependabot=$?
    set -e

    if [[ $exit_code_dependabot -ne 0 ]] || echo "$gh_output_dependabot" | grep -qiE "resource not accessible|403|saml enforcement"; then
      echo "❌ Failed to set LHCI_GITHUB_APP_TOKEN for Dependabot"
      echo "🔐 GitHub CLI error:"
      echo "$gh_output_dependabot"
      echo ""
      echo "💡 Ensure your token includes:"
      echo "   - Repository → Dependabot secrets (Read & Write)"
      echo ""
      echo "📌 Organization tokens may require admin approval for Dependabot access."
      echo ""
      exit 1
    fi
  fi

  echo "✅ All GitHub secrets set successfully."
}

enable_github_pages() {
  echo ""
  echo "📘 Enabling GitHub Pages..."

  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  git fetch origin

  if ! git ls-remote --exit-code origin gh-pages &>/dev/null; then
    echo "🔧 Creating empty gh-pages branch..."
    git checkout --orphan gh-pages
    git reset --hard
    echo "# GitHub Pages placeholder" > index.html
    git add index.html
    git commit -m "chore: init gh-pages"
    git push origin gh-pages
    git checkout "$CURRENT_BRANCH"
  fi

  echo "🔍 Checking existing GitHub Pages config..."
  set +e
  current_config=$(gh api "repos/${REPO_OWNER}/${REPO_NAME}/pages" 2>&1)
  config_status=$?
  set -e

  if [[ $config_status -eq 0 ]]; then
    source_branch=$(echo "$current_config" | jq -r '.source.branch // empty')
    source_path=$(echo "$current_config" | jq -r '.source.path // empty')

    if [[ "$source_branch" == "gh-pages" && "$source_path" == "/" ]]; then
      echo "✅ GitHub Pages is already configured correctly (branch: $source_branch, path: $source_path)."
      return
    else
      echo "⚠️ GitHub Pages is enabled but source is incorrect. Updating..."
    fi
  else
    echo "ℹ️ GitHub Pages not enabled yet. Proceeding to enable it..."
  fi

  echo "🔧 Setting GitHub Pages source to gh-pages branch (root)..."
  set +e
  gh_output=$(gh api "repos/${REPO_OWNER}/${REPO_NAME}/pages" \
    --method POST \
    --silent \
    --input - <<< '{ "source": { "branch": "gh-pages", "path": "/" } }' 2>&1)
  exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]; then
    echo "✅ GitHub Pages enabled."
  elif [[ $exit_code -eq 409 ]]; then
    echo "ℹ️ GitHub Pages was already enabled (conflict)."
  else
    echo "❌ Failed to enable GitHub Pages (exit code $exit_code)"
    echo "🔐 GitHub CLI error:"
    echo "$gh_output"
    echo ""
    echo "💡 Ensure your GitHub token has the required permissions (Read & Write):"
    echo "   - Repository → Pages"
    echo "   - Repository → Administration"
    echo ""
    echo "📌 If this is an organization repo, token approval may be required."
    exit 1
  fi
}

final_push() {
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  echo "📤 Pushing to current branch: $CURRENT_BRANCH..."

  git add .

  if [[ -n $(git status -s) ]]; then
    git commit -m "chore: repository initialization updates"
  fi

  git push origin "$CURRENT_BRANCH"
  echo "✅ All changes pushed to '$CURRENT_BRANCH'"
}

remove_init_files() {
    echo "🗑️ Removing initialization files..."

    # Remove the init project script
    if [[ -f "scripts/init-project.sh" ]]; then
      git rm scripts/init-project.sh
    fi

    # Remove the datocms.json file
    if [[ -f "datocms.json" ]]; then
      git rm datocms.json
    fi

    # Remove the post-deploy API route
    if [[ -d "src/app/api/post-deploy" ]]; then
      git rm -r src/app/api/post-deploy
    fi

  if [[ -n $(git status -s) ]]; then
    git commit -m "chore: remove repository initialization files"
  fi
}

function cleanup_readme_sections() {
  echo "🧼 Cleaning up README.md sections..."

  if [[ -f "README.md" ]]; then
    echo "🧽 Keeping only content between ORIGINAL README markers..."

    # Extract everything between the two markers, excluding the markers themselves
    awk '/<!-- ORIGINAL-README-START/{flag=1; next} /ORIGINAL-README-END -->/{flag=0} flag' README.md > README.cleaned.md

    mv README.cleaned.md README.md

    echo "🧻 Tidying up empty lines..."
    sed -i.bak '/^$/N;/^\n$/D' README.md

    rm -f README.md.bak
    git add README.md
    echo "✅ README.md cleaned and staged."
  else
    echo "⚠️ README.md not found — skipping all cleanups."
  fi
}

##############################
# 🚀 Run All Steps
##############################

ensure_vercel_cli_installed
generate_secret_token
link_vercel_project
get_vercel_site_url
set_vercel_env_variables
prompt_datocms_token
fetch_and_write_datocms_tokens_to_env
set_datocms_tokens_on_vercel
fetch_datocms_plugin_data
update_webhook
install_or_update_web_previews_plugin
install_or_update_seo_plugin
configure_slug_with_collections_plugin

prompt_github_tokens

if [[ "$SKIP_GITHUB" != true ]]; then
  install_gh_cli_if_missing
  configure_github_repo
  set_github_secrets
  enable_github_pages
fi

remove_init_files
extract_datocms_project_info
update_readme_urls
cleanup_readme_sections
restore_workflows
final_push
trigger_vercel_deploy