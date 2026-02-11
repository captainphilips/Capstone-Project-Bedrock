################################################################################
# Serverless Module - Lambda
################################################################################
# Validate Lambda zip exists before creating resources
resource "null_resource" "validate_lambda_zip" {
  lifecycle {
    precondition {
      condition     = fileexists(var.lambda_zip_path)
      error_message = "Lambda zip not found at ${var.lambda_zip_path}. Run: python3 scripts/package_lambda_handler.py (from repo root)"
    }
  }
}

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
      Project = "Bedrock-Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch log group for Lambda with retention (completes logging setup)
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.lambda_log_retention_days
  tags              = merge(var.tags, { Name = "/aws/lambda/${var.function_name}" })
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  runtime       = "python3.10"
  handler       = "handler.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = var.lambda_zip_path

  depends_on = [null_resource.validate_lambda_zip]

  tags = merge(
    var.tags,
    { Name = var.function_name },
    var.vpc_id != null ? { VpcId = var.vpc_id, VpcName = "project-bedrock-vpc" } : {}
  )
}

resource "aws_s3_bucket" "assets" {
  bucket = var.assets_bucket_name

  tags = merge(
    var.tags,
    { Name = "project-bedrock-assets" },
    var.vpc_id != null ? { VpcId = var.vpc_id, VpcName = "project-bedrock-vpc" } : {}
  )
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets.arn
}

resource "aws_s3_bucket_notification" "assets" {
  bucket = aws_s3_bucket.assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
