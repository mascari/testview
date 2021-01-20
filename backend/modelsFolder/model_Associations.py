from config import MongoDBConnect
import pymongo


client = pymongo.MongoClient(MongoDBConnect)

class Associations():
    def __init__(project_name, repository_name):
        print("Associations.__init__(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + "_associations"]
        
    def new_association(project_name, repository_name, file_path, feature_name):
        print("Associations.new_association(" + project_name + ", " + repository_name + ", " + file_path + ", " + feature_name +")")
        mydb = client[project_name]
        mycol = mydb[repository_name + "_associations"]
        
        mycol.insert({'file_path' : file_path, 'feature_name' : feature_name})

    def get_associations(project_name, repository_name, file_path = 0, feature_name = 0):
        print("Associations.get_associations(" + project_name + ", " + repository_name + ", " + str(file_path) + ", " + str(feature_name) +")")
        mydb = client[project_name]
        mycol = mydb[repository_name + "_associations"]

        if file_path and feature_name:
            result = mycol.find({"file_path" : file_path, "feature_name" : feature_name})
        elif file_path:
            result = mycol.find({"file_path" : file_path})
        elif feature_name:
            result = mycol.find({"feature_name" : feature_name})
        else:
            result = mycol.find()

        myresult = []
        for x in result:
            myresult.append(x)

        return myresult

    def delete_association(project_name, repository_name, file_path, feature_name):
        print("Associations.get_associations(" + project_name + ", " + repository_name + ", " + str(file_path) + ", " + str(feature_name) +")")
        mydb = client[project_name]
        mycol = mydb[repository_name + "_associations"]
        mycol.delete_one({ 'feature_name' : feature_name, 'file_path' : file_path })


    def delete_table(project_name, repository_name):
        print("Associations.delete_table(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_associations']
        mycol.drop()