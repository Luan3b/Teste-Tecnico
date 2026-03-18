from flask import Flask, jsonify
from flask_cors import CORS
import boto3
import os
import logging
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

s3 = boto3.client("s3")
BUCKET = os.environ.get("BUCKET_NAME")

@app.route("/files", methods=["GET"])
def list_files():
    """Lista todos os arquivos no bucket S3"""
    try:
        logger.info(f"Listing files from bucket: {BUCKET}")
        
        if not BUCKET:
            return jsonify({"error": "BUCKET_NAME not configured"}), 500
            
        response = s3.list_objects_v2(Bucket=BUCKET)
        files = []

        if "Contents" in response:
            for obj in response["Contents"]:
                files.append({
                    "key": obj["Key"],
                    "size": obj["Size"],
                    "last_modified": obj["LastModified"].isoformat()
                })

        return jsonify({
            "total": len(files),
            "files": files
        }), 200
        
    except Exception as e:
        logger.error(f"Error listing files: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route("/files/<path:file_key>", methods=["GET"])
def get_file(file_key):
    """Obtém um arquivo específico do S3"""
    try:
        logger.info(f"Getting file: {file_key} from bucket: {BUCKET}")
        
        if not BUCKET:
            return jsonify({"error": "BUCKET_NAME not configured"}), 500
        
        response = s3.get_object(Bucket=BUCKET, Key=file_key)
        content = response['Body'].read().decode('utf-8')
        
        return jsonify({
            "key": file_key,
            "content": content,
            "size": response['ContentLength']
        }), 200
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'NoSuchKey':
            return jsonify({"error": "File not found"}), 404
        else:
            logger.error(f"ClientError getting file: {str(e)}")
            return jsonify({"error": str(e)}), 500
    except Exception as e:
        logger.error(f"Error getting file: {str(e)}")
        return jsonify({"error": str(e)}), 500

@app.route("/health", methods=["GET"])
@app.route("/", methods=["GET"])
def health():
    """Rota de health check para o ALB"""
    return jsonify({
        "status": "ok",
        "service": "backend",
        "bucket": BUCKET
    }), 200

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=False)
