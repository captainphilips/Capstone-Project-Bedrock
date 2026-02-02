#!/usr/bin/env python3
"""
Lambda handler for Bedrock asset processor.

This function processes uploaded files from S3 and performs:
- File validation
- Metadata extraction
- Asset optimization
"""

import json
import boto3
import logging
from typing import Any, Dict

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client("s3")


def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Handler function for S3 upload events.

    Args:
        event: Lambda event from S3
        context: Lambda context

    Returns:
        Response dictionary with statusCode and body
    """
    try:
        logger.info(f"Received event: {json.dumps(event)}")

        # Extract S3 bucket and key from event
        bucket = event.get("Records", [{}])[0].get("s3", {}).get("bucket", {}).get("name")
        key = event.get("Records", [{}])[0].get("s3", {}).get("object", {}).get("key")

        if not bucket or not key:
            logger.warning("Missing bucket or key in event")
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing bucket or key"}),
            }

        logger.info(f"Processing file: s3://{bucket}/{key}")

        # Get object metadata
        obj = s3_client.head_object(Bucket=bucket, Key=key)
        logger.info(f"Object metadata: {obj['Metadata']}")

        # Process the asset (placeholder for actual logic)
        result = {
            "bucket": bucket,
            "key": key,
            "size": obj.get("ContentLength", 0),
            "content_type": obj.get("ContentType", "unknown"),
            "status": "processed",
        }

        logger.info(f"Processing complete: {json.dumps(result)}")
        return {
            "statusCode": 200,
            "body": json.dumps(result),
        }

    except Exception as e:
        logger.error(f"Error processing asset: {str(e)}", exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
