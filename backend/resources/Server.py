from flask_restful import Resource
from flask import request

class Server(Resource):
    def get(self):
        print("GET Server")
        return { "data" : "Server is up..."}, 201

