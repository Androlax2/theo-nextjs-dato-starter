#!/bin/bash

set -e

echo ""
echo "🚀 Initializing Vercel + GitHub + DatoCMS project"
echo "-----------------------------------------------"

# Prompt for token
read -sp "🔐 Enter the secret token you generated (from step 10): " SECRET_TOKEN
echo ""

# Validate token
if [ -z "$SECRET_TOKEN" ]; then
  echo "❌ Token cannot be empty. Exiting."
  exit 1
fi

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

# Add SITE_URL
vercel env rm SITE_URL || true
echo "$SITE_URL" | vercel env add SITE_URL production
echo "$SITE_URL" | vercel env add SITE_URL preview
echo "$SITE_URL" | vercel env add SITE_URL development

# Add SECRET_API_TOKEN
vercel env rm SECRET_API_TOKEN || true
echo "$SECRET_TOKEN" | vercel env add SECRET_API_TOKEN production
echo "$SECRET_TOKEN" | vercel env add SECRET_API_TOKEN preview
echo "$SECRET_TOKEN" | vercel env add SECRET_API_TOKEN development

echo ""
echo "🔁 Restoring GitHub Actions workflows (if needed)..."

if [ -d ".github/_workflows" ]; then
  mv .github/_workflows .github/workflows
  git add .github/workflows
  git commit -m "Restore GitHub Actions workflows"
  git push
  echo "✅ Workflows restored and pushed to the repo."
else
  echo "⚠️  .github/_workflows not found. Skipping workflow restore."
fi

echo ""
echo "🚀 Redeploying the project (production)..."
vercel --prod --confirm --no-clipboard

echo ""
echo "🧹 Cleaning up init script..."
rm -- "$0"

echo ""
echo "🎉 Setup complete and script removed!"
echo "Your project is deployed and fully configured."
