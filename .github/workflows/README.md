# GitHub Actions Workflows

This repository contains various GitHub Actions workflows and custom actions to automate different tasks such as deploying Ansible playbooks, building Docker images, and more.

## Directory Structure

- **`.github/workflows`**: This directory contains the workflow files that define the automated processes for different tasks. Each YAML file in this directory represents a separate workflow.
  - **[`ansible.yml`](.github/workflows/ansible.yml)**: Automates deployments of Ansible playbooks and scripts to AWS.
  - **[`docker_run.yml`](.github/workflows/docker_run.yml)**: Manages Docker container operations.
  - **[`image_builder.yml`](.github/workflows/image_builder.yml)**: Automates building container images using Buildx and stores them in an Amazon ECR repository.
  - **[`scripts.yml`](.github/workflows/scripts.yml)**: Runs custom deployment scripts.

- **`.github/actions`**: This directory contains custom GitHub Actions that can be reused across different workflows.
  - **[`assume_repo_role`](.github/actions/assume_repo_role)**: A custom action to assume an AWS IAM role based on the repository name or an alternative role provided as input. It configures AWS credentials for subsequent steps in the workflow.
    - **[`action.yml`](.github/actions/assume_repo_role/action.yml)**: The action definition file for `assume_repo_role`.

## Reusable Workflows

### Ansible Workflow

The [`.github/workflows/ansible.yml`](.github/workflows/ansible.yml) workflow automates the deployment of Ansible playbooks and scripts to AWS.

#### Inputs

- **`RUNS_ON`**: Specifies the operating system for running jobs (required).
- **`AWS_ROLE`**: The AWS role to assume for the deployment (required).
- **`AWS_REGION`**: The target AWS region (required).
- **`DEPLOY_FILE`**: An optional Ansible deploy script (optional).
- **`VARS`**: Variables to pass to Ansible (optional).
- **`PLAYBOOK`**: An optional Ansible playbook (optional).
- **`VERBOSE`**: Verbose option for Ansible (optional).

### Docker Run Workflow

The [`.github/workflows/docker_run.yml`](.github/workflows/docker_run.yml) workflow manages Docker container operations, including building and running Docker containers.

#### Inputs

- **`IMAGE_NAME`**: The name of the Docker image (required).
- **`IMAGE_TAG`**: The tag for the Docker image (required).
- **`DOCKERFILE_PATH`**: The path to the Dockerfile (default: `Dockerfile`).
- **`BUILD_CONTEXT`**: The build context for the Docker image (default: `.`).

### Image Builder Workflow

The [`.github/workflows/image_builder.yml`](.github/workflows/image_builder.yml) workflow automates the process of building container images using Buildx and storing them in an Amazon ECR repository.

#### Inputs

- **`RUNS_ON`**: Specifies the operating system for running jobs (required).
- **`REPO_NAME`**: Name of the Amazon ECR repository where the image will be stored (required).
- **`CONTEXT`**: The build context (default: `.`).
- **`IMAGE_FILE`**: Path to the Dockerfile (default: `Dockerfile`).
- **`IMAGE_TAG`**: Tag for the Docker image (required).
- **`PLATFORMS`**: Specifies the OS and architecture combinations to build the image for (required).
- **`PUSH_IMAGE`**: Boolean flag to determine whether to push the image to ECR (default: `false`).
- **`CHECKOUT_SUBMODULES`**: Option to check out submodules if your project uses them (default: an empty string).
- **`ALLOW_VULNERABILITIES`**: Boolean flag to allow pushing the image to ECR even if vulnerabilities are detected (default: `false`).

### Scripts Workflow

The [`.github/workflows/scripts.yml`](.github/workflows/scripts.yml) workflow runs custom deployment scripts.

#### Inputs

- **`SCRIPT_PATH`**: The path to the script to be executed (required).
- **`ARGS`**: Arguments to pass to the script (optional).

## Usage

To use any of these workflows in your repository, you can reference them in your workflow files. For example, to use the Ansible workflow, you can add the following to your workflow file:

```yaml
jobs:
  deploy:
    uses: getsmarter/gha-workflows/.github/workflows/ansible.yml@main
    with:
      RUNS_ON: 'ubuntu-latest'
      AWS_ROLE: 'arn:aws:iam::123456789012:role/YourRole'
      AWS_REGION: 'us-west-2'
      DEPLOY_FILE: 'deploy.yml'
      VARS: '{"key": "value"}'
      PLAYBOOK: 'playbook.yml'
      VERBOSE: true
