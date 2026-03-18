import boto3
import os
from datetime import datetime

s3 = boto3.client("s3")

def lambda_handler(event, context):

    bucket = os.environ["BUCKET_NAME"]

    filename = f"file-{datetime.utcnow().isoformat()}.txt"

    s3.put_object(
        Bucket=bucket,
        Key=filename,
        Body="arquivo criado automaticamente"
    )

    return {
        "statusCode": 200,
        "file": filename
    }