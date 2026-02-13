#!/usr/bin/env python3
"""
Lambda handler for Bedrock asset processor.

This function is triggered by S3 upload events and processes uploaded files.
"""

import json
import logging
from urllib.parse import unquote_plus

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """
    Process S3 upload events. Logs to CloudWatch (/aws/lambda/barakat-2025-capstone-bedrock-asset-processor).
    """
    request_id = getattr(context, "aws_request_id", "unknown") if context else "unknown"
    logger.info("Lambda invoked, request_id=%s, event_keys=%s", request_id, list(event.keys()))

    records = event.get("Records", [])
    for record in records:
        s3_info = record.get("s3", {})
        bucket = s3_info.get("bucket", {}).get("name", "unknown-bucket")
        key = s3_info.get("object", {}).get("key", "")
        filename = unquote_plus(key)
        logger.info(
            "S3 event processed: bucket=%s key=%s filename=%s request_id=%s",
            bucket, key, filename, request_id
        )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Processed upload event",
            "recordCount": len(records),
            "requestId": request_id,
        }),
    }
