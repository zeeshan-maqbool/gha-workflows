module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "gha-workflows"
  versioning = {
    enabled = true
  }
  attach_policy = true
  policy        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS":"arn:aws:iam::823386275404:role/gha-image-builder"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::gha-workflows",
                "arn:aws:s3:::gha-workflows/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_object" "ecr_lifecycle_policy" {
  bucket  = module.s3_bucket.s3_bucket_id
  key     = "ecr/default-ecr-lifecycle-policy.json"
  content = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 30 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["scan-", "cache-", "pr-"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

moved {
  from = aws_s3_object.ecr_repo_policy
  to   = aws_s3_object.ecr_lifecycle_policy
}

data "aws_organizations_organization" "default" {
    provider = aws.org
}

resource "aws_s3_object" "ecr_permissions_policy" {
  for_each = { for k, v in data.aws_organizations_organization.default.accounts : k => v }
  bucket  = module.s3_bucket.s3_bucket_id
  key     = "ecr/${each.value.name}-ecr-repo-policy.json"
  content = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "allow ${each.value.name} account",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::${each.value.id}:root"
        ]
      },
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:ListImages"
      ]
    }
  ]
}
EOF
}
