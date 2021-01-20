import requests
import pytest
from config import URL_BACKEND


class TestFeatures:
    url_projects = URL_BACKEND + '/project'
    url_repositories = URL_BACKEND + '/repository'
    url_features = URL_BACKEND + '/features'
    url_files = URL_BACKEND + '/files'
    url_associations = URL_BACKEND + '/associations'
    repo_url = 'https://github.com/csnoboa/public_test.git'

    def test_get_associations(self):
        # Create a project to use
        obj = {"project_name": "pytest_repo"}
        response = requests.post(self.url_projects, json= obj)

        # Create a repository
        obj = {"project_name": "pytest_repo", "repository_name": "public_test", "url": "https://github.com/csnoboa/public_test.git" }
        response = requests.post(self.url_repositories, json= obj)
        assert response.status_code == 201

        # Get the associations (must be empty)
        response = requests.get(self.url_associations + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201
        assert '{"data": "[]"}' in response.text

    def test_post_associations(self):

        # Add the features in the repository
        obj = {"project_name": "pytest_repo", "repository_name" : "public_test", "feature_name": "Home", "number_bugs": 10}
        response = requests.post(self.url_features, json= obj)
        obj = {"project_name": "pytest_repo", "repository_name" : "public_test", "feature_name": "Chat", "number_bugs": 50}
        response = requests.post(self.url_features, json= obj)

        # Get the features (must have the features)
        response = requests.get(self.url_features + '?project_name=pytest_repo&repository_name=public_test')
        assert 'Home' in response.text
        assert 'Chat' in response.text

        # Get the files (must have test.py)
        response = requests.get(self.url_files + '?project_name=pytest_repo&repository_name=public_test')
        assert 'test.py' in response.text

        # Add a association
        obj = {"project_name": "pytest_repo", "repository_name" : "public_test", "feature_name": "Chat", "file_path": 'test.py'}
        response = requests.post(self.url_associations, json= obj)

        # Get the associations
        response = requests.get(self.url_associations + '?project_name=pytest_repo&repository_name=public_test')
        assert 'test.py' in response.text
        assert 'Chat' in response.text


    def test_delete_feature(self):

        # Delete the association
        response = requests.delete(self.url_associations + '?project_name=pytest_repo&repository_name=public_test&feature_name=Chat&file_path=test.py')
        assert response.status_code == 201

        # Get the associations (must be empty)
        response = requests.get(self.url_associations + '?project_name=pytest_repo&repository_name=public_test')
        assert '{"data": "[]"}' in response.text


        # Delete the repository created
        response = requests.delete(self.url_repositories + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201

        # Delete the project
        response = requests.delete(self.url_projects + '?project_name=pytest_repo')
        assert response.status_code == 201
