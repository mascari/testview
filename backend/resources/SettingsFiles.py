from flask_restful import Resource
from flask import request
import json
from modelsFolder.model_SettingsFiles import ModelSettingsFiles

class SettingsFiles(Resource):
    
    def get(self):
        args = request.args
        if not args:
            return {'message': 'No input data provided'}, 400
        project_name = args['project_name']

        result = ModelSettingsFiles.get_file_extensions(project_name)

        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        return { "data" : result}, 201
        

    def post(self):
        json_data = request.get_json(force=True)

        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = json_data['project_name']
        file_extensions = json_data['file_extensions']

        ModelSettingsFiles.new_file_extensions(project_name, file_extensions)

        # return the new settingsFiles to the client
        return { "status": 'success' }, 201

    def put(self):
        json_data = request.get_json(force=True)

        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = json_data['project_name']
        file_extensions_old = json_data['file_extensions_old']
        file_extensions_new = json_data['file_extensions_new']

        # edit the settingsFiles days retrieval
        ModelSettingsFiles.edit_file_extensions(project_name, file_extensions_old, file_extensions_new)

        # return the new settingsFiles to the client
        return { "status": 'success' }, 201

    def delete(self):
        args = request.args
        if not args:
            return {'message': 'No input data provided'}, 400
        project_name = args['project_name']
        file_extensions = args['file_extensions']

        file_extensions_existing = ModelSettingsFiles.get_file_extensions(project_name)

        if file_extensions not in file_extensions_existing:
            return { "status" : "failed" }, 400

        ModelSettingsFiles.delete_file_extensions(project_name, file_extensions)

        return { "status": 'success' }, 201