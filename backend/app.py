from flask import Blueprint
from flask_restful import Api
from resources.Project import Project
from resources.Repository import Repository
from resources.Commit import Commit
from resources.File import File
from resources.Feature import Feature
from resources.Association import Association
from resources.Author import Author
from resources.Server import Server
from resources.Settings import Settings
from resources.SettingsFiles import SettingsFiles
from resources.Report import Report

api_bp = Blueprint('api/', __name__)
api = Api(api_bp)

# Route
api.add_resource(Server, '/')
api.add_resource(Project, '/project')
api.add_resource(Repository, '/repository')
api.add_resource(Commit, '/commits')
api.add_resource(File, '/files')
api.add_resource(Feature, '/features')
api.add_resource(Association, '/associations')
api.add_resource(Author, '/authors')
api.add_resource(Settings, '/settings')
api.add_resource(SettingsFiles, '/settingsfiles')
api.add_resource(Report, '/reports')

from flask import Flask
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

from app import api_bp
app.register_blueprint(api_bp, url_prefix='/api')


if __name__ == "__main__":
    app.run(debug = True)