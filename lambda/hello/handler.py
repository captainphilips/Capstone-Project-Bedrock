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
    records = event.get("Records", [])
    for record in records:
        s3_info = record.get("s3", {})
        bucket = s3_info.get("bucket", {}).get("name", "unknown-bucket")
        key = s3_info.get("object", {}).get("key", "")
        filename = unquote_plus(key)
        logger.info("Image received: %s (bucket=%s)", filename, bucket)

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Processed upload event"}),
    }
