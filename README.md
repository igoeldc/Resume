# 📄 Resume

This repository contains my LaTeX-formatted resume.

## 🛠 Usage

To sync Overleaf edits and update GitHub:

```zsh
make sync
```

This runs sync_resume.zsh to:
- Pull the latest .tex from Overleaf
- Prompt you to download the latest .pdf
- Stage and commit both files (if changed)
- Push clean updates to GitHub if at least one has changed

## 📁 Files

- `Ishaan_Resume_LaTeX.tex` – source resume file (from Overleaf)
- `Ishaan_Goel_Resume.pdf` – compiled resume (downloaded from Overleaf)
- `sync_resume.zsh` – sync automation script
- `Makefile` – simple shortcut to run the sync script

## 🔗 Preview

You can view the latest version [here](./Ishaan_Goel_Resume.pdf).