# Publishing from Windows

The exact project names are important:

- GitHub repository: articwhisper895/InsightOS (capital I, O, S).
- Desktop source folder: insightos-app (all lowercase).

The CMD publisher is scripts/push-insightos-to-github.cmd. It automatically searches the Windows Desktop and OneDrive Desktop for a folder whose name matches insightos-app exactly. A folder with different capitalization is rejected with a clear message. You may also drag the exact folder onto the CMD file to pass its path.

## Requirements

1. Install Git for Windows.
2. Sign in to GitHub through Git Credential Manager.
3. Make sure the source directory is exactly Desktop\insightos-app.

## Run

1. Download scripts/push-insightos-to-github.cmd from this repository.
2. Double-click it.
3. Choose a review branch (recommended) or a direct update to main.
4. Review the staged files and type YES in capital letters to publish.
5. For a review branch, inspect the comparison page and create a pull request.

The publisher clones the current GitHub main into a temporary workspace, then overlays the local application files. It preserves the repository's root documentation and GitHub issue templates, places app documentation under docs/application/, and copies app GitHub workflows into .github/workflows/. It does not modify the source folder or its Git history.

Common local environment files, private-key formats, dependency folders, build output, databases, and logs are excluded. This is not a secret scanner: inspect staged changes for hard-coded credentials, personal data, and assets you do not have permission to publish.

A diagnostic log is written to %TEMP%\InsightOS-publish.log. If a run fails, the script displays the log before exiting.
