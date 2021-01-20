from config import MongoDBConnect
from modelsFolder.model_SettingsFiles import ModelSettingsFiles
import pymongo


client = pymongo.MongoClient(MongoDBConnect)



class Files():
    def __init__(project_name, repository_name):
        print("Files.__init__(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_files']

    def new_file(project_name, repository_name, file_name = 0, file_path = 0, number_features_associated = 0, last_modification = 0):
        print("Files.new_file(" + project_name+ ", " + repository_name +", " + str(file_name) + ", " + str(file_path) + ", " + str(number_features_associated)  + ", " + str(last_modification) + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_files']

        file_extensions = ModelSettingsFiles.get_file_extensions(project_name)

        for e in file_extensions:
            if file_name.endswith(e):
                if file_path != '_None_':
                    
                    result = mycol.find({"file_path" : file_path})
                    if not result.count():
                        x = mycol.insert_one({ "file_path": file_path, "file_name": file_name, "number_features_associated" : number_features_associated, "last_modification": last_modification })
                    else:
                        Files.update_file_last_modification(project_name, repository_name, file_path, last_modification)
                    
                        


    def get_files(project_name, repository_name, file_name = 0, file_path = 0):
        print("Files.get_files(" + project_name+ ", " + repository_name + ", " + str(file_name) + ", " + str(file_path) + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_files']

        if file_name:
            result = mycol.find({'file_name' : file_name})
        elif file_path:
            result = mycol.find({'file_path' : file_path})
        else:
            result = mycol.find()

        myresult = []
        for x in result:
            myresult.append(x)     

        return myresult
    
    def update_file(project_name, repository_name, file_path):
        print("Files.update_file(" + project_name+ ", " + repository_name + ", " + str(file_path) + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_files']

        mycolAsso = mydb[repository_name + '_associations']
        result = mycolAsso.find({'file_path' : file_path})
        number_features_associated = result.count()

        myquery = { "file_path": file_path }
        newvalues = { "$set": { "number_features_associated": number_features_associated } }
        mycol.update_one(myquery, newvalues)
    
    def update_file_last_modification(project_name, repository_name, file_path, last_modification = 0):
        print("Files.update_file(" + project_name+ ", " + repository_name + ", " + str(last_modification) + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_files']

        myquery = { "file_path": file_path }
        newvalues = { "$set": { "last_modification": last_modification } }
        mycol.update_one(myquery, newvalues)

    def delete_table(project_name, repository_name):
        print("Files.delete_table(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_files']
        mycol.drop()