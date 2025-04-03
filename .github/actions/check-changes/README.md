# Check Changes GitHub Action

This GitHub Action detects changes in specified source directories for monorepo applications. It is designed to help determine which components of a monorepo have been modified in a pull request, enabling targeted builds and deployments.

## Purpose

The action serves to:

1. Analyze git differences between base and head SHAs
2. Identify which packages or components in a monorepo have changed
3. Output a list of changed packages for use in dynamic matrix builds
4. Provide a boolean flag indicating whether any changes were detected

## Required Dependencies

- The repository must have `jq` and `yq` installed on the runner
- The config file (default: `gitops.yaml`) must exist and be properly formatted

## Inputs

| Name          | Description                                                                                                                      | Required | Default                                                                       |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------------------- |
| `config-file` | Path to configuration file (defaults to gitops.yaml)                                                                             | No       | `gitops.yaml`                                                                 |
| `jq-pattern`  | Pattern to extract package paths. For gitops.yaml: `.apps[].repoPath \| split("/helm")[0] \| if . == "helm" then "." else . end` | No       | `.apps[].repoPath \| split("/helm")[0] \| if . == "helm" then "." else . end` |
| `base-sha`    | Base Git SHA to compare changes against                                                                                          | No       | PR base SHA                                                                   |
| `head-sha`    | Head Git SHA to detect changes                                                                                                   | No       | PR head SHA                                                                   |

## Outputs

| Name          | Description                                                            | Example                             |
| ------------- | ---------------------------------------------------------------------- | ----------------------------------- |
| `src_list`    | JSON array of changed package paths/directory names                    | `["cronjobs/cron1","services/api"]` |
| `app_list`    | JSON array of unique app names (only available when using gitops.yaml) | `["app1","app2"]`                   |
| `has_changes` | Boolean indicating if changes were detected in any monitored package   | `true` or `false`                   |

## How It Works

The action:

1. Reads the configuration file (defaults to `gitops.yaml`)
2. Extracts package paths using the provided pattern
3. For each package path, checks if any files were changed within that directory
4. Constructs JSON arrays of all directories with changes and their corresponding app names
5. Sets appropriate outputs for use in subsequent workflow steps

## Configuration File Format

The action supports both YAML and JSON configuration files. By default, it expects a `gitops.yaml` file with the following structure:

```yaml
apps:
  - name: app1
    repoPath: services/app1/helm
    env: dev
  - name: app2
    repoPath: services/app2/helm
    env: prod
```

## Basic Usage Example

```yaml
jobs:
  check-changes:
    runs-on: ubuntu-latest
    outputs:
      src_list: ${{ steps.check.outputs.src_list }}
      app_list: ${{ steps.check.outputs.app_list }}
      has_changes: ${{ steps.check.outputs.has_changes }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Determine changed sources
        id: check
        uses: zeeshan-maqbool/gha-workflows/.github/actions/check-changes@main

  build-and-push:
    needs: check-changes
    if: needs.check-changes.outputs.has_changes == 'true'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        component: ${{ fromJSON(needs.check-changes.outputs.src_list) }}
    steps:
      - name: Build ${{ matrix.component }}
        run: |
          echo "Building ${{ matrix.component }}"
```

## Using a Custom Configuration File

If you want to use a different configuration file:

```yaml
- name: Determine changed sources
  id: check
  uses: zeeshan-maqbool/gha-workflows/.github/actions/check-changes@main
  with:
    config-file: 'my-config.json'
    jq-pattern: '.components | keys[]'
```

## Permissions Required

- `contents: read` - To checkout repository and compare git differences
