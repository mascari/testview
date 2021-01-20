from flask_restful import Resource
from flask import request
from modelsFolder.model_Projects import Projects
import json

class Project(Resource):
    
    def get(self):
        result = Projects.get_projects()
        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        return { "data" : result}, 201
        

    def post(self):
        json_data = request.get_json(force=True)

        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = json_data['project_name']

        # create the project
        Projects.new_project(project_name = project_name)

        # return the new project to the client
        return { "status": 'success' }, 201

    # def put(self):
    #     json_data = request.get_json(force=True)

    #     # check if the input exists
    #     if not json_data:
    #         return {'message': 'No input data provided'}, 400

    #     # get the input
    #     project_name_old = json_data['project_name_old']
    #     project_name_new = json_data['project_name_new']

    #     # create the project
    #     Projects.edit_project(project_name_old = project_name_old, project_name_new=project_name_new)

    #     # return the new project to the client
    #     return { "status": 'success' }, 201

    #delete one project
    #input: project_name
    def delete(self):
        args = request.args

        # check if the input exists
        if not args:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = args['project_name']

        # delete the project
        Projects.delete_project(project_name)

        # return to the client the status
        return { "status": 'success'}, 201