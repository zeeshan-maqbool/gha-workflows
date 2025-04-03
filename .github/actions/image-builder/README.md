# Image Builder GitHub Action

This GitHub Action builds and pushes Docker images to Amazon ECR with integrated security scanning. It handles repository creation, vulnerability scanning with Trivy, and proper image tagging.

## Purpose

The action provides end-to-end Docker image building capabilities:

1. Creation/configuration of ECR repositories with appropriate policies
2. Multi-architecture image building with Docker Buildx
3. Vulnerability scanning via Trivy
4. Conditional publishing based on scan results
5. Support for AWS Secrets Manager integration
6. Repository caching for faster builds

## Required Inputs

| Name         | Description                                        | Required | Default |
| ------------ | -------------------------------------------------- | -------- | ------- |
| `RUNS_ON`    | GitHub runner to use for the job                   | Yes      |         |
| `AWS_REGION` | AWS region for ECR repository and AWS API calls    | Yes      |         |
| `REPO_NAME`  | ECR repository name where the image will be stored | Yes      |         |
| `IMAGE_TAG`  | Image tag to apply to the built image              | Yes      |         |

## Optional Inputs

| Name                         | Description                                                 | Required | Default                             |
| ---------------------------- | ----------------------------------------------------------- | -------- | ----------------------------------- |
| `AWS_ACCOUNT_NAME`           | AWS account from which to pull ECR credentials              | No       | `corp-delivery-prod`                |
| `REPO_POLICY`                | ECR repository policy file or JSON string                   | No       |                                     |
| `LIFECYCLE_POLICY_FILE`      | ECR lifecycle policy JSON file                              | No       | `default-ecr-lifecycle-policy.json` |
| `CONTEXT`                    | Docker build context directory                              | No       | `.`                                 |
| `IMAGE_FILE`                 | Path to the Dockerfile relative to the context              | No       | `Dockerfile`                        |
| `BUILD_SECRETS_NAME`         | AWS Secrets Manager secret to load as environment variables | No       |                                     |
| `BUILD_SECRETS_OUTPUT_PATH`  | Path to output secrets file                                 | No       |                                     |
| `BUILD_ARGS`                 | Docker build arguments (ARG=value,ARG2=value2)              | No       | `''`                                |
| `PLATFORMS`                  | Build platforms in Docker format                            | No       | `linux/amd64`                       |
| `PUSH_IMAGE`                 | Whether to push the final image                             | No       | `false`                             |
| `CHECKOUT_SUBMODULES`        | Checkout submodules strategy                                | No       | `''`                                |
| `ALLOW_VULNERABILITIES`      | Allow vulnerabilities in scan                               | No       | `false`                             |
| `SKIP_SESSION_TAGGING`       | Skip AWS session tagging for assumed role                   | No       | `true`                              |
| `USE_ROLE_CHAINING`          | Use AWS role chaining for credential management             | No       | `true`                              |
| `ACTIONS_RUNNER_APP_ID`      | GitHub App ID for private repo access                       | No       |                                     |
| `ACTIONS_RUNNER_PRIVATE_KEY` | GitHub App private key for private repo access              | No       |                                     |

## Outputs

| Name             | Description                                                  | Example                                                |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------ |
| `image_uri`      | The full URI of the built image including repository and tag | `12345.dkr.ecr.us-west-2.amazonaws.com/my-repo:v1.0.0` |
| `repository_uri` | The ECR repository URI without the tag                       | `12345.dkr.ecr.us-west-2.amazonaws.com/my-repo`        |
| `image_digest`   | The content-addressable digest of the built image            | `sha256:abcdef...`                                     |

## How It Works

The action performs these steps:

1. Checks for repository secrets and sets up the environment
2. Clones the repository (with submodules if specified)
3. Configures AWS credentials for ECR access
4. Sets up QEMU and Docker Buildx for multi-architecture builds
5. Creates the ECR repository if it doesn't exist
6. Loads secrets from AWS Secrets Manager if specified
7. Builds and tags the Docker image with a `scan-` prefix
8. Runs Trivy vulnerability scanning on the image
9. If `PUSH_IMAGE` is true and scanning passes, promotes the image by retagging it without the `scan-` prefix
10. Sets output variables for subsequent workflow steps

## Security Features

- **Vulnerability Scanning**: Uses Trivy to scan for critical vulnerabilities before pushing the final image
- **Policy Management**: Applies repository and lifecycle policies to ECR repositories
- **Secret Management**: Integrates with AWS Secrets Manager for secure handling of build secrets

## Basic Usage Example

```yaml
jobs:
  build-image:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build and Push Docker Image
        uses: zeeshan-maqbool/gha-workflows/.github/actions/image-builder@main
        with:
          RUNS_ON: ubuntu-latest
          AWS_REGION: us-west-2
          REPO_NAME: my-app
          IMAGE_TAG: ${{ github.sha }}
          PUSH_IMAGE: true
```

## Advanced Example with Multi-Architecture and Build Args

```yaml
jobs:
  build-image:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: Build and Push Multi-Architecture Image
        uses: zeeshan-maqbool/gha-workflows/.github/actions/image-builder@main
        with:
          RUNS_ON: ubuntu-latest
          AWS_REGION: us-west-2
          AWS_ACCOUNT_NAME: degrees-prod
          REPO_NAME: ops/my-service
          IMAGE_TAG: v1.2.3
          PLATFORMS: linux/amd64,linux/arm64
          BUILD_ARGS: NODE_ENV=production,VERSION=${{ github.sha }}
          BUILD_SECRETS_NAME: my-app/build-secrets
          PUSH_IMAGE: true
          ALLOW_VULNERABILITIES: false
```

## Example with Private Dependencies

```yaml
jobs:
  build-image:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Build Image with Private Repos
        uses: zeeshan-maqbool/gha-workflows/.github/actions/image-builder@main
        with:
          RUNS_ON: ubuntu-latest
          AWS_REGION: us-west-2
          REPO_NAME: my-app
          IMAGE_TAG: ${{ github.sha }}
          CHECKOUT_SUBMODULES: true
          ACTIONS_RUNNER_APP_ID: ${{ secrets.ACTIONS_RUNNER_APP_ID }}
          ACTIONS_RUNNER_PRIVATE_KEY: ${{ secrets.ACTIONS_RUNNER_PRIVATE_KEY }}
          PUSH_IMAGE: true
```

## Dependencies

- [actions/checkout@v4](https://github.com/actions/checkout)
- [actions/create-github-app-token@v1](https://github.com/actions/create-github-app-token)
- [aws-actions/configure-aws-credentials@main](https://github.com/aws-actions/configure-aws-credentials)
- [aws-actions/amazon-ecr-login@v2.0.1](https://github.com/aws-actions/amazon-ecr-login)
- [int128/create-ecr-repository-action@v1.308.0](https://github.com/int128/create-ecr-repository-action)
- [docker/setup-qemu-action@v3](https://github.com/docker/setup-qemu-action)
- [docker/setup-buildx-action@v3.1.0](https://github.com/docker/setup-buildx-action)
- [docker/metadata-action@v5](https://github.com/docker/metadata-action)
- [docker/build-push-action@v5.2.0](https://github.com/docker/build-push-action)
- [aquasecurity/trivy-action@0.28.0](https://github.com/aquasecurity/trivy-action)
- [say8425/aws-secrets-manager-actions@v2](https://github.com/say8425/aws-secrets-manager-actions)

## Permissions Required

- `id-token: write` - Required for OIDC AWS authentication
- `contents: read` - Required to checkout the repository
