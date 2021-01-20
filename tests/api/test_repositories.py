import requests
import pytest
from config import URL_BACKEND


class TestRepositories:
    url_projects = URL_BACKEND + '/project'
    url_repositories = URL_BACKEND + '/repository'
    repo_url = 'https://github.com/csnoboa/public_test.git'

    def test_get(self):
        # Create a project to use
        obj = {"project_name": "pytest_repo"}
        response = requests.post(self.url_projects, json= obj)

        # Get all the repositories, the status must be 201 and the data must be empty
        response = requests.get(self.url_repositories + '?project_name=pytest_repo')
        assert response.status_code == 201

        assert '{"data": "[]"}' in response.text

    def test_post(self):
        # Create e repository
        obj = {"project_name": "pytest_repo", "repository_name": "public_test", "url": "https://github.com/csnoboa/public_test.git" }
        response = requests.post(self.url_repositories, json= obj)
        assert response.status_code == 201

        # Get all the repositories, the response must contain the repository created
        response = requests.get(self.url_repositories + '?project_name=pytest_repo')
        assert 'public_test' in response.text
        assert 'https://github.com/csnoboa/public_test.git' in response.text

    def test_delete(self):
        # Delete the repository created in the last test
        response = requests.delete(self.url_repositories + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201

        # Get all the repositories, the response must not contain the repository created
        response = requests.get(self.url_repositories + '?project_name=pytest_repo')
        assert 'public_test' not in response.text
        assert 'https://github.com/csnoboa/public_test.git' not in response.text

        # Delete the project
        response = requests.delete(self.url_projects + '?project_name=pytest_repo')
        assert response.status_code == 201

        # Get all the projects and check if the project was deleted
        response = requests.get(self.url_projects)
        assert 'pytest_repo' not in response.text 

