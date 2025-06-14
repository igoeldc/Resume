#!/bin/zsh

# Get today's date in mm/dd/yy format
today=$(date +"%m/%d/%y")

echo "📥 Pulling latest .tex from Overleaf (auto-resolving in favor of Overleaf)..."
git fetch overleaf master
git merge -X theirs overleaf/master --no-edit

# Automatically remove the merge commit but keep Overleaf changes staged
echo "🧽 Cleaning up merge context..."
# git reset --soft HEAD~1
echo "🧠 Rewriting Overleaf merge into a clean commit..."

echo "📄 Done. Now download the latest Ishaan_Goel_Resume.pdf from Overleaf manually."
read "?⏳ Press Enter once Ishaan_Goel_Resume.pdf is downloaded..."

# Stage files only if they've changed
staged_anything=false

if git diff --quiet --exit-code -- Ishaan_Resume_LaTeX.tex; then
  echo "📝 .tex file unchanged."
else
  git add Ishaan_Resume_LaTeX.tex
  echo "📌 Staged .tex file"
  staged_anything=true
fi

if git diff --quiet --exit-code -- Ishaan_Goel_Resume.pdf; then
  echo "📄 .pdf file unchanged."
else
  git add Ishaan_Goel_Resume.pdf
  echo "📌 Staged .pdf file"
  staged_anything=true
fi

# Ask about using default commit message
default_msg="Updated resume $today"
read "?✏️ Use default commit message: \"$default_msg\"? (y/n): " use_default

if [[ "$use_default" == "y" ]]; then
    commit_msg="$default_msg"
else
    read "?📝 Enter custom commit message: " commit_msg
fi

# Commit and push if something was staged
if [[ "$staged_anything" = true ]]; then
  git commit -m "$commit_msg"
  echo "🚀 Pushing to GitHub (origin)..."
  git push origin master
  echo "✅ Clean commit created, merge removed, and pushed to GitHub."
else
  echo "⚠️ No changes to commit. Nothing pushed."
fi