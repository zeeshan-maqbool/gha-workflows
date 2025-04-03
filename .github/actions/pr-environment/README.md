# PR Environment GitHub Action

This GitHub Action facilitates preview environments for pull requests. It creates or updates PR comments with links to preview environments and adds a label to trigger ArgoCD deployment.

## Purpose

The action serves as a bridge between CI/CD systems and preview environments by:

1. Adding a label to PRs to trigger GitOps deployments via ArgoCD
2. Creating or updating PR comments with preview environment URLs
3. Providing consistent URLs based on PR numbers
4. Skipping preview environments for specific branch patterns (e.g., release branches)

## Required Dependencies

- GitHub Actions API access through `actions/github-script`
- PRs must be configured to allow for label updates from the workflow

## Inputs

| Name                | Description                                                              | Required | Default                                                     |
| ------------------- | ------------------------------------------------------------------------ | -------- | ----------------------------------------------------------- |
| `URL_TEMPLATE`      | URL template for PR environment (use ${PR_NUMBER} as placeholder)        | No       | `https://buildkite-node-app-${PR_NUMBER}.dev.devops.2u.com` |
| `COMMENT_PREFIX`    | Prefix text for the comment to identify and update existing comments     | No       | `Preview environment will be available @`                   |
| `ADD_PREVIEW_LABEL` | Whether to add a preview label to the PR to trigger ArgoCD deployment    | No       | `true`                                                      |
| `LABEL_NAME`        | Name of the label to add to the PR (used for ArgoCD triggers)            | No       | `preview`                                                   |
| `SKIP_BRANCHES`     | Comma-separated list of branch prefixes to skip preview environments for | No       | `promote-,release-please`                                   |

## Outputs

| Name          | Description                                                   | Example                             |
| ------------- | ------------------------------------------------------------- | ----------------------------------- |
| `preview_url` | The generated preview environment URL                         | `https://myapp-123.dev.example.com` |
| `label_added` | Whether the preview label was added (true) or skipped (false) | `true`                              |

## How It Works

The action performs these steps:

1. Checks if the current branch should be skipped based on defined patterns
2. Adds a configurable label to the PR if enabled (used by ArgoCD to trigger deployments)
3. Generates a preview URL based on the provided template and PR number
4. Searches for existing PR comments that match the comment prefix
5. Updates the existing comment if found, or creates a new one
6. Sets output variables for use in subsequent workflow steps

## ArgoCD Integration

This action is designed to work with ArgoCD ApplicationSets that use the pull request generator. The label added by this action serves as a trigger for ArgoCD to deploy the preview environment.

The ApplicationSet should be configured with:

```yaml
generators:
  - pullRequest:
      github:
        labels:
          - preview
```

## Basic Usage Example

```yaml
jobs:
  preview-environment:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - name: Create Preview Environment
        uses: zeeshan-maqbool/gha-workflows/.github/actions/pr_environment@main
```

## Custom URL Example

```yaml
jobs:
  preview-environment:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - name: Create Preview Environment
        uses: zeeshan-maqbool/gha-workflows/.github/actions/pr_environment@main
        with:
          URL_TEMPLATE: 'https://my-app-${PR_NUMBER}.staging.example.com'
          COMMENT_PREFIX: '🚀 Preview deployment available at:'
          LABEL_NAME: 'deploy-preview'
```

## Skip Specific Branches Example

```yaml
jobs:
  preview-environment:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - name: Create Preview Environment
        uses: zeeshan-maqbool/gha-workflows/.github/actions/pr_environment@main
        with:
          SKIP_BRANCHES: 'promote-,release-please,dependabot/'
```

## Permissions Required

- `pull-requests: write` - Required to add labels and comments to pull requests

## Dependencies

- [actions/github-script@v6](https://github.com/actions/github-script) - For GitHub API operations
