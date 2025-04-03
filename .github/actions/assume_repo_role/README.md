# Assume Repo Role GitHub Action

This GitHub Action is designed to assume an AWS IAM role based on the repository name. It configures AWS credentials for subsequent steps in the workflow, enabling seamless AWS service integration.

Repo roles can be created and updated @ [2uinc/tf-aws-organization/gha-aws-auth/repo_roles](https://github.com/2uinc/tf-aws-organization/tree/main/gha-aws-auth/repo_roles)
Simply drop an IAM Policy JSON file named after your repo in your AWS Account-Named Folder.

## Purpose

The action provides a standardized way to:

1. Determine the appropriate IAM role based on the repository name
2. Fetch role ARNs from AWS Secrets Manager
3. Assume the IAM role using AWS STS
4. Configure GitHub workflow environment with AWS credentials

## Required Inputs

| Name         | Description                                 | Required | Default     |
| ------------ | ------------------------------------------- | -------- | ----------- |
| `AWS_REGION` | The AWS region to use for all AWS API calls | Yes      | `us-east-1` |

## Optional Inputs

| Name               | Description                                                                          | Required | Default              |
| ------------------ | ------------------------------------------------------------------------------------ | -------- | -------------------- |
| `AWS_ACCOUNT_NAME` | AWS Account identifier to deploy to, used to look up appropriate role ARN in secrets | No       | `corp-delivery-prod` |

## How It Works

The action performs the following steps:

1. Extracts the repository name from `GITHUB_REPOSITORY` environment variable
2. Converts the repository name to uppercase and replaces hyphens with underscores to form an environment variable name
3. Retrieves the IAM role ARN from AWS Secrets Manager using the converted repo name
4. Configures the AWS credentials for use in subsequent workflow steps

## AWS Secrets Manager Structure

The action expects a secret in AWS Secrets Manager with the name `{AWS_ACCOUNT_NAME}/gha-aws-auth` containing key-value pairs mapping repository names (in uppercase with underscores) to role ARNs.

For example:

```json
{
  "MY_REPO_NAME": "arn:aws:iam::123456789012:role/my-repo-role",
  "ANOTHER_REPO": "arn:aws:iam::123456789012:role/another-repo-role"
}
```

## Permissions Required

- `id-token: write` - Required for OIDC AWS authentication
- AWS Secrets Manager read permissions for the secret `{AWS_ACCOUNT_NAME}/gha-aws-auth`

## Basic Usage Example

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: zeeshan-maqbool/gha-workflows/.github/actions/assume_repo_role@main
        with:
          AWS_REGION: 'us-west-2'
          AWS_ACCOUNT_NAME: 'my-aws-account'

      - name: Deploy with AWS CLI
        run: |
          aws s3 sync ./build s3://my-bucket/
```

## Dependencies

- [aws-actions/aws-secretsmanager-get-secrets@v2](https://github.com/aws-actions/aws-secretsmanager-get-secrets)
- [aws-actions/configure-aws-credentials@main](https://github.com/aws-actions/configure-aws-credentials)
