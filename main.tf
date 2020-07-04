provider "aws" {
  region = "ap-southeast-2"
  shared_credentials_file = "/Users/gavanlamb/.aws/Credentials"
  profile = "haplo"
}

terraform {
  backend "s3" {
    bucket = "haplo-terraform-remote-state"
    dynamodb_table = "haplo-terraform-remote-state-lock"
    key = "state"
    region = "ap-southeast-2"
    shared_credentials_file = "/Users/gavanlamb/.aws/Credentials"
    profile = "haplo"
  }
}

resource "aws_s3_bucket" "serverless-repository" {
  bucket = "d253-serverless-repository"
  acl    = "private"

  tags = {
    Name = "serverless repository"
    Company = "haplo"
    Environment = "cicd"
    service = "cicd"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "serverless-repository" {
  name = "serverless-repository-policy"
  path = "/cicd/"
  description = "IAM policy for putting an object in a bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
	  "Action": ["s3:PutObject"],
      "Resource": "${aws_s3_bucket.serverless-repository.arn}/*",
  	  "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_group" "serverless-repository" {
  name = "lambda-artifact"
  path = "/cicd/"
}

resource "aws_iam_group_policy_attachment" "test-terraform_remote_state" {
  group = aws_iam_group.serverless-repository.name
  policy_arn = aws_iam_policy.serverless-repository.arn
}

output "serverless-repository" {
  value = aws_s3_bucket.serverless-repository.bucket
}
