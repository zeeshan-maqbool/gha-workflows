# Github Actions Workflows

### Ansible
---
This GitHub workflow automates deployments of Ansible playbooks and scripts to AWS. It is triggered by a `workflow_call` event which allows invoking it from other workflows.

### Inputs

The following inputs can be configured:

- `RUNS_ON` - The operating system to run the job on
- `AWS_ROLE` - The AWS role to assume for the deployment
- `AWS_REGION` - The target AWS region
- `SYSTEM_ENVIRONMENT` - The environment being deployed (e.g. prod, staging)
- `DEPLOY_FILE` - An optional Ansible deploy script
- `VARS` - Variables to pass to Ansible
- `PLAYBOOK` - An optional Ansible playbook
- `VERBOSE` - Verbose option for Ansible

### Jobs

The `run_ansible` job performs the following steps:
1. Clones the code repository.
2. Installs dependencies, including Ansible and Node.js.
3. Configures AWS credentials using the provided inputs.

It then executes the deployment process:
- If `DEPLOY_FILE` is set, it runs the provided deploy script.
- If `PLAYBOOK` is provided, it runs the playbook. Variables specified in `VARS` are passed to Ansible.

For playbook executions, it first retrieves the Ansible vault password from AWS Secrets Manager.

### Image Builder
---
This GitHub workflow automates building container images using buildx

### Inputs

The following inputs can be configured:

- `RUNS_ON` - The operating system to run jobs on
- `AWS_ROLE` - The AWS role to assume
- `AWS_REGION` - The target AWS region
- `REPO_NAME` - The ECR repository name
- `IMAGE_FILE` - The Dockerfile path (default `Dockerfile`)
- `IMAGE_TAG` - The image tag
- `PLATFORMS` - OS/architectures to build for
- `PUSH_IMAGE` - Whether to push to ECR (default `false`)

### Jobs

The `build_and_push` job performs the following steps:
1. Clones the repository.
2. Configures AWS credentials.
3. Builds the image for each specified platform.
4. Optionally pushes the images to ECR.

The use of a matrix strategy allows for building across multiple platforms in parallel.

This workflow provides a standardized process for building Docker images from source code, with customization options for different repositories or configurations through the inputs.
