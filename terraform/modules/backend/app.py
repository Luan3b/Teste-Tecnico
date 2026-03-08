from flask import Flask, jsonify
import boto3
import os

app = Flask(__name__)

s3 = boto3.client("s3")
BUCKET = os.environ.get("BUCKET_NAME")

@app.route("/files")
def list_files():

    response = s3.list_objects_v2(Bucket=BUCKET)

    files = []

    if "Contents" in response:
        for obj in response["Contents"]:
            files.append(obj["Key"])

    return jsonify({
        "total": len(files),
        "files": files
    })

@app.route("/")
def health():
    return {"status": "ok"}

app.run(host="0.0.0.0", port=3000)