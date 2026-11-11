# Publishing from Windows

The repository includes `scripts/push-insightos-to-github.cmd`, a Windows CMD publisher for the local `Desktop\insightos-app` folder.

## Use

1. Install Git for Windows and sign in to GitHub through Git Credential Manager.
2. Download or copy the CMD file into a convenient location.
3. Double-click it, or run it from Command Prompt. The default source is `%USERPROFILE%\Desktop\insightos-app`.
4. You can also pass a different source path as the first argument.
5. Choose a review branch (recommended) or a direct update to `main`.
6. Inspect the staged file list carefully. Type `YES` only when you are satisfied.

The script clones the current repository into a temporary workspace, overlays the local application files, and commits from the repository's existing history. This avoids unrelated-history push failures and leaves the original project folder, its Git history, and its remotes untouched.

The following are deliberately not copied: Git metadata, dependency folders, common build outputs, local environment files, common private-key formats, logs, and local database files. Existing repository governance files and documentation are preserved; local application docs are placed under `docs/application/`, and local GitHub Actions workflows are copied into `.github/workflows/`.

This is a convenience tool, not a secret scanner. Review staged paths and source content for API keys, credentials, personal data, and assets you do not have permission to publish before confirming.

The review-branch option opens a GitHub comparison page so you can inspect the application import and create a pull request. The direct-to-main option updates the default branch immediately and may be blocked by branch protection rules.
