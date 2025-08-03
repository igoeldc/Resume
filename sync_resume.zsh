#!/bin/zsh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- PDF Check ---
echo "🔎 Checking for local PDF changes..."
pdf_changed=false
if ! git diff --quiet --exit-code -- Ishaan_Goel_Resume.pdf; then
  echo "📄 PDF has changed. Staging..."
  git add Ishaan_Goel_Resume.pdf
  pdf_changed=true
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
        echo "⚠️ Merge conflict or local change detected. Resolving in favor of Overleaf..."
        
        # Reset your working copy of conflicting files to Overleaf version
        git checkout --theirs Ishaan_Resume_LaTeX.tex Ishaan_Goel_Resume.pdf 2>/dev/null || true

        # Stage them
        git add Ishaan_Resume_LaTeX.tex Ishaan_Goel_Resume.pdf

        # No commit here — defer to final commit block
        echo "✅ Merge resolved in favor of Overleaf — staged for final commit."
    fi
    overleaf_has_changes=true
else
    echo "✅ Overleaf is already up to date."
fi

# --- Stage final tex ---
if $overleaf_has_changes; then
    git add Ishaan_Resume_LaTeX.tex
fi

# --- Final Commit ---
if $pdf_changed || $overleaf_has_changes; then
    today=$(date +"%m/%d/%y")
    default_msg="Updated resume $today"

    read "?✏️ Use default commit message: \"$default_msg\"? (Y/n): " use_default
    if [[ "$use_default" =~ ^[Yy]?$ ]]; then
        commit_msg="$default_msg"
    else
        read "?📝 Enter custom commit message: " commit_msg
    fi

    echo "📝 Committing changes..."
    if ! git diff --cached --quiet; then
        git commit -m "$commit_msg"
    else
        echo "✅ Nothing to commit."
    fi
    echo "🚀 Pushing to GitHub (origin)..."
    git push origin master
    echo "✅ Resume synced and pushed to GitHub."
else
    echo "✅ No changes to commit. Working directory is clean."
    exit 0
fi
