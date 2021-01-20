from flask_restful import Resource
from flask import request
from modelsFolder.model_Authors import Authors
import json

class Author(Resource):
	# get all the project's authors
	def get(self):
		print('GET Author')
		args = request.args
		if not args:
			return {'message': 'No input data provided'}, 400
		project_name = args['project_name']
		repository_name = args['repository_name']
		result = Authors.get_authors(project_name, repository_name)
		result = json.dumps(result, indent=4, sort_keys=True, default=str)
		return { "data" : result}, 201

