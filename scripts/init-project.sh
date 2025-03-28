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

# Remove SITE_URL if exists
vercel env rm SITE_URL --yes || true
echo "$SITE_URL" | vercel env add SITE_URL production

# Remove SECRET_API_TOKEN if exists
vercel env rm SECRET_API_TOKEN --yes || true
echo "$SECRET_TOKEN" | vercel env add SECRET_API_TOKEN production

echo ""
echo "📡 Retrieving DATOCMS_CMA_TOKEN from Vercel..."

DATOCMS_CMA_TOKEN=$(vercel env ls | grep DATOCMS_CMA_TOKEN | awk '{print $4}')

if [ -z "$DATOCMS_CMA_TOKEN" ]; then
  echo "❌ DATOCMS_CMA_TOKEN not found in Vercel environment. Skipping DatoCMS updates."
else
  echo "✅ Found DATOCMS_CMA_TOKEN"

  echo ""
  echo "🔄 Updating DatoCMS webhook URL with secret token..."

  WEBHOOK_URL="${SITE_URL}/api/invalidate-cache?token=${SECRET_TOKEN}"
  echo "Updating webhook URL to: $WEBHOOK_URL"

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
      -d "{
        \"data\": {
          \"id\": \"${WEBHOOK_ID}\",
          \"type\": \"webhook\",
          \"attributes\": {
            \"url\": \"${WEBHOOK_URL}\"
          }
        }
      }")

    if echo "$WEBHOOK_UPDATE_RESPONSE" | grep -q '"type":"api_error"'; then
      echo "❌ Failed to update DatoCMS webhook:"
      echo "$WEBHOOK_UPDATE_RESPONSE"
    else
      echo "✅ DatoCMS webhook successfully updated."
    fi
  fi

  echo ""
  echo "🔄 Updating DatoCMS web-previews plugin with secret token..."

  PLUGIN_UPDATE_URL="${SITE_URL}/api/preview-links?token=${SECRET_TOKEN}"

  PLUGIN_LIST=$(curl -s -X GET "https://site-api.datocms.com/plugins" \
    -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
    -H "Accept: application/json" \
    -H "X-Api-Version: 3")

  PLUGIN_ID=$(echo "$PLUGIN_LIST" | jq -r '.data[] | select(.attributes.package_name == "datocms-plugin-web-previews") | .id')

  if [ -z "$PLUGIN_ID" ]; then
    echo "❌ Could not find plugin 'datocms-plugin-web-previews'."
    echo "$PLUGIN_LIST"
  else
    echo "✅ Found plugin ID: $PLUGIN_ID"
    echo "➡️ Updating previewWebhook URL to: $PLUGIN_UPDATE_URL"

    PLUGIN_PATCH_RESPONSE=$(curl -s -X PATCH "https://site-api.datocms.com/plugins/${PLUGIN_ID}" \
      -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Version: 3" \
      -d "{
        \"data\": {
          \"id\": \"${PLUGIN_ID}\",
          \"type\": \"plugin\",
          \"attributes\": {
            \"parameters\": {
              \"frontends\": [
                {
                  \"name\": \"Production\",
                  \"previewWebhook\": \"${PLUGIN_UPDATE_URL}\"
                }
              ],
              \"startOpen\": true
            }
          }
        }
      }")

    if echo "$PLUGIN_PATCH_RESPONSE" | grep -q '"type":"api_error"'; then
      echo "❌ Failed to update plugin:"
      echo "$PLUGIN_PATCH_RESPONSE"
    else
      echo "✅ Plugin successfully updated!"
    fi
  fi

  echo ""
  echo "🔄 Updating DatoCMS SEO Analysis plugin with secret token..."

  SEO_ANALYSIS_URL="${SITE_URL}/api/seo-analysis?token=${SECRET_TOKEN}"

  SEO_PLUGIN_ID=$(echo "$PLUGIN_LIST" | jq -r '.data[] | select(.attributes.package_name == "datocms-plugin-seo-readability-analysis") | .id')

  if [ -z "$SEO_PLUGIN_ID" ]; then
    echo "❌ Could not find plugin 'datocms-plugin-seo-readability-analysis'."
    echo "$PLUGIN_LIST"
  else
    echo "✅ Found plugin ID: $SEO_PLUGIN_ID"
    echo "➡️ Updating htmlGeneratorUrl to: $SEO_ANALYSIS_URL"

    SEO_PATCH_RESPONSE=$(curl -s -X PATCH "https://site-api.datocms.com/plugins/${SEO_PLUGIN_ID}" \
      -H "Authorization: Bearer ${DATOCMS_CMA_TOKEN}" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "X-Api-Version: 3" \
      -d "{
        \"data\": {
          \"id\": \"${SEO_PLUGIN_ID}\",
          \"type\": \"plugin\",
          \"attributes\": {
            \"parameters\": {
              \"htmlGeneratorUrl\": \"${SEO_ANALYSIS_URL}\",
              \"autoApplyToFieldsWithApiKey\": \"seo_analysis\",
              \"setSeoReadabilityAnalysisFieldExtensionId\": true
            }
          }
        }
      }")

    if echo "$SEO_PATCH_RESPONSE" | grep -q '"type":"api_error"'; then
      echo "❌ Failed to update SEO plugin:"
      echo "$SEO_PATCH_RESPONSE"
    else
      echo "✅ SEO Analysis plugin successfully updated!"
    fi
  fi
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
echo "🚀 Redeploying the project (production)..."
vercel --prod --yes

echo ""
echo "🧹 Cleaning up init script..."
rm -- "$0"

echo ""
echo "📤 Committing any remaining changes..."
git add .
git commit -m "Finalize project setup" || echo "⚠️ Nothing to commit."
git push

echo ""
echo "🎉 Setup complete and script removed!"
echo "Your project is deployed and fully configured."