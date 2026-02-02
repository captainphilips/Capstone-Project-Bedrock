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
    Triggered by S3 upload. Logs the uploaded file name.
    
    Args:
        event: Lambda event from S3
        context: Lambda context
    
    Returns:
        Response dictionary with statusCode and body
    """
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Validate event structure
        if 'Records' not in event or not event['Records']:
            logger.warning("No Records found in event")
            return {
                'statusCode': 400,
                'body': json.dumps('No records in event')
            }
        
        for record in event['Records']:
            try:
                # Extract S3 event details
                s3_info = record.get('s3', {})
                bucket = s3_info.get('bucket', {}).get('name', 'unknown')
                key = s3_info.get('object', {}).get('key', 'unknown')
                
                # Decode URL-encoded key
                key = unquote_plus(key)
                
                logger.info(f"Image received: {key}")
                logger.info(f"Bucket: {bucket}")
                
            except (KeyError, TypeError) as e:
                logger.error(f"Error parsing record: {str(e)}")
                continue
        
        return {
            'statusCode': 200,
            'body': json.dumps('Processing complete')
        }
    
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }

