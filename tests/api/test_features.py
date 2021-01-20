import requests
import pytest
from config import URL_BACKEND


class TestFeatures:
    url_projects = URL_BACKEND + '/project'
    url_repositories = URL_BACKEND + '/repository'
    url_features = URL_BACKEND + '/features'
    repo_url = 'https://github.com/csnoboa/public_test.git'

    def test_get_features(self):
        # Create a project to use
        obj = {"project_name": "pytest_repo"}
        response = requests.post(self.url_projects, json= obj)

        # Create a repository
        obj = {"project_name": "pytest_repo", "repository_name": "public_test", "url": "https://github.com/csnoboa/public_test.git" }
        response = requests.post(self.url_repositories, json= obj)
        assert response.status_code == 201

        # Get the features (must be empty)
        response = requests.get(self.url_features + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201
        assert '{"data": "[]"}' in response.text

    def test_post_feature(self):

        # Add a feature in the repository
        obj = {"project_name": "pytest_repo", "repository_name" : "public_test", "feature_name": "Home", "number_bugs": 10}
        response = requests.post(self.url_features, json= obj)
        assert response.status_code == 201

        # Add a feature in the repository
        obj = {"project_name": "pytest_repo", "repository_name" : "public_test", "feature_name": "Chat", "number_bugs": 50}
        response = requests.post(self.url_features, json= obj)
        assert response.status_code == 201

        # Add a feature in the repository
        obj = {"project_name": "pytest_repo", "repository_name" : "public_test", "feature_name": "Call Controll", "number_bugs": 1}
        response = requests.post(self.url_features, json= obj)
        assert response.status_code == 201

        # Add a feature in the repository
        obj = {"project_name": "pytest_repo", "repository_name" : "public_test", "feature_name": "Conference", "number_bugs": 0}
        response = requests.post(self.url_features, json= obj)
        assert response.status_code == 201

        # Get the features (must have the features)
        response = requests.get(self.url_features + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201
        assert 'Home' in response.text
        assert 'Chat' in response.text
        assert 'Call Controll' in response.text
        assert 'Conference' in response.text


    def test_delete_feature(self):

        # Delete only one feature
        response = requests.delete(self.url_features + '?project_name=pytest_repo&repository_name=public_test&feature_name=Chat')
        assert response.status_code == 201

        # Get the features (must have all the features unless Chat)
        response = requests.get(self.url_features + '?project_name=pytest_repo&repository_name=public_test')
        assert 'Home' in response.text
        assert 'Chat' not in response.text
        assert 'Call Controll' in response.text
        assert 'Conference' in response.text

        # Delete all features
        response = requests.delete(self.url_features + '?project_name=pytest_repo&repository_name=public_test&feature_name=Conference')
        response = requests.delete(self.url_features + '?project_name=pytest_repo&repository_name=public_test&feature_name=Home')
        response = requests.delete(self.url_features + '?project_name=pytest_repo&repository_name=public_test&feature_name=Call%20Controll')
        assert response.status_code == 201

        # Get the features (must be empty)
        response = requests.get(self.url_features + '?project_name=pytest_repo&repository_name=public_test')
        assert '{"data": "[]"}' in response.text

        # Delete the repository created
        response = requests.delete(self.url_repositories + '?project_name=pytest_repo&repository_name=public_test')
        assert response.status_code == 201

        # Delete the project
        response = requests.delete(self.url_projects + '?project_name=pytest_repo')
        assert response.status_code == 201
