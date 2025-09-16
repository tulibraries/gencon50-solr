# GitHub Actions Migration

This project has been migrated from CircleCI to GitHub Actions.

## Required GitHub Secrets

The following secrets need to be configured in your GitHub repository settings:

1. **SOLR_USER**: Username for Solr authentication
2. **SOLR_PASSWORD**: Password for Solr authentication
3. **GITHUB_TOKEN**: Automatically provided by GitHub Actions (used for cloning repositories and GitHub API access)

## Workflow Overview

The CI/CD pipeline consists of two main jobs:

### Test Job
- Runs on every push to main/develop branches
- Sets up a local SolrCloud cluster for testing
- Verifies that the Solr collection is accessible

### Deploy Job
- Runs only when a new release is published
- Builds the configuration asset (zip file)
- Deploys the configuration to SolrCloud
- Creates collection and aliases
- Uploads the zip file to the GitHub release

## Migration Notes

- Scripts have been moved from `.circleci/` to `.github/scripts/`
- Environment variables have been updated for GitHub Actions:
  - `~/project` → `$GITHUB_WORKSPACE`
  - `/home/circleci/` → `$HOME/`
  - `$CIRCLE_TAG` → `$RELEASE_TAG` (set to `${{ github.ref_name }}`)
- Using marketplace actions where possible:
  - `actions/checkout@v4` for code checkout
  - `docker/setup-buildx-action@v3` for Docker setup
  - `webfactory/ssh-agent@v0.9.0` for SSH key management
  - `actions/setup-python@v5` for Python setup
