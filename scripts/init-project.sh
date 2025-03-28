#!/bin/bash

set -e

echo ""
echo "🚀 Initializing Vercel + GitHub + DatoCMS project"
echo "-----------------------------------------------"

# Generate a secret token
echo "🔐 Generating secret token..."
SECRET_TOKEN=$(openssl rand -hex 32)
echo "✅ Generated secret token: $SECRET_TOKEN"

echo ""
echo "🔗 Linking Vercel project (if not already linked)..."
vercel link || true

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

echo ""
echo "📦 Setting Vercel environment variables..."

vercel env rm SITE_URL --yes || true
echo "$SITE_URL" | vercel env add SITE_URL production

vercel env rm SECRET_API_TOKEN --yes || true
echo "$SECRET_TOKEN" | vercel env add SECRET_API_TOKEN production

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

echo ""
echo "🔄 Updating DatoCMS webhook URL with secret token..."

WEBHOOK_URL="${SITE_URL}/api/invalidate-cache?token=${SECRET_TOKEN}"
PLUGIN_LIST=$(curl -s -X GET "https://site-api.datocms.com/plugins" \
  -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
  -H "Accept: application/json" \
  -H "X-Api-Version: 3")

WEBHOOK_LIST=$(curl -s -X GET "https://site-api.datocms.com/webhooks" \
  -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
  -H "Accept: application/json" \
  -H "X-Api-Version: 3")

WEBHOOK_ID=$(echo "$WEBHOOK_LIST" | jq -r '.data[] | select(.attributes.name == "🔄 Invalidate Next.js Cache") | .id')

if [ -z "$WEBHOOK_ID" ]; then
  echo "❌ Could not find existing webhook to update."
  echo "$WEBHOOK_LIST"
else
  WEBHOOK_UPDATE_RESPONSE=$(curl -s -X PATCH "https://site-api.datocms.com/webhooks/${WEBHOOK_ID}" \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Version: 3" \
    -d "{\n      \"data\": {\n        \"id\": \"${WEBHOOK_ID}\",\n        \"type\": \"webhook\",\n        \"attributes\": {\n          \"url\": \"${WEBHOOK_URL}\"\n        }\n      }\n    }")

  if echo "$WEBHOOK_UPDATE_RESPONSE" | grep -q '"type":"api_error"'; then
    echo "❌ Failed to update DatoCMS webhook:"
    echo "$WEBHOOK_UPDATE_RESPONSE"
  else
    echo "✅ DatoCMS webhook successfully updated."
  fi
fi

echo ""
echo "🔄 Updating DatoCMS web-previews plugin with secret token..."

WEB_PREV_PLUGIN_ID=$(echo "$PLUGIN_LIST" | jq -r '.data[] | select(.attributes.package_name == "datocms-plugin-web-previews") | .id')
PREVIEW_URL="${SITE_URL}/api/preview-links?token=${SECRET_TOKEN}"

if [ -z "$WEB_PREV_PLUGIN_ID" ]; then
  echo "❌ Could not find plugin 'datocms-plugin-web-previews'."
else
  curl -s -X PATCH "https://site-api.datocms.com/plugins/${WEB_PREV_PLUGIN_ID}" \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Version: 3" \
    -d "{\n      \"data\": {\n        \"id\": \"${WEB_PREV_PLUGIN_ID}\",\n        \"type\": \"plugin\",\n        \"attributes\": {\n          \"parameters\": {\n            \"frontends\": [{\n              \"name\": \"Production\",\n              \"previewWebhook\": \"${PREVIEW_URL}\"\n            }],\n            \"startOpen\": true\n          }\n        }\n      }\n    }" > /dev/null

  echo "✅ web-previews plugin updated."
fi

echo ""
echo "🔄 Updating DatoCMS SEO Analysis plugin with secret token..."

SEO_PLUGIN_ID=$(echo "$PLUGIN_LIST" | jq -r '.data[] | select(.attributes.package_name == "datocms-plugin-seo-readability-analysis") | .id')
SEO_URL="${SITE_URL}/api/seo-analysis?token=${SECRET_TOKEN}"

if [ -z "$SEO_PLUGIN_ID" ]; then
  echo "❌ Could not find plugin 'datocms-plugin-seo-readability-analysis'."
else
  curl -s -X PATCH "https://site-api.datocms.com/plugins/${SEO_PLUGIN_ID}" \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "X-Api-Version: 3" \
    -d "{\n      \"data\": {\n        \"id\": \"${SEO_PLUGIN_ID}\",\n        \"type\": \"plugin\",\n        \"attributes\": {\n          \"parameters\": {\n            \"htmlGeneratorUrl\": \"${SEO_URL}\",\n            \"autoApplyToFieldsWithApiKey\": \"seo_analysis\",\n            \"setSeoReadabilityAnalysisFieldExtensionId\": true\n          }\n        }\n      }\n    }" > /dev/null

  echo "✅ SEO Analysis plugin updated."
fi

echo ""
echo "🔁 Restoring GitHub Actions workflows (if needed)..."

if [ -d ".github/_workflows" ]; then
  mv .github/_workflows .github/workflows
  rm -rf .github/_workflows
  git add .github/workflows
  git add .github/_workflows
  git commit -m "Restore GitHub Actions workflows"
  git push
  echo "✅ Workflows restored and pushed to the repo."
else
  echo "⚠️  .github/_workflows not found. Skipping workflow restore."
fi

echo ""
echo "🚀 Rede