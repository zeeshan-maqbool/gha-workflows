# Github Actions Workflows
### Image Builder

This GitHub Action workflow automates building container images using Buildx, supporting multiple platforms, including ARM and AMD, with QEMU. The built images are stored in an Amazon ECR repository in the delivery account.

### Inputs

The workflow allows the following inputs to be configured:

- **`RUNS_ON`**: Specifies the operating system for running jobs (required).
- **`RUN_ENV`**: The environment in which the workflow is being run (required).
- **`REPO_NAME`**: Name of the Amazon ECR repository where the image will be stored (required).
- **`CONTEXT`**: The build context (default is `.`).
- **`IMAGE_FILE`**: Path to the Dockerfile (default is `Dockerfile`).
- **`IMAGE_TAG`**: Tag for the Docker image (required).
- **`PLATFORMS`**: Specifies the OS and architecture combinations to build the image for (required).
- **`PUSH_IMAGE`**: Boolean flag to determine whether to push the image to ECR (default is `false`).
- **`CHECKOUT_SUBMODULES`**: Option to check out submodules if your project uses them (default is an empty string).
- **`ALLOW_VULNERABILITIES`**: Boolean flag to allow pushing the image to ECR even if vulnerabilities are detected (default is `false`).


### Features

- **Multi-platform builds**: Leverages QEMU to build images for both ARM and AMD platforms.
- **Automated ECR repository creation**: Upon successful build, the workflow automatically creates an ECR repository in the specified delivery account for image storage.

---

### Ansible

This GitHub workflow automates deployments of Ansible playbooks and scripts to AWS. It is triggered by a `workflow_call` event which allows invoking it from other workflows.

#### Inputs

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
