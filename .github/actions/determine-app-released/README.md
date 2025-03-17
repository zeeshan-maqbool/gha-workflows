# Determine Released App GitHub Action

This GitHub Action determines the application name from a Release-Please-style GitHub release. It handles both standard repository releases and monorepo component releases, validating app names against a GitOps configuration file.

## Purpose

The action serves to:

1. Parse GitHub release names to extract app name and version information
2. Support monorepo patterns with multiple components/apps
3. Distinguish between root app releases (`v1.0.0`) and component releases (`appname:v1.0.0`)
4. Validate app names against a GitOps configuration file
5. Provide standardized outputs for subsequent workflow steps

## Use Cases

This action is particularly useful for:

- Automated promotion workflows that need to identify which application to promote
- Monorepo setups with multiple releasable components
- GitOps workflows that deploy specific applications based on releases
- Maintaining consistent naming between releases and deployments

## Inputs

| Name           | Description                                                     | Required | Default         |
| -------------- | --------------------------------------------------------------- | -------- | --------------- |
| `release-name` | Name of the GitHub release (e.g., "v1.0.0" or "appname:v1.0.0") | Yes      |                 |
| `gitops-file`  | Path to gitops configuration file to validate app names against | No       | `gitops.yaml`   |
| `root-app`     | Override the default root/default app name                      | No       | Repository name |

## Outputs

| Name           | Description                                                        | Example     |
| -------------- | ------------------------------------------------------------------ | ----------- |
| `app_name`     | Name of the app determined from release                            | `my-app`    |
| `release_type` | Type of release: "root" for main app or "component" for nested app | `component` |
| `version`      | Extracted version from the release name                            | `v1.0.0`    |

## How It Works

The action follows these steps:

1. Determines the root app name (from input or repository name)
2. Extracts all unique app names from the GitOps configuration file
3. Analyzes the release name format:
   - If it contains a colon (`appname:v1.0.0`), it's a component release
   - If not (`v1.0.0`), it's a root app release
4. For component releases, validates the app name against the GitOps configuration
5. Sets output variables for app name, release type, and version

## Release Name Format

The action supports two formats:

1. **Root App Release**: `v1.0.0`
   - The version is applied to the repository's main application
2. **Component Release**: `appname:v1.0.0`
   - The version is applied to a specific component/app within a monorepo

## GitOps File Format

The action expects a gitops.yaml file with the following structure:

```yaml
apps:
  - name: app1
    # other properties...
  - name: app2
    # other properties...
```

## Basic Usage Example

```yaml
jobs:
  promote-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Determine released app
        id: app-info
        uses: 2uinc/gha-workflows/.github/actions/determine-app-released@main
        with:
          release-name: ${{ github.event.release.name }}
      
      - name: Promote the released app
        uses: some-promotion-action@v1
        with:
          app-name: ${{ steps.app-info.outputs.app_name }}
          version: ${{ steps.app-info.outputs.version }}
```

## Custom Configuration Example

```yaml
jobs:
  promote-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Determine released app
        id: app-info
        uses: 2uinc/gha-workflows/.github/actions/determine-app-released@main
        with:
          release-name: ${{ github.event.release.name }}
          gitops-file: 'deploy/gitops.yaml'
          root-app: 'main-service'
      
      - name: Conditional processing based on release type
        run: |
          if [ "${{ steps.app-info.outputs.release_type }}" = "component" ]; then
            echo "Processing component release for ${{ steps.app-info.outputs.app_name }}"
          else
            echo "Processing root app release"
          fi
```

## Permissions Required

No special permissions required. The action only processes local files.

## Dependencies

- [2uinc/gha-workflows/.github/actions/install-yq@main](https://github.com/2uinc/gha-workflows/tree/main/.github/actions/install-yq) - For YAML parsing
- Python yq must be installed on the runner
