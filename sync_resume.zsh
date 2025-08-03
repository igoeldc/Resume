#!/bin/zsh

# Exit immediately if a command exits with a non-zero status.
set -e

pdf_committed=false
# --- PDF Check and Commit ---
echo "🔎 Checking for local PDF changes..."
if ! git diff --quiet --exit-code -- Ishaan_Goel_Resume.pdf; then
  echo "📝 Committing modified PDF to clean working directory..."
  git add Ishaan_Goel_Resume.pdf
  git commit -m "chore: Temporarily commit PDF"
  pdf_committed=true
else
  echo "📄 PDF is unchanged."
fi

# --- Overleaf Sync ---
echo "📥 Pulling latest .tex from Overleaf..."
git fetch overleaf master

overleaf_head=$(git rev-parse overleaf/master)
head=$(git rev-parse HEAD)

overleaf_has_changes=false
if [ "$overleaf_head" != "$head" ]; then
    echo "Merging changes from Overleaf..."
    if ! git merge overleaf/master --no-edit; then
        echo "⚠️ Merge conflict detected. Resolving in favor of Overleaf..."
        conflicted_files=$(git diff --name-only --diff-filter=U)
        for file in $conflicted_files; do
            git checkout --theirs "$file"
            git add "$file"
        done
        git commit -m "resolve: auto-merged in favor of Overleaf"
    fi
    overleaf_has_changes=true
else
    echo "✅ Overleaf is already up to date."
fi

# --- Consolidate Commits ---
commits_to_squash=0
if [ "$pdf_committed" = true ]; then
    commits_to_squash=$((commits_to_squash + 1))
fi
if [ "$overleaf_has_changes" = true ]; then
    commits_to_squash=$((commits_to_squash + 1))
fi

if [ "$commits_to_squash" -gt 0 ]; then
    echo "🧽 Consolidating changes into a single commit..."
    git reset --soft "HEAD~$commits_to_squash"
else
    echo "✅ No changes to commit. Working directory is clean."
    exit 0
fi

# --- Final Commit ---
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
