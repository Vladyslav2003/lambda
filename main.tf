terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "hello.py"
  output_path = "hello.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "hello.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256


  environment {
    variables = {
      foo = "bar"
    }
  }
}

variable "access_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}
