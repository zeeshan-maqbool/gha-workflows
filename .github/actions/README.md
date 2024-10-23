# Assume Repo Role GitHub Action

This GitHub Action is designed to assume an AWS IAM role based on the repository name or an alternative role provided as input. It configures AWS credentials for subsequent steps in the workflow.

## Inputs

- **`AWS_REGION`**: The AWS region which you will be deploying in (required, default: `us-east-1`).
- **`AWS_ACCOUNT_NAME`**: The AWS account name to deploy to (optional, default: `corp-delivery-prod`).
- **`AWS_ALTERNATIVE_ROLE`**: An alternative AWS role to assume (optional).

## Usage

To use this action in your workflow, add the following step:

```yaml
jobs:
  example-job:
    runs-on: ubuntu-latest
    steps:
      - name: Assume Repo Role
        uses: getsmarter/gha-workflows/.github/actions/assume_repo_role@main
        with:
          AWS_REGION: 'us-west-2'
          AWS_ACCOUNT_NAME: 'my-aws-account-name'
