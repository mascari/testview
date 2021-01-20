from flask_restful import Resource
from flask import request
from modelsFolder.model_Files import Files
import json

class File(Resource):
	# get all the project's files
	def get(self):
		args = request.args
		if not args:
			return {'message': 'No input data provided'}, 400
		project_name = args['project_name']
		repository_name = args['repository_name']
		result = Files.get_files(project_name, repository_name)
		result = json.dumps(result, indent=4, sort_keys=True, default=str)
		return { "data" : result}, 201

