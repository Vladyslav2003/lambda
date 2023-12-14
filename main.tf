terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
    access_key = "***********"
    secret_key = "***********"
}

# module "lambda_function_existing_package_local" {
#   source = "terraform-aws-modules/lambda/aws"

#   function_name = "lambda_function_name"
#   description   = "My awesome lambda function"
#   handler       = "index.lambda_handler"
#   runtime       = "python3.8"

#   create_package         = false
#   local_existing_package = "hello.zip"
# }

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
  source_file = "lambda/app/hello.py"
  output_path = "hello.zip"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
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