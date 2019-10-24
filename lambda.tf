provider "aws" {
  profile = "${var.aws_credentials_profile}"
  region  = "${var.aws_region}"
}

data "archive_file" "build_code" {
  type        = "zip"
  source_dir  = "code"
  output_path = "code.zip"
}

resource "aws_lambda_function" "example" {
  function_name    = "ServerlessExample"
  filename         = "code.zip"
  source_code_hash = "${data.archive_file.build_code.output_sha}"
  depends_on       = ["data.archive_file.build_code", "aws_cloudwatch_log_group.example"]

  handler = "index.getStatusHandler"
  runtime = "nodejs10.x"

  environment {
    variables = {
      DB_TABLE_NAME = "${aws_dynamodb_table.status_db.id}"
    }
  }

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test_policy" {
  name = "serverless_example_lambda_policy"
  role = "${aws_iam_role.lambda_exec.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.module_name}"
  retention_in_days = 14
}
