# Development Guide

This guide is the canonical location for verified setup and engineering instructions. Complete it against the actual application stack before publishing install commands.

## Environment

Record supported operating systems, runtime versions, package manager, and required system dependencies here.

## Installation

Add the exact dependency installation command used by the project. Commit the appropriate lockfile and keep dependency versions reproducible.

## Local development

Document the actual command to start the application, its local URL, and any required services.

## Quality checks

Document and maintain commands for:

- formatting;
- linting and static analysis;
- unit and integration tests;
- production builds;
- accessibility checks, where applicable.

## Environment variables and secrets

Provide an `.env.example` containing variable names and safe placeholder values only. Never commit API keys, credentials, private certificates, access tokens, or production data. Keep local environment files ignored by Git.

## Architecture notes

Record major architectural decisions, boundaries between modules, data flows, and external service dependencies. For consequential decisions, use a short Architecture Decision Record in `docs/decisions/` describing context, decision, alternatives, and consequences.

## Release process

Document versioning, changelog updates, release tagging, deployment steps, rollback procedure, and required post-release checks once those processes exist.
