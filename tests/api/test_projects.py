import requests
import pytest
from config import URL_BACKEND



class TestProjects:
    url = URL_BACKEND + '/project'
    def test_get(self):
        response = requests.get(self.url)
        assert response.status_code == 201

    def test_post(self):
        obj = {"project_name": "pytest_insert"}
        response = requests.post(self.url, json= obj)
        assert response.status_code == 201
        response = requests.get(self.url)
        assert 'pytest_insert' in response.text
        response = requests.delete(self.url + '?project_name=pytest_insert')

    def test_delete(self):
        response = requests.get(self.url)
        if 'pytest_delete' not in response.text:
            obj = {"project_name": "pytest_delete"}
            response = requests.post(self.url, json= obj)
        response = requests.delete(self.url + '?project_name=pytest_delete')
        assert response.status_code == 201
        response = requests.get(self.url)
        assert 'pytest_delete' not in response.text
