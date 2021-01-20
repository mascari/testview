import requests
import pytest
from config import URL_BACKEND


class TestFiles:
    url_projects = URL_BACKEND + '/project'
    url_repositories = URL_BACKEND + '/repository'
    url_files = URL_BACKEND + '/files'
    repo_url = 'https://github.com/csnoboa/public_test.git'

    def test_get_files(self):
        # Create a project to use
        obj = {"project_name": "pytest_repo"}
        response = requests.post(self.url_projects, json= obj)

        # Create a repository
        obj = {"project_name": "pytest_repo", "repository_name": "public_test", "url": "https://github.com/csnoboa/public_test.git" }
        response = requests.post(self.url_repositories, json= obj)
        assert response.status_code == 201

        # Get the files
        response = requests.get(self.url_files + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201

        assert 'README.md' not in response.text
        assert 'test.py' in response.text

        # Delete the repository created
        response = requests.delete(self.url_repositories + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201

        # Delete the project
        response = requests.delete(self.url_projects + '?project_name=pytest_repo')
        assert response.status_code == 201
