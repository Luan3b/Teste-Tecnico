from flask import Flask, jsonify
import boto3
import os

app = Flask(__name__)

s3 = boto3.client("s3")
bucket = os.environ.get("BUCKET_NAME")

@app.route("/files")
def files():

    response = s3.list_objects_v2(Bucket=bucket)

    total = 0

    if "Contents" in response:
        total = len(response["Contents"])

    return jsonify({"total_files": total})


@app.route("/")
def home():
    return jsonify({"status": "backend running"})


app.run(host="0.0.0.0", port=5000)