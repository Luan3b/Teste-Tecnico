import pytest
import json
import os
import sys
from unittest.mock import patch, MagicMock

# Adicionar o caminho raiz ao PYTHONPATH
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.backend.app import app

@pytest.fixture
def client():
    """Fixture para o cliente de teste do Flask"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_endpoint(client):
    """Testa o endpoint de health check"""
    response = client.get('/health')
    data = json.loads(response.data)
    
    assert response.status_code == 200
    assert data['status'] == 'ok'
    assert data['service'] == 'backend'

def test_root_endpoint(client):
    """Testa o endpoint raiz"""
    response = client.get('/')
    data = json.loads(response.data)
    
    assert response.status_code == 200
    assert data['status'] == 'ok'

def test_list_files_empty_bucket(client):
    """Testa listagem de arquivos quando bucket está vazio"""
    with patch('app.backend.app.s3') as mock_s3:
        with patch('app.backend.app.BUCKET', 'test-bucket'):
            # Mock do S3 retornando bucket vazio
            mock_s3.list_objects_v2.return_value = {}
            
            response = client.get('/files')
            data = json.loads(response.data)
            
            assert response.status_code == 200
            assert data['total'] == 0
            assert data['files'] == []

def test_list_files_with_content(client):
    """Testa listagem de arquivos com conteúdo no bucket"""
    with patch('app.backend.app.s3') as mock_s3:
        with patch('app.backend.app.BUCKET', 'test-bucket'):
            # Mock do S3 retornando arquivos
            mock_s3.list_objects_v2.return_value = {
                'Contents': [
                    {'Key': 'file1.txt', 'Size': 100, 'LastModified': '2024-01-01'},
                    {'Key': 'file2.txt', 'Size': 200, 'LastModified': '2024-01-02'}
                ]
            }
            
            response = client.get('/files')
            data = json.loads(response.data)
            
            assert response.status_code == 200
            assert data['total'] == 2
            assert len(data['files']) == 2
            assert data['files'][0]['key'] == 'file1.txt'
            assert data['files'][1]['key'] == 'file2.txt'

def test_get_specific_file(client):
    """Testa obtenção de um arquivo específico"""
    with patch('app.backend.app.s3') as mock_s3:
        with patch('app.backend.app.BUCKET', 'test-bucket'):
            # Criar um mock para o Body que tenha o método read
            mock_body = MagicMock()
            mock_body.read.return_value = b'conteudo do arquivo'
            
            # Criar um dicionário normal (não MagicMock) para a resposta
            mock_response = {
                'Body': mock_body,
                'ContentLength': 18
            }
            mock_s3.get_object.return_value = mock_response
            
            response = client.get('/files/test.txt')
            data = json.loads(response.data)
            
            assert response.status_code == 200
            assert data['key'] == 'test.txt'
            assert data['content'] == 'conteudo do arquivo'
            assert data['size'] == 18

def test_get_file_not_found(client):
    """Testa erro quando arquivo não existe"""
    with patch('app.backend.app.s3') as mock_s3:
        with patch('app.backend.app.BUCKET', 'test-bucket'):
            # Mock do S3 lançando exceção de arquivo não encontrado
            from botocore.exceptions import ClientError
            
            error_response = {'Error': {'Code': 'NoSuchKey'}}
            mock_s3.get_object.side_effect = ClientError(error_response, 'GetObject')
            
            response = client.get('/files/naoexiste.txt')
            
            assert response.status_code == 404

def test_list_files_error(client):
    """Testa erro na listagem de arquivos"""
    with patch('app.backend.app.s3') as mock_s3:
        with patch('app.backend.app.BUCKET', 'test-bucket'):
            # Mock do S3 lançando exceção
            mock_s3.list_objects_v2.side_effect = Exception("S3 error")
            
            response = client.get('/files')
            data = json.loads(response.data)
            
            assert response.status_code == 500
            assert 'error' in data
