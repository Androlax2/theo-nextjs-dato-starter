echo $(head -n1 $1) | npx cspell --no-summary --no-progress --language-id commit-msg $1
