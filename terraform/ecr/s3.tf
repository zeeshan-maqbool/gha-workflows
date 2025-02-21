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

resource "aws_s3_object" "ecr_repo_policy" {
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
