# Install yq GitHub Action

This GitHub Action installs and verifies the Python-based `yq` utility, which is a command-line YAML processor using jq-like syntax. This action specifically installs the Python version of yq (<https://github.com/kislyuk/yq>), not the Go-based version.
This is so we can use both jq and yq queries interchangeably; the python yq uses jq-like syntax.

## Purpose

The action ensures that:

1. The Python version of `yq` is installed and available in the PATH
2. The installation is verified to be the correct version (Python-based, not Go-based)
3. A consistent version is used across your workflows

This action is particularly useful for GitOps workflows and other processes that require YAML file manipulation.

## Important Note

There are two different tools named `yq`:

1. **Python yq** (<https://github.com/kislyuk/yq>) - This is what this action installs
2. Go-based yq (<https://github.com/mikefarah/yq>) - This is NOT what this action installs

The Python version uses jq-like syntax and is designed to work with YAML files similarly to how jq works with JSON.

## Inputs

| Name              | Description                                                       | Required | Default       |
| ----------------- | ----------------------------------------------------------------- | -------- | ------------- |
| `version`         | Specific version of Python yq to install (omit to install latest) | No       | `''`          |
| `install_command` | Custom installation command if needed                             | No       | `pip install` |

## Outputs

| Name         | Description             | Example |
| ------------ | ----------------------- | ------- |
| `yq_version` | Installed version of yq | `3.1.0` |

## How It Works

The action:

1. Checks if `yq` is already installed and is the Python version
2. If not installed or wrong version, installs the Python version of `yq` using pip
3. Verifies the installation is the correct version
4. Outputs the installed version for reference

## Basic Usage Example

```yaml
jobs:
  process-yaml:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install yq
        uses: 2uinc/gha-workflows/.github/actions/install-yq@main
      
      - name: Use yq to process YAML
        run: |
          # Extract a value from a YAML file
          VALUE=$(yq -r '.apps[0].name' gitops.yaml)
          echo "First app name: $VALUE"
```

## Example with Specific Version

```yaml
jobs:
  process-yaml:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install specific yq version
        uses: 2uinc/gha-workflows/.github/actions/install-yq@main
        with:
          version: '3.0.2'
      
      - name: Use yq to process YAML
        run: |
          # Process a YAML file
          yq -r '.apps[] | select(.name == "my-app") | .revision' gitops.yaml
```

## Permissions Required

No special permissions required.

## Dependencies

- Python and pip must be available on the runner
