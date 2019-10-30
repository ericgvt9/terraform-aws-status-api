provider "aws" {
  profile = "${var.aws_credentials_profile}"
  region  = "${var.aws_region}"
}

resource "null_resource" "install_code" {
  provisioner "local-exec" {
    command = "git clone https://github.com/Open-Attestation/status-api.git && mv status-api code"
  }
}

resource "null_resource" "install_code_dep" {
  provisioner "local-exec" {
    command = "cd code && npm install --production"
  }
  depends_on = ["null_resource.install_code"]
}

resource "null_resource" "install_cleanup" {
  provisioner "local-exec" {
    when    = "destroy"
    command = "rm code.zip && rm -rf code"
  }
  depends_on = ["aws_lambda_function.get_status_fn", "aws_lambda_function.update_status_fn"]
}

data "archive_file" "build_code" {
  type        = "zip"
  source_dir  = "code"
  output_path = "code.zip"
  depends_on  = ["null_resource.install_code_dep"]
}

resource "aws_lambda_function" "get_status_fn" {
  function_name    = "${var.module_name}_${var.stage}_get_status"
  description      = "Gets status of a document using document id from dynamodb"
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

resource "aws_lambda_function" "update_status_fn" {
  function_name    = "${var.module_name}_${var.stage}_update_status"
  description      = "Updates status of a document using document id in dynamodb"
  filename         = "code.zip"
  source_code_hash = "${data.archive_file.build_code.output_sha}"
  depends_on       = ["data.archive_file.build_code", "aws_cloudwatch_log_group.example"]

  handler = "index.updateStatusHandler"
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
