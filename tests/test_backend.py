import pytest
import json
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