from flask import Flask
from config import MongoDBConnect
from pydriller import RepositoryMining
import datetime
import pymongo
from config import MongoDBConnect


client = pymongo.MongoClient(MongoDBConnect)


class ModelSettingsFiles():
    def __init__(project_name):
        print("ModelSettingsFiles.__init__(project_name):")
        mydb = client[project_name]
        mycol = mydb['settings']
        mycol.insert({'file_extensions' : '.py'})
        mycol.insert({'file_extensions' : '.java'})
        mycol.insert({'file_extensions' : '.c'})
        mycol.insert({'file_extensions' : '.h'})
        mycol.insert({'file_extensions' : '.cpp'})
        mycol.insert({'file_extensions' : '.html'})
        mycol.insert({'file_extensions' : '.js'})
        mycol.insert({'file_extensions' : '.css'})

    def new_file_extensions(project_name, file_extensions):
        print("ModelSettingsFiles.edit_file_extensions("+project_name+", "+file_extensions + ")")
        mydb = client[project_name]
        mycol = mydb['settings']
        if file_extensions[0] != '.':
            file_extensions = '.' + file_extensions

        file_extensions = file_extensions.replace('..', '.')

        mycol.insert({'file_extensions' : file_extensions})
        

    def edit_file_extensions(project_name, file_extensions_old, file_extensions_new):
        print("ModelSettingsFiles.edit_file_extensions("+project_name+", "+file_extensions_old + ", " + file_extensions_new +")")
        mydb = client[project_name]
        mycol = mydb['settings']

        if file_extensions_new[0] != '.':
            file_extensions_new = '.' + file_extensions_new

        file_extensions_new = file_extensions_new.replace('..', '.')

        newvalues = { "$set": { "file_extensions": file_extensions_new } }
        mycol.update_one({"file_extensions" : file_extensions_old }, newvalues)
        
    def get_file_extensions(project_name):
        print("ModelSettingsFiles.edit_file_extensions("+project_name+")")

        mydb = client[project_name]
        mycol = mydb['settings']

        result = mycol.find()

        myresult = []
        final_result = []

        for x in result:
            myresult.append(x)

        for x in myresult:
            try: 
                final_result.append(x['file_extensions'])
            except:
                print('Not file extension')

        return final_result

    def delete_file_extensions(project_name, file_extensions):
        print("ModelSettingsFiles.delete_file_extensions("+project_name+ ", " + file_extensions + ")")

        mydb = client[project_name]
        mycol = mydb['settings']

        mycol.delete_one({ 'file_extensions' : file_extensions })