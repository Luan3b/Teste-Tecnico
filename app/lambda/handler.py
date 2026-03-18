import boto3
import os
import logging
from datetime import datetime

# Configurar logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")

def lambda_handler(event, context):
    """
    Lambda function that creates a daily file in S3
    """
    try:
        # Get bucket name from environment variable
        bucket = os.environ.get("BUCKET_NAME")
        
        if not bucket:
            raise ValueError("BUCKET_NAME environment variable not set")
        
        # Generate filename with current timestamp
        timestamp = datetime.utcnow().isoformat()
        filename = f"daily-file-{timestamp}.txt"
        
        # Create content
        content = f"Arquivo criado automaticamente em {timestamp}\n"
        content += f"Event ID: {context.aws_request_id}\n"
        
        # Upload to S3
        s3.put_object(
            Bucket=bucket,
            Key=filename,
            Body=content.encode('utf-8'),
            ContentType="text/plain"
        )
        
        logger.info(f"Successfully created file: {filename} in bucket: {bucket}")
        
        return {
            "statusCode": 200,
            "body": {
                "message": "File created successfully",
                "file": filename,
                "bucket": bucket,
                "timestamp": timestamp
            }
        }
        
    except Exception as e:
        logger.error(f"Error creating file: {str(e)}")
        return {
            "statusCode": 500,
            "body": {
                "message": "Error creating file",
                "error": str(e)
            }
        }
