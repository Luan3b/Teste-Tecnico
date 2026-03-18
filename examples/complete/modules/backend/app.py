from flask import Flask, jsonify
from flask_cors import CORS
import boto3
import os

app = Flask(__name__)
# LIBERA O ACESSO PARA O SEU CLOUDFRONT
CORS(app) 

# Configuração do S3
s3 = boto3.client("s3")
BUCKET = os.environ.get("BUCKET_NAME")

# Rota principal para o Dashboard
@app.route("/files")
def list_files():
    try:
        response = s3.list_objects_v2(Bucket=BUCKET)
        files = []

        if "Contents" in response:
            for obj in response["Contents"]:
                files.append(obj["Key"])

        return jsonify({
            "total": len(files),
            "files": files
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ROTA DE HEALTH CHECK (O QUE O ALB PROCURA NA PORTA 5000)
@app.route("/")
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == "__main__":
    # IMPORTANTE: host="0.0.0.0" permite que o Load Balancer te encontre
    app.run(host="0.0.0.0", port=5000)