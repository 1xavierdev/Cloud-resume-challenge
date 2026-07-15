# Zips the function source at plan/apply time so the deployed code always
# matches what's in lambda/lambda_function.py.
data "archive_file" "visitor_counter" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambda_function.py"
  output_path = "${path.module}/../lambda/function.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "resume-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Built from live account/region data rather than hardcoded values -- keeps
# the account ID out of source control entirely, not just out of the
# committed copies of the plain JSON policy files.
data "aws_iam_policy_document" "lambda_exec" {
  statement {
    sid       = "DynamoDBUpdate"
    effect    = "Allow"
    actions   = ["dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.visitor_count.arn]
  }

  statement {
    sid    = "Logs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/resume-*"]
  }
}

resource "aws_iam_role_policy" "lambda_exec" {
  name   = "resume-lambda-execution-policy"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_exec.json
}

resource "aws_lambda_function" "visitor_counter" {
  function_name    = "resume-visitor-counter"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.visitor_counter.output_path
  source_code_hash = data.archive_file.visitor_counter.output_base64sha256
}

# Resource-based policy that lets API Gateway actually invoke the function --
# separate from the IAM role, which only governs what the function itself can do.
resource "aws_lambda_permission" "apigateway_invoke" {
  statement_id  = "apigateway-invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*/count"
}
