import requests
import pytest
from config import URL_BACKEND

class TestSettingsFiles:
    url_projects = URL_BACKEND + '/project'
    url_settings = URL_BACKEND + '/settingsfiles'

    def test_get(self):
        # Create a project to use
        obj = {"project_name": "pytest_repo"}
        response = requests.post(self.url_projects, json= obj)
        assert response.status_code == 201

        # Get the settings from the project
        response = requests.get(self.url_settings + "?project_name=pytest_repo")
        assert response.status_code == 201

        # Check if the settings is with the default extensions files
        assert '.py' in response.text
        assert '.java' in response.text
        assert '.c' in response.text
        assert '.h' in response.text
        assert '.cpp' in response.text
        assert '.html' in response.text
        assert '.js' in response.text
        assert '.css' in response.text

    def test_add_file(self):
        # Add the .dart extension in settings
        obj = {"project_name": "pytest_repo", "file_extensions" : ".dart"}
        response = requests.post(self.url_settings, json= obj)
        assert response.status_code == 201

        # Get the settings from the project
        response = requests.get(self.url_settings + "?project_name=pytest_repo")
        assert response.status_code == 201

        # Check if the settings have the .dart
        assert '.dart' in response.text

    def test_delete_file(self):
        # Delete the .dart in settings
        response = requests.delete(self.url_settings + '?project_name=pytest_repo&file_extensions=.dart')

        # Get the settings from the project
        response = requests.get(self.url_settings + "?project_name=pytest_repo")
        assert response.status_code == 201

        # Check if the settings is with the altered days
        assert '.dart' not in response.text

        # Check if the settings have all the extensions that have before
        assert '.py' in response.text
        assert '.java' in response.text
        assert '.c' in response.text
        assert '.h' in response.text
        assert '.cpp' in response.text
        assert '.html' in response.text
        assert '.js' in response.text
        assert '.css' in response.text

        # Delete the project
        response = requests.delete(self.url_projects + '?project_name=pytest_repo')
        assert response.status_code == 201