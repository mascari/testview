from flask_restful import Resource
from flask import request
from modelsFolder.model_Repositories import Repositories
import json

class Repository(Resource):
    # get all the repositories from the project
    def get(self):
        args = request.args
        if not args:
            return {'message': 'No input data provided'}, 400
        project_name = args['project_name']
        result = Repositories.get_repositories(project_name)
        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        return { "data" : result}, 201

    def put(self):
        json_data = request.get_json(force=True)

        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = json_data['project_name']
        repository_name_old = json_data['repository_name_old']
        repository_name_new = json_data['repository_name_new']
        url_new = json_data['url_new']

        result = Repositories.get_repositories(project_name, repository_name_old)
        if len(result) < 1: 
            return {'message': 'Repository name not exists'}, 400

        Repositories.edit_repositories(project_name=project_name, repository_name_old=repository_name_old, repository_name_new=repository_name_new, url_new=url_new)

        return { "status": 'success' }, 201

    # create a new project
    # input: project_name, url
    def post(self):
        json_data = request.get_json(force=True)

        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = json_data['project_name']
        repository_name = json_data['repository_name']
        url = json_data['url']

        # check if the project already exists
        result = Repositories.get_repositories(project_name, repository_name)
        if len(result) > 1: 
            return {'message': 'Repository name already exists'}, 400
        
        # check if the project's url already exists
        result = Repositories.get_repositories_by_url(repository_name, url)
        if len(result) > 1: 
            return {'message': 'Repository url already exists'}, 400

        # create the repository
        Repositories.new_repository(
            project_name = project_name,
            repository_name = repository_name,
            url = url
        )

        # get the new project to confirm that everything is OK
        result = Repositories.get_repositories(project_name, repository_name)

        result = json.dumps(result, indent=4, sort_keys=True, default=str)

        # return the new project to the client
        return { "status": 'success', 'data': result }, 201

    #delete one project
    #input: project_name
    def delete(self):
        args = request.args

        # check if the input exists
        if not args:
               return {'message': 'No input data provided'}, 400

        # get the input
        project_name = args['project_name']
        repository_name = args['repository_name']

        # check if the project exists
        result = Repositories.get_repositories(project_name, repository_name)
        if not result: 
            return {'message': 'Repository name not exists'}, 400

        # delete the project
        Repositories.delete_repository(project_name, repository_name)
        result = json.dumps(result, indent=4, sort_keys=True, default=str)

        # return to the client the deleted project
        return { "status": 'success', 'data': result}, 201