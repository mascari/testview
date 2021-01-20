from flask_restful import Resource
from flask import request
from modelsFolder.model_Commits import Commits
from modelsFolder.model_Repositories import Repositories
import json

class Commit(Resource):
	# get all the project's commits
	def get(self):
		print('GET Commit')
		args = request.args
		if not args:
			return {'message': 'No input data provided'}, 400
		project_name = args['project_name']
		repository_name = args['repository_name']
		
		try: 
			_hash = args['hash']
			result = Commits.get_files_commit(project_name, repository_name, _hash)
			result = json.dumps(result, indent=4, sort_keys=True, default=str)
		except:
			result = Commits.get_commits(project_name, repository_name)
			result = json.dumps(result, indent=4, sort_keys=True, default=str)

		return { "data" : result}, 201

	def put(self):
		json_data = request.get_json(force=True)

        # check if the input exists
		if not json_data:
			return {'message': 'No input data provided'}, 400

        # get the input
		project_name = json_data['project_name']
		repository_name = json_data['repository_name']

		Commits.update_commits(project_name, repository_name)
		
		return { "status": 'success' }, 201



