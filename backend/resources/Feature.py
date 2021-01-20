from flask_restful import Resource
from flask import request
from modelsFolder.model_Features import Features
from modelsFolder.model_Repositories import Repositories
import json

class Feature(Resource):
    # get all the project's features
    def get(self):
        print('GET Feature')
        args = request.args
        
        if not args:
            return {'message': 'No input data provided'}, 400

        project_name = args['project_name']
        repository_name = args['repository_name']
        result = Features.get_features(project_name, repository_name)
        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        return { "data" : result}, 201


    # create a new feature
    # input: project_name, feature_name
    def post(self):
        json_data = request.get_json(force=True)

        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = json_data['project_name']
        repository_name = json_data['repository_name']
        feature_name = json_data['feature_name']
        number_bugs_string = json_data['number_bugs']
        number_bugs = int(number_bugs_string)

        # check if the project exists
        result = Repositories.get_repositories(project_name, repository_name)
        if not result: 
            return {'message': 'Repository name not exists'}, 400

        # check if the feature already exists
        result = Features.get_features(project_name, repository_name, feature_name)
        if len(result) > 1: 
            return {'message': 'Feature name already exists'}, 400
        
        # create the new feature
        Features.new_feature(project_name, repository_name, feature_name, number_bugs)

        # get the new feature to confirm that everything is OK
        result = Features.get_features(project_name, repository_name, feature_name)
        
        result = json.dumps(result, indent=4, sort_keys=True, default=str)

        return { "status": 'success', 'data': result }, 201

    # put: alter the number of bugs of the feature
    def put(self):
        json_data = request.get_json(force=True)

        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = json_data['project_name']
        repository_name = json_data['repository_name']
        feature_name = json_data['feature_name']
        feature_name_new = json_data['feature_name_new']
        number_bugs_string = json_data['number_bugs']
        number_bugs_string = number_bugs_string.replace('"', '')
        number_bugs_string = number_bugs_string.replace(" ", "")
        number_bugs = int(number_bugs_string)

        result = Features.get_features(project_name, repository_name, feature_name)
        if not result: 
            return {'message': 'Feature name not exists'}, 400

        Features.update_feature_number_bug(project_name, repository_name, feature_name, feature_name_new, number_bugs)

        return { "status": 'success'}, 201


    #delete one feature
    #input: project_name, feature_name
    def delete(self):
        args = request.args

        # check if the input exists
        if not args:
               return {'message': 'No input data provided'}, 400

        # get the input
        project_name = args['project_name']
        repository_name = args['repository_name']
        feature_name = args['feature_name']

        # check if the project exists
        result = Repositories.get_repositories(project_name, repository_name)
        if not result: 
            return {'message': 'Repository name not exists'}, 400

        # check if the feature exists in this project
        result = Features.get_features(project_name, repository_name, feature_name)
        if not result: 
            return {'message': 'Feature name not exists'}, 400

        # delete the feature
        Features.delete_feature(project_name, repository_name, feature_name)

        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        # return to the client the deleted feature
        return { "status": 'success', 'data': result}, 201