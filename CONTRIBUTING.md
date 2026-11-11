# Contributing to InsightOS

Thank you for considering a contribution. Changes should improve product clarity, reliability, accessibility, maintainability, or documented user value.

## Before you begin

1. Search existing issues and pull requests to avoid duplicate work.
2. For substantial changes, open an issue first to discuss the problem and proposed approach.
3. Keep changes focused and avoid unrelated formatting or refactoring.
4. Do not include secrets, private user data, or assets that you do not have permission to use.

## Development setup

Follow [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md). That guide must be kept aligned with the actual application stack. Do not assume commands or runtime versions that are not documented there.

## Pull request checklist

- [ ] The change has a clear purpose and appropriate scope.
- [ ] Relevant tests have been added or updated.
- [ ] Formatting, linting, tests, and production build have been run where configured.
- [ ] Documentation and changelog have been updated where appropriate.
- [ ] UI changes have been checked for keyboard access, focus visibility, contrast, responsive behaviour, and reduced-motion support.
- [ ] Screenshots or recordings are included for material visual changes where useful.
- [ ] No secrets, credentials, private data, or unlicensed assets are included.

## Commit messages

Use clear, imperative commit messages. Conventional Commits are recommended:

- `feat: add workspace navigation`
- `fix: preserve selected date across refresh`
- `docs: clarify local development setup`
- `refactor: centralise surface tokens`
- `test: cover timezone boundary cases`

## Review process

Maintainers may request clarification, smaller scope, tests, or revisions. Keep review discussions constructive and make requested changes easy to inspect. A change is ready to merge only after the repository's required checks and approvals have passed.

## Community standards

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
