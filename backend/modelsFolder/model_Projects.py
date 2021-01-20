from config import MongoDBConnect
from modelsFolder.model_Settings import ModelSettings
from modelsFolder.model_Repositories import Repositories
from modelsFolder.model_SettingsFiles import ModelSettingsFiles
import pymongo


client = pymongo.MongoClient(MongoDBConnect)

class Projects():
    def new_project(project_name):
        print("Projects.new_project("+project_name+")")
        mydb = client['all_projects']
        mycol = mydb['projects']
        result = mycol.find({"project_name" : project_name})
        if not result.count():
            mycol.insert({'project_name' : project_name})
        ModelSettings.__init__(project_name)
        ModelSettingsFiles.__init__(project_name)
        
    def edit_project(project_name_old, project_name_new):
        print("Projects.edit_project("+project_name_old+ ", " + project_name_new + ")")
        client.admin.command('copydb',
                         fromdb=project_name_old,
                         todb=project_name_new)
        client.drop_database(project_name_old)

        mydb = client['all_projects']
        mycol = mydb['projects']

        myquery = { "project_name": project_name_old }
        newvalues = { "$set": { "project_name": project_name_new } }
        mycol.update_one(myquery, newvalues)


    def delete_project(project_name):
        print("Projects.delete_project("+project_name+")")
        mydb = client['all_projects']
        mycol = mydb['projects']
        mycol.delete_one({'project_name' : project_name})
        client.drop_database(project_name)

    def get_projects():
        print("Projects.get_projects()")
        mydb = client['all_projects']
        mycol = mydb['projects']
        result = mycol.find()
        myresult = []
        for x in result:
            myresult.append(x)
        return myresult