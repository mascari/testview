from flask_restful import Resource
from flask import request
from modelsFolder.model_Associations import Associations
from modelsFolder.model_Features import Features
from modelsFolder.model_Files import Files
from modelsFolder.model_Repositories import Repositories
import json

class Association(Resource):
    # get all the project's associations 
    def get(self):
        print('GET Association')
        args = request.args
        
        if not args:
            return {'message': 'No input data provided'}, 400

        project_name = args['project_name']
        repository_name = args['repository_name']
        
        result = Associations.get_associations(project_name, repository_name)

        
        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        return { "data" : result}, 201

    # create a new association
    # input: project_name, file_name, feature_name
    def post(self):
        json_data = request.get_json(force=True)

        # check if the input exists
        if not json_data:
            return {'message': 'No input data provided'}, 400

        # get the input
        project_name = json_data['project_name']
        repository_name = json_data['repository_name']
        feature_name = json_data['feature_name']
        file_path = json_data['file_path']

        # check if the project exists
        result = Repositories.get_repositories(project_name, repository_name)
        if len(result) < 1: 
            return {'message': 'Repository name not exists'}, 400
        
        # check if the file_name exists in the project
    
        file_path = file_path.replace('\\\\', '\\')
        file_path = file_path.replace(' ', '')
        result = Files.get_files(project_name = project_name, repository_name = repository_name, file_path = file_path)
        if not result: 
            return {'message': 'File path not exists'}, 400

        # check if the feature_name exists in the project
        result = Features.get_features(project_name, repository_name, feature_name)
        if not result: 
            return {'message': 'Feature name not exists'}, 400

        # check if the feature_name exists in the project
        result = Associations.get_associations(project_name, repository_name, file_path, feature_name)
        if result: 
            return {'message': 'Association name already exists'}, 400

        
        # create the association
        Associations.new_association(project_name, repository_name, file_path, feature_name)

        # update the numbe of features associated to the file
        Files.update_file(project_name, repository_name, file_path)

        # # update the number of files associated to the feature
        Features.update_feature_files_associated(project_name, repository_name, feature_name)

        # get the new association to confirm that everything is OK
        result = Associations.get_associations(project_name, repository_name, file_path, feature_name)

        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        # return the new association to the client
        return { "status": 'success', 'data': result }, 201

    #delete one association
    #input: project_name, file_name, feature_name
    def delete(self):
        args = request.args

        # check if the input exists
        if not args:
               return {'message': 'No input data provided'}, 400

        # get the input
        project_name = args['project_name']
        repository_name = args['repository_name']
        feature_name = args['feature_name']
        file_path = args['file_path']

        # check if the project exists
        result = Repositories.get_repositories(project_name, repository_name)
        if not result: 
            return {'message': 'Repository name not exists'}, 400

        file_path = file_path.replace('\\\\', '\\')
        file_path = file_path.replace(' ', '')


        result = Files.get_files(project_name = project_name, repository_name = repository_name, file_path = file_path) 
        if not result:
            return {'message': 'File path not exists'}, 400

        # check if the association exists in this repository
        result = Associations.get_associations(project_name, repository_name, file_path ,feature_name)
        if not result: 
            return {'message': 'Association not exists'}, 400

        # delete the association
        Associations.delete_association(project_name, repository_name, file_path, feature_name)

        # update the numbe of features associated to the file
        Files.update_file(project_name, repository_name, file_path)

        # # update the number of files associated to the feature
        Features.update_feature_files_associated(project_name, repository_name, feature_name)

        result = json.dumps(result, indent=4, sort_keys=True, default=str)
        # return to the client the deleted association
        return { "status": 'success', 'data': result}, 201