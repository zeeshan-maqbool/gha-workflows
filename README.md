# Github Actions Workflows

This repository contains various GitHub Actions workflows and custom actions to automate different tasks such as deploying Ansible playbooks, building Docker images, and more.

## Directory Structure

- **`.github/workflows`**: This directory contains the workflow files that define the automated processes for different tasks. Each YAML file in this directory represents a separate workflow.
  - **`ansible.yml`**: Automates deployments of Ansible playbooks and scripts to AWS.
  - **`docker_run.yml`**: Runs Docker container operations.
  - **`image_builder.yml`**: Automates building container images using Buildx and stores them in an Amazon ECR repository.
  - **`scripts.yml`**: Runs custom deployment scripts.

- **`.github/actions`**: This directory contains custom GitHub Actions that can be reused across different workflows.
  - **`assume_repo_role`**: A custom action to assume an AWS IAM role based on the repository name or an alternative role provided as input. It configures AWS credentials for subsequent steps in the workflow.
    - **`action.yml`**: The action definition file for `assume_repo_role`.

## Assume Repo Role GitHub Action

This GitHub Action is designed to assume an AWS IAM role based on the repository name or an alternative role provided as input. It configures AWS credentials for subsequent steps in the workflow.

### Inputs

- **`AWS_REGION`**: The AWS region which you will be deploying in (required, default: `us-east-1`).
- **`AWS_ACCOUNT_NAME`**: The AWS account name to deploy to (optional, default: `corp-delivery-prod`).
- **`AWS_ALTERNATIVE_ROLE`**: An alternative AWS role to assume (optional).
