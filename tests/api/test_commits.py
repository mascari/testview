import requests
import pytest
from config import URL_BACKEND


class TestCommits:
    url_projects = URL_BACKEND + '/project'
    url_repositories = URL_BACKEND + '/repository'
    url_settings = URL_BACKEND + '/settings'
    url_commits = URL_BACKEND + '/commits'
    repo_url = 'https://github.com/csnoboa/public_test.git'

    def test_get(self):
        # Create a project to use
        obj = {"project_name": "pytest_repo"}
        response = requests.post(self.url_projects, json= obj)

        # Alter the days in settings to zero
        obj = {"project_name": "pytest_repo", "days_retrieval" : "0"}
        response = requests.post(self.url_settings, json= obj)
        assert response.status_code == 201

        # Create a repository
        obj = {"project_name": "pytest_repo", "repository_name": "public_test", "url": "https://github.com/csnoboa/public_test.git" }
        response = requests.post(self.url_repositories, json= obj)
        assert response.status_code == 201

        # Get the commits (must be empty, because the days_retrieval = 0)
        response = requests.get(self.url_commits + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201

        assert '{"data": "[]"}' in response.text

    def test_put(self):
        # Alter the days in settings to get a commit
        obj = {"project_name": "pytest_repo", "days_retrieval" : "15"}
        response = requests.post(self.url_settings, json= obj)
        assert response.status_code == 201

        # Update the commits
        obj = {"project_name": "pytest_repo", "repository_name": "public_test"}
        response = requests.put(self.url_commits, json= obj)
        assert response.status_code == 201

        # Get the commits (must be have something)
        response = requests.get(self.url_commits + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201

        assert '121bcc4389edb7542d2da8f642996591fad69308' in response.text
        assert 'Initial commit' in response.text
        assert 'Create test.py' in response.text

        # Delete the repository created in the last test
        response = requests.delete(self.url_repositories + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201



    def test_new_repo(self):

        # Create a new repository
        obj = {"project_name": "pytest_repo", "repository_name": "public_test", "url": "https://github.com/csnoboa/public_test.git" }
        response = requests.post(self.url_repositories, json= obj)
        assert response.status_code == 201

        # Get the commits
        response = requests.get(self.url_commits + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201

        assert '121bcc4389edb7542d2da8f642996591fad69308' in response.text
        assert 'Initial commit' in response.text
        assert 'Create test.py' in response.text

        # Delete the repository created in the last test
        response = requests.delete(self.url_repositories + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201

        # Delete the project
        response = requests.delete(self.url_projects + '?project_name=pytest_repo')
        assert response.status_code == 201


