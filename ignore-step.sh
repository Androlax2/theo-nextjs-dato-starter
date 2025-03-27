#!/bin/bash

echo "VERCEL_GIT_COMMIT_REF: $VERCEL_GIT_COMMIT_REF"

# Run the build if the branch is not `gh-pages`
# This need to be put inside Vercel's ignore step to prevent the build from running on the `gh-pages` branch
#
# https://vercel.com/docs/platform/projects#ignored-build-step
#
# Select "Run my Bash Script" and paste the following code :
# ```
# bash ignore-step.sh
# ```

if [[ "$VERCEL_GIT_COMMIT_REF" == "gh-pages" ]]; then
  # Don't build
  echo "🛑 - Build cancelled"
  exit 0;

else
  # Proceed with the build
  echo "✅ - Build can proceed"
  exit 1;
fi