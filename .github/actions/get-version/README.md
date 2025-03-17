# Get Version GitHub Action

This GitHub Action extracts version information from pull requests in two ways:

1. For Release-Please-style PRs (with `autorelease: pending` label), it extracts the version number from the last word in the PR title
2. For regular PRs, it generates a version based on the PR number

This action is useful for generating version tags for Docker images, release artifacts, and preview environments.

## Purpose

The action serves to:

1. Detect whether a PR is a release PR or a regular PR
2. Extract semantic version numbers from Release-Please PR titles
3. Generate consistent version tags for non-release PRs
4. Provide version information for subsequent workflow steps

## Inputs

| Name            | Description                                                               | Required | Default                |
| --------------- | ------------------------------------------------------------------------- | -------- | ---------------------- |
| `pr_title`      | Pull request title to extract version from                                | No       | Current PR title       |
| `pr_number`     | Pull request number to use if no release version is found                 | No       | Current PR number      |
| `pr_labels`     | JSON array of pull request labels                                         | No       | Current PR labels      |
| `release_label` | Label that indicates a release PR (for Release Please)                    | No       | `autorelease: pending` |
| `prefix`        | Prefix to add to PR-based versions (only applies to non-release versions) | No       | `pr-`                  |

## Outputs

| Name          | Description                                                               | Example            |
| ------------- | ------------------------------------------------------------------------- | ------------------ |
| `tag`         | The extracted or generated version tag                                    | `1.2.3` or `pr-42` |
| `is_release`  | Boolean indicating if this is a release PR (true) or a regular PR (false) | `true`             |
| `raw_version` | The raw extracted version without any modifications                       | `1.2.3`            |

## How It Works

The action takes these steps:

1. Examines the PR labels to determine if it's a release PR (has the specified release label)
2. For release PRs:
   - Extracts the version number from the last word in the PR title
   - Sets `is_release` to `true`
3. For non-release PRs:
   - Creates a version tag using the PR number with the specified prefix
   - Sets `is_release` to `false`
4. Sets output variables for use in subsequent workflow steps

## Release-Please Integration

This action is designed to work with [Release Please](https://github.com/googleapis/release-please), which:

1. Creates PRs with titles containing the new version number (e.g., "chore: release 1.2.3")
2. Adds the `autorelease: pending` label to these PRs
3. Manages version numbers based on conventional commits

## Basic Usage Example

```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Get version
        id: version
        uses: 2uinc/gha-workflows/.github/actions/get-version@main
      
      - name: Build and tag Docker image
        uses: docker/build-push-action@v5
        with:
          tags: myapp:${{ steps.version.outputs.tag }}
```

## Example with Custom Release Label

```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Get version
        id: version
        uses: 2uinc/gha-workflows/.github/actions/get-version@main
        with:
          release_label: 'release-pr'
          prefix: 'dev-'
      
      - name: Conditional steps based on PR type
        run: |
          if [[ "${{ steps.version.outputs.is_release }}" == "true" ]]; then
            echo "Building release version ${{ steps.version.outputs.tag }}"
            # Additional release-specific steps
          else
            echo "Building development version ${{ steps.version.outputs.tag }}"
            # Development-specific steps
          fi
```

## Permissions Required

No special permissions required. The action only processes information already available in the context.
