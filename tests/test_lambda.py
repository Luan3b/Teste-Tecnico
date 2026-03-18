import pytest
import boto3
import json
import os
import sys
from moto import mock_aws
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.lambda_function.handler import lambda_handler

class TestLambdaFunction:
    
    @pytest.fixture
    def lambda_context(self):
        """Mock do contexto da Lambda"""
        context = MagicMock()
        context.aws_request_id = "test-request-id"
        return context
    
    @mock_aws
    def test_lambda_handler_success(self, lambda_context):
        """Testa execução bem-sucedida da Lambda"""
        s3 = boto3.client('s3', region_name='us-east-1')
        s3.create_bucket(Bucket='test-bucket')
        
        event = {}
        
        with patch.dict(os.environ, {
            "BUCKET_NAME": "test-bucket",
            "AWS_ACCESS_KEY_ID": "testing",
            "AWS_SECRET_ACCESS_KEY": "testing",
            "AWS_SECURITY_TOKEN": "testing",
            "AWS_SESSION_TOKEN": "testing",
            "AWS_DEFAULT_REGION": "us-east-1"
        }):
            result = lambda_handler(event, lambda_context)
        
        assert result["statusCode"] == 200
        assert "file" in result["body"]
        assert result["body"]["message"] == "File created successfully"
        
        response = s3.list_objects_v2(Bucket='test-bucket')
        assert 'Contents' in response
        assert len(response['Contents']) == 1
    
    @mock_aws
    def test_lambda_handler_missing_bucket(self, lambda_context):
        """Testa erro quando BUCKET_NAME não está configurado"""
        event = {}
        
        result = lambda_handler(event, lambda_context)
        
        assert result["statusCode"] == 500
        assert "error" in result["body"]
        assert "BUCKET_NAME environment variable not set" in result["body"]["error"]
    
    @mock_aws
    def test_lambda_handler_s3_error(self, lambda_context):
        """Testa erro quando S3 falha"""
        event = {}
        
        with patch('boto3.client') as mock_boto3:
            mock_s3 = MagicMock()
            mock_s3.put_object.side_effect = Exception("S3 error")
            mock_boto3.return_value = mock_s3
            
            with patch.dict(os.environ, {"BUCKET_NAME": "test-bucket"}):
                result = lambda_handler(event, lambda_context)
            
            assert result["statusCode"] == 500
            assert "error" in result["body"]