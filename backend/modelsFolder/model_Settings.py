from config import MongoDBConnect
import pymongo


client = pymongo.MongoClient(MongoDBConnect)


class ModelSettings():
    def __init__(project_name):
        print("ModelSettings.__init__(project_name):")
        mydb = client[project_name]
        mycol = mydb['settings']
        mycol.insert({'days_retrieval' : 30})
        

    def edit_days_retrieval(project_name, days_retrieval = 30):
        print("ModelSettings.edit_days_retrieval("+project_name+", "+str(days_retrieval)+")")
        mydb = client[project_name]
        mycol = mydb['settings']
        newvalues = { "$set": { "days_retrieval": days_retrieval } }
        mycol.update_one({}, newvalues)
        
    def get_days_retrieval(project_name):
        print("ModelSettings.edit_days_retrieval("+project_name+")")

        mydb = client[project_name]
        mycol = mydb['settings']

        result = mycol.find({}, {'days_retrieval': 1})

        myresult = []

        for x in result:
            myresult.append(x)

        final_result = myresult[0]['days_retrieval']
        print(final_result)

        return final_result