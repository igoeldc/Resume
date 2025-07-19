#!/bin/zsh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- PDF Check ---
echo "🔎 Checking for local PDF changes..."
if ! git diff --quiet --exit-code -- Ishaan_Goel_Resume.pdf; then
  echo "📌 Staging modified PDF..."
  git add Ishaan_Goel_Resume.pdf
else
  echo "📄 PDF is unchanged."
fi

# --- Overleaf Sync ---
echo "📥 Pulling latest .tex from Overleaf..."
git fetch overleaf master
echo "Applying changes from Overleaf..."
git merge --squash overleaf/master

# --- Staging .tex ---
# Stage the .tex file only if it was changed by the merge
if ! git diff --quiet --exit-code -- Ishaan_Resume_LaTeX.tex; then
    echo "📌 Staging modified .tex file..."
    git add Ishaan_Resume_LaTeX.tex
fi

# --- Check for Changes ---
if git diff --cached --quiet; then
  echo "✅ No changes to commit. Working directory is clean."
  exit 0
fi

# --- Commit ---
today=$(date +"%m/%d/%y")
default_msg="Updated resume $today"

read "?✏️ Use default commit message: \"$default_msg\"? (Y/n): " use_default

if [[ "$use_default" =~ ^[Yy]?$ ]]; then
    commit_msg="$default_msg"
else
    read "?📝 Enter custom commit message: " commit_msg
fi


echo "📝 Committing changes..."
git commit -m "$commit_msg"

# --- Push ---
echo "🚀 Pushing to GitHub (origin)..."
git push origin master

echo "✅ Resume synced and pushed to GitHub."
