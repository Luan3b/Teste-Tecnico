import boto3
import datetime

s3 = boto3.client("s3")

def lambda_handler(event, context):

    bucket = "files-bucket"

    now = datetime.datetime.now().isoformat()

    filename = f"file-{now}.txt"

    s3.put_object(
        Bucket=bucket,
        Key=filename,
        Body="arquivo criado automaticamente"
    )

    return {
        "statusCode": 200,
        "body": "arquivo criado"
    }