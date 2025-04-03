# Release-Please GitHub Action

This GitHub Action automates the versioning and changelog generation process using Google's Release Please tool. It creates and updates release pull requests based on conventional commits, then generates GitHub releases when those PRs are merged.

## Purpose

The action serves to:

1. Automate semantic versioning based on [Conventional Commits](https://www.conventionalcommits.org/)
2. Generate and maintain CHANGELOG files
3. Create GitHub releases with proper tags
4. Support monorepo structures with multiple packages
5. Update version references in specified files (via release-please-config.json)

## Required Inputs

| Name     | Description                        | Required | Default |
| -------- | ---------------------------------- | -------- | ------- |
| `app_id` | GitHub App ID for token generation | Yes      |         |

## Required Secrets

| Name          | Description                                 | Required |
| ------------- | ------------------------------------------- | -------- |
| `private_key` | GitHub App private key for token generation | Yes      |

## Optional Inputs

| Name                  | Description                                                | Required | Default                         |
| --------------------- | ---------------------------------------------------------- | -------- | ------------------------------- |
| `runs_on`             | GitHub runner to use                                       | No       | `ubuntu-latest`                 |
| `config_file`         | Path to the release-please-config.json file                | No       | `release-please-config.json`    |
| `manifest_file`       | Path to the .release-please-manifest.json file             | No       | `.release-please-manifest.json` |
| `release_branches`    | Comma-separated list of branches that trigger the workflow | No       | `master,main`                   |
| `gitops_paths_ignore` | Paths to ignore when triggering the release workflow       | No       | `gitops.yaml`                   |

## Outputs

This action does not provide any outputs directly, but creates:

1. Release Pull Requests (when conventional commits are detected)
2. GitHub Releases (when Release PRs are merged)
3. Updated CHANGELOG.md files
4. Updated version numbers in package files and any other files configured in release-please-config.json

## How It Works

The action consists of three primary jobs:

1. **get-packages**: Extracts the list of packages from release-please-config.json
2. **github-release**: Creates/updates GitHub releases when Release PRs are merged
3. **release-pr**: Creates/updates Release PRs for each package based on conventional commits

When conventional commits are detected on a monitored branch, a Release PR is generated or updated. This PR:

- Updates version numbers in specified files
- Updates the CHANGELOG.md
- Uses semantic versioning to determine the appropriate version bump

When a Release PR is merged, a GitHub release is automatically created with release notes from the CHANGELOG.

## Configuration

### release-please-config.json

This file defines the release configuration:

```json
{
  "initial-version": "0.1.0",
  "packages": {
    ".": {
      "changelog-path": "CHANGELOG.md",
      "release-type": "node",
      "prerelease": false,
      "include-component-in-tag": false,
      "include-v-in-tag": false,
      "extra-files": [
        {
          "type": "yaml",
          "path": "gitops.yaml",
          "jsonpath": "$.apps[?(@.name=='app-name' && @.env=='dev')].revision"
        }
      ]
    }
  }
}
```

### .release-please-manifest.json

This file tracks the current versions:

```json
{
  ".": "1.2.3"
}
```

## Monorepo Support

For monorepos with multiple packages, each package should be defined in the `packages` section of the config file:

```json
{
  "packages": {
    ".": {
      "changelog-path": "CHANGELOG.md",
      "release-type": "node"
    },
    "packages/package1": {
      "changelog-path": "CHANGELOG.md",
      "release-type": "node"
    },
    "packages/package2": {
      "changelog-path": "CHANGELOG.md",
      "release-type": "python"
    }
  }
}
```

## Basic Usage Example

```yaml
name: Release

on:
  push:
    branches:
      - main
    paths-ignore:
      - 'gitops.yaml'

jobs:
  release:
    uses: zeeshan-maqbool/gha-workflows/.github/workflows/release.yml@main
    with:
      app_id: ${{ vars.RELEASE_APP_ID }}
    secrets:
      private_key: ${{ secrets.RELEASE_APP_PRIVATE_KEY }}
```

## Advanced Configuration Example

```yaml
name: Release

on:
  push:
    branches:
      - main
    paths-ignore:
      - 'gitops.yaml'
      - 'infrastructure/**'

jobs:
  release:
    uses: zeeshan-maqbool/gha-workflows/.github/workflows/release.yml@main
    with:
      runs_on: 2uinc-mgmt
      config_file: 'config/release-please-config.json'
      manifest_file: 'config/.release-please-manifest.json'
      app_id: ${{ vars.RELEASE_APP_ID }}
    secrets:
      private_key: ${{ secrets.RELEASE_APP_PRIVATE_KEY }}
```

## Permissions Required

- `contents: write` - Required to create GitHub releases and tags
- `pull-requests: write` - Required to create and update Release PRs

## Dependencies

- [actions/checkout@v4](https://github.com/actions/checkout)
- [actions/create-github-app-token@v1](https://github.com/actions/create-github-app-token)
- [actions/setup-node@v4](https://github.com/actions/setup-node)
- [Release Please](https://github.com/googleapis/release-please) - Installed via NPX
