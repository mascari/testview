from flask_restful import Resource
from flask import request
from modelsFolder.model_Reports import Reports
import json

class Report(Resource):
    # get all the project's commits
    def get(self):
        print('GET Report')
        args = request.args
        if not args:
            return {'message': 'No input data provided'}, 400
        project_name = args['project_name']
        repository_name = args['repository_name']

        result = Reports.get_report(project_name, repository_name)
        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        return { "status": 'success', 'data': result }, 201
        
    def post(self):
        json_data = request.get_json(force=True)
        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400
        # get the input
        project_name = json_data['project_name']
        repository_name = json_data['repository_name']
        date = json_data['date']
        result = Reports.create_report(project_name, repository_name, date)
        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        return result, 201



