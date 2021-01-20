from flask_restful import Resource
from flask import request
import json
from modelsFolder.model_Settings import ModelSettings

class Settings(Resource):
    
    def get(self):
        args = request.args
        if not args:
            return {'message': 'No input data provided'}, 400
        project_name = args['project_name']

        result = ModelSettings.get_days_retrieval(project_name)

        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        return { "data" : result}, 201
        

    def post(self):
        json_data = request.get_json(force=True)

        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = json_data['project_name']
        days_retrieval = json_data['days_retrieval']

        days_retrieval = int(days_retrieval)
        # edit the settings days retrieval
        ModelSettings.edit_days_retrieval(project_name, days_retrieval)

        # return the new settings to the client
        return { "status": 'success' }, 201