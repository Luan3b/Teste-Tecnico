import boto3
from datetime import datetime
import os

s3 = boto3.client("s3")

def lambda_handler(event, context):
    bucket_name = os.environ["BUCKET_NAME"]

    now = datetime.utcnow().strftime("%Y-%m-%d_%H-%M-%S")
    file_name = f"{now}.txt"

    s3.put_object(
        Bucket=bucket_name,
        Key=file_name,
        Body=f"Arquivo gerado em {now}"
    )

    return {
        "statusCode": 200,
        "body": f"Arquivo {file_name} criado com sucesso"
    }