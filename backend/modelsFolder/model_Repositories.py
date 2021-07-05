from config import MongoDBConnect
from modelsFolder.model_Commits import Commits
from modelsFolder.model_Files import Files
from modelsFolder.model_Features import Features
from modelsFolder.model_Associations import Associations
from modelsFolder.model_Authors import Authors
from modelsFolder.model_Reports import Reports
import pymongo


client = pymongo.MongoClient(MongoDBConnect)



class Repositories():
    def __init__(project_name):
        print("Repositories.__init__("+project_name+")")
        mydb = client[project_name]
        mycol = mydb['repositories']
        
    def new_repository(project_name, repository_name, url):
        print("Repositories.new_repository("+project_name+", " + repository_name + ", " + url + ")")
        mydb = client[project_name]
        mycol = mydb['repositories']

        mydict = { "repository_name": repository_name, "url": url }
        x = mycol.insert_one(mydict)

        Associations.__init__(project_name, repository_name)
        Features.__init__(project_name, repository_name)
        Files.__init__(project_name, repository_name)
        Authors.__init__(project_name, repository_name)
        Commits.__init__(project_name, repository_name)

    def edit_repositories(project_name, repository_name_old, repository_name_new, url_new):
        print("Repositories.edit_repository("+project_name+", " + repository_name_old + ", " + repository_name_new + ", " + url_new + ")")
        
        mydb = client[project_name]
        mycol = mydb['repositories']
        myquery = { "repository_name": repository_name_old }
        newvalues = { "$set": { "repository_name": repository_name_new, "url": url_new } }
        mycol.update_one(myquery, newvalues)

        if repository_name_new != repository_name_old:
            mydb[repository_name_old + '_commits'].rename(repository_name_new + '_commits')
            mydb[repository_name_old + '_files'].rename(repository_name_new + '_files')
            mydb[repository_name_old + '_authors'].rename(repository_name_new + '_authors') 
            mydb[repository_name_old + '_features'].rename(repository_name_new + '_features')
            mydb[repository_name_old + '_associations'].rename(repository_name_new + '_associations')
        
        

    def get_repositories(project_name, repository_name = 0):
        print("Repositories.get_repositories(" + project_name+ ", " + str(repository_name) + ")")
        mydb = client[project_name]
        mycol = mydb['repositories']

        if repository_name:
            result = mycol.find({'repository_name' : repository_name})
            
        else:
            result = mycol.find()

        myresult = []

        for x in result:
            myresult.append(x)

        return myresult

    def get_repositories_by_url(project_name, url):
        print("Repositories.get_repositories_by_url(" + project_name+ ", " + url + ")")
        mydb = client[project_name]
        mycol = mydb['repositories']

        result = mycol.find({'url' : url})        

        myresult = []
        for x in result:
            myresult.append(x)

        return myresult

    def delete_repository(project_name, repository_name):
        print("Repositories.delete_repositories(" + project_name+ ", " + repository_name + ")")

        Commits.delete_table(project_name, repository_name)
        Files.delete_table(project_name, repository_name)
        Features.delete_table(project_name, repository_name)
        Associations.delete_table(project_name, repository_name)
        Authors.delete_table(project_name, repository_name)
        Reports.delete_table(project_name, repository_name)

        mydb = client[project_name]
        mycol = mydb['repositories']
        mycol.delete_one({'repository_name' : repository_name})

    def get_url(project_name, repository_name):
        print("Repositories.get_url(" + project_name + ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb['repositories']

        result = mycol.find({'repository_name' : repository_name})
        myresult = []
        for x in result:
            myresult.append(x)

        url = myresult[0]['url']
            
        return url