# Validate Helm Chart Environments GitHub Action

This GitHub Action validates Helm chart configurations across different environments, ensuring that charts can be successfully rendered in all target environments. It handles dependency resolution, template validation, and provides detailed feedback on validation failures.

## Purpose

The action serves to:

1. Validate Helm chart configurations before deployment
2. Ensure consistency across multiple environments (dev, staging, production)
3. Detect configuration issues early in the CI/CD pipeline
4. Handle private Helm chart dependencies securely
5. Support GitOps-based deployment workflows

## Required Inputs

| Name        | Description                                                           | Required | Default |
| ----------- | --------------------------------------------------------------------- | -------- | ------- |
| `REPO_PATH` | Path to the Helm chart repository (e.g., helm or services/myapp/helm) | Yes      |         |

## Optional Inputs

| Name                 | Description                                                                             | Required | Default       |
| -------------------- | --------------------------------------------------------------------------------------- | -------- | ------------- |
| `APP_NAME`           | Application name to validate (if not provided, will be determined from REPO_PATH)       | No       |               |
| `GITOPS_FILE`        | Path to gitops configuration file containing app configurations                         | No       | `gitops.yaml` |
| `SHARED_VALUES`      | Override the sharedValues from gitops.yaml (path relative to REPO_PATH)                 | No       |               |
| `ENV`                | Environment identifier to validate (e.g., dev, stg, prd)                                | No       |               |
| `ENV_VALUES`         | Override the environment-specific values file name (path relative to REPO_PATH)         | No       |               |
| `GH_APP_ID`          | GitHub App ID for authentication (required if using private helm dependencies)          | No       |               |
| `GH_APP_PRIVATE_KEY` | GitHub App private key for authentication (required if using private helm dependencies) | No       |               |
| `DEBUG`              | Enable debug output for helm commands                                                   | No       | `false`       |

## Outputs

| Name                | Description                                   | Example         |
| ------------------- | --------------------------------------------- | --------------- |
| `app_name`          | The validated application name                | `my-app`        |
| `environments`      | JSON array of validated environments          | `["dev","stg"]` |
| `validation_result` | Result of the validation (success or failure) | `success`       |

## How It Works

The action performs these steps:

1. Determines the app name from either direct input or by querying the gitops configuration
2. Checks for private helm dependencies and sets up GitHub token-based authentication if needed
3. Extracts environment configurations from the gitops file
4. For each environment:
   - Identifies the repository path, shared values, and environment-specific values
   - Validates that all required files exist
   - Builds helm dependencies
   - Renders the helm templates to verify syntax and chart compatibility
5. Collects validation results and outputs a summary

## GitOps File Format

The action expects a gitops.yaml file with the following structure:

```yaml
apps:
  - name: my-app
    clusterGroup: main
    clusterEnv: dev
    env: dev
    namespace: ops
    revision: 1.2.3
    repoPath: helm
    sharedValues: shared-values.yaml
    values: dev-values.yaml
  - name: my-app
    clusterGroup: main
    clusterEnv: stg
    env: stg
    namespace: ops
    revision: 1.2.3
    repoPath: helm
    sharedValues: shared-values.yaml
    values: stg-values.yaml
```

## Private Helm Dependencies

The action supports private Helm dependencies hosted on GitHub. For private dependencies:

1. Dependencies should be defined in Chart.yaml with GitHub raw URLs
2. The action will authenticate using the provided GitHub App credentials
3. Helm repos will be added with the appropriate authentication

Example Chart.yaml with private dependencies:

```yaml
dependencies:
  - name: web-app
    version: 3.0.0
    repository: "https://raw.githubusercontent.com/your-org/helm-charts/master/incubator/"
```

## Basic Usage Example

```yaml
jobs:
  validate-helm:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate Helm Chart Environments
        uses: zeeshan-maqbool/gha-workflows/.github/actions/validate_helm@main
        with:
          REPO_PATH: "helm"
```

## Example with Private Dependencies

```yaml
jobs:
  validate-helm:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate Helm Chart Environments
        uses: zeeshan-maqbool/gha-workflows/.github/actions/validate_helm@main
        with:
          REPO_PATH: "helm"
          GH_APP_ID: ${{ vars.GITOPS_BOT_APP_ID }}
          GH_APP_PRIVATE_KEY: ${{ secrets.GITOPS_BOT_PRIVATE_KEY }}
```

## Example Validating Specific Environment

```yaml
jobs:
  validate-helm:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate Helm for Staging Only
        uses: zeeshan-maqbool/gha-workflows/.github/actions/validate_helm@main
        with:
          REPO_PATH: "helm"
          ENV: "stg"
          DEBUG: "true"
```

## Example with Custom GitOps File

```yaml
jobs:
  validate-helm:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate Helm Chart Environments
        uses: zeeshan-maqbool/gha-workflows/.github/actions/validate_helm@main
        with:
          REPO_PATH: "helm"
          GITOPS_FILE: "deployment/gitops.yaml"
          APP_NAME: "custom-app-name"
```

## Permissions Required

- `contents: read` - Required to checkout the repository and read Helm chart files

## Dependencies

- [zeeshan-maqbool/gha-workflows/.github/actions/install-yq@main](https://github.com/2uinc/gha-workflows/tree/main/.github/actions/install-yq) - For YAML parsing
- [actions/create-github-app-token@v1](https://github.com/actions/create-github-app-token) - For GitHub App token generation (private dependencies only)
- Helm CLI must be installed on the runner
