import pytest
import boto3
import json
import os
from moto import mock_aws
from unittest.mock import patch, MagicMock

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
        # Setup
        from app.lambda.handler import lambda_handler
        
        # Criar mock do evento
        event = {}
        
        # Executar
        with patch.dict(os.environ, {"BUCKET_NAME": "test-bucket"}):
            result = lambda_handler(event, lambda_context)
        
        # Verificar
        assert result["statusCode"] == 200
        assert "file" in result["body"]
        assert result["body"]["message"] == "File created successfully"
    
    @mock_aws
    def test_lambda_handler_missing_bucket(self, lambda_context):
        """Testa erro quando BUCKET_NAME não está configurado"""
        from app.lambda.handler import lambda_handler
        
        event = {}
        
        # Executar sem a variável de ambiente
        result = lambda_handler(event, lambda_context)
        
        # Verificar
        assert result["statusCode"] == 500
        assert "error" in result["body"]