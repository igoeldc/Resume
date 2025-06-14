#!/bin/zsh

# Get today's date in mm/dd/yy format
today=$(date +"%m/%d/%y")

echo "📥 Pulling latest .tex from Overleaf..."
git pull overleaf master --allow-unrelated-histories

echo "📄 Done. Now download the latest resume.pdf from Overleaf manually."
read "?⏳ Press Enter once resume.pdf is downloaded..."

# Stage both .tex and .pdf
git add resume.tex resume.pdf

# Ask about using default commit message
default_msg="Updated resume $today"
read "?✏️ Use default commit message: \"$default_msg\"? (y/n): " use_default

if [[ "$use_default" == "y" ]]; then
    commit_msg="$default_msg"
else
    read "?📝 Enter custom commit message: " commit_msg
fi

git commit -m "$commit_msg"

# Push to GitHub
echo "🚀 Pushing to GitHub (origin)..."
git push origin master

echo "✅ Done. Overleaf changes pulled, PDF included, and commit pushed to GitHub."