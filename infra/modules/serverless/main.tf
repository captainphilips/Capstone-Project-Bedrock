################################################################################
# Serverless Module - Lambda
################################################################################
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(
    var.tags,
    {
      Project = "Bedrock"
    }
  )
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  runtime       = "python3.10"
  handler       = "handler.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/lambda.zip"

  tags = merge(
    var.tags,
    {
      Project = "Bedrock"
    }
  )
}

resource "aws_s3_bucket" "assets" {
  bucket = var.assets_bucket_name

  tags = merge(
    var.tags,
    {
      Project = "Bedrock"
    }
  )
}
