#!/bin/zsh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Pre-flight Check ---
echo "🔎 Checking for clean working directory..."
if ! git diff --quiet --exit-code; then
  echo "❌ Error: Your working directory is not clean. Please commit or stash your changes before running this script."
  exit 1
fi
echo "✅ Working directory is clean."

# --- Overleaf Sync ---
echo "📥 Pulling latest .tex from Overleaf..."
git fetch overleaf master

echo "Applying changes from Overleaf..."
# Use squash to apply changes without a merge commit
git merge --squash overleaf/master

# Check if the squash merge resulted in any changes
if git diff --cached --quiet; then
  echo "✅ No new changes from Overleaf. Nothing to do."
  exit 0
fi

# --- Manual PDF Step ---
echo "📄 .tex file updated. Now download the latest Ishaan_Goel_Resume.pdf from Overleaf manually."
read "?⏳ Press Enter once Ishaan_Goel_Resume.pdf is downloaded..."

# --- Staging ---
echo "📌 Staging .tex and .pdf files..."
git add Ishaan_Resume_LaTeX.tex Ishaan_Goel_Resume.pdf

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
