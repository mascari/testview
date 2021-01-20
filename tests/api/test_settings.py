import requests
import pytest
from config import URL_BACKEND

class TestSettings:
    url_projects = URL_BACKEND + '/project'
    url_settings = URL_BACKEND + '/settings'

    def test_get(self):
        # Create a project to use
        obj = {"project_name": "pytest_repo"}
        response = requests.post(self.url_projects, json= obj)
        assert response.status_code == 201

        # Get the settings from the project
        response = requests.get(self.url_settings + "?project_name=pytest_repo")
        assert response.status_code == 201

        # Check if the settings is with the default days
        assert '{"data": "30"}' in response.text

    def test_alter_days(self):
        # Alter the days in settings
        obj = {"project_name": "pytest_repo", "days_retrieval" : "60"}
        response = requests.post(self.url_settings, json= obj)
        assert response.status_code == 201

        # Get the settings from the project
        response = requests.get(self.url_settings + "?project_name=pytest_repo")
        assert response.status_code == 201

        # Check if the settings is with the altered days
        assert "60" in response.text

        # Delete the project
        response = requests.delete(self.url_projects + '?project_name=pytest_repo')
        assert response.status_code == 201