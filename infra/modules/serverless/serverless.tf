################################################################################
# S3 Bucket
################################################################################
resource "aws_s3_bucket" "bedrock_assets" {
  bucket = var.assets_bucket_name

  tags = merge(
    var.tags,
    {
      Project = "Bedrock"
    }
  )
}

resource "aws_s3_bucket_ownership_controls" "assets" {
  bucket = aws_s3_bucket.bedrock_assets.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.bedrock_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################################################################
# Lambda IAM Role
################################################################################
resource "aws_iam_role" "lambda_role" {
  name = "project-bedrock-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.tags,
    {
      Project = "Bedrock"
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  # Grants: logs:CreateLogGroup, logs:CreateLogStream, logs:PutLogEvents
}

################################################################################
# Lambda Function
################################################################################
resource "aws_lambda_function" "asset_processor" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = var.lambda_runtime
  filename      = "${path.root}/services/lambda/build/handler.zip"

  tags = merge(
    var.tags,
    {
      Project = "Bedrock"
    }
  )
}

################################################################################
# S3 Event Notification → Lambda
################################################################################
resource "aws_lambda_permission" "s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asset_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bedrock_assets.arn
}

resource "aws_s3_bucket_notification" "assets" {
  bucket = aws_s3_bucket.bedrock_assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.asset_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_trigger]
}