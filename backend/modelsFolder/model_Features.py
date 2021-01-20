from config import MongoDBConnect
import pymongo

client = pymongo.MongoClient(MongoDBConnect)

class Features():
    def __init__(project_name, repository_name):
        print("Features.__init__(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_features']

    def new_feature(project_name, repository_name, feature_name, number_bugs = 0, number_files_associated = 0):
        print("Features.new_feature(" + project_name+ ", " + repository_name + ", " + feature_name + ", " + str(number_bugs) + ", " + str(number_files_associated) + ")")

        mydb = client[project_name]
        mycol = mydb[repository_name + '_features']

        mydict = {
            'feature_name' : feature_name,
            'number_bugs' : number_bugs,
            'number_files_associated' : number_files_associated
        }

        mycol.insert_one(mydict)
        

    def get_features(project_name, repository_name, feature_name = 0):
        print("Features.get_features(" + project_name+ ", " + repository_name + ", " + str(feature_name) + ")")

        mydb = client[project_name]
        mycol = mydb[repository_name + '_features']

        if feature_name:
            result = mycol.find({'feature_name' : feature_name})
        else:
            result = mycol.find()

        myresult = []
        for x in result:
            myresult.append(x)
        return myresult

    def update_feature_number_bug(project_name, repository_name, feature_name, feature_name_new, number_bugs):
        print("Features.update_feature_number_bug(" + project_name+ ", " + repository_name + ", " + feature_name + ", " + str(number_bugs) + ")")
        
        mydb = client[project_name]
        mycol = mydb[repository_name + '_features']

        myquery = { "feature_name": feature_name }
        newvalues = { "$set": { "feature_name" : feature_name_new, "number_bugs": number_bugs } }
        mycol.update_one(myquery, newvalues)
        if feature_name != feature_name_new:
            mycolAssociated = mydb[repository_name + '_associations']
            myquery = {"feature_name" : feature_name}
            newvalues = { "$set": { "feature_name": feature_name_new } }
            mycolAssociated.update_many(myquery, newvalues)
       

    def update_feature_files_associated(project_name, repository_name, feature_name):
        print("Features.update_feature_files_associated(" + project_name+ ", " + repository_name + ", " + str(feature_name) + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_features']

        mycolAsso = mydb[repository_name + '_associations']
        result = mycolAsso.find({'feature_name' : feature_name})
        number_files_associated = result.count()

        myquery = { "feature_name": feature_name }
        newvalues = { "$set": { "number_files_associated": number_files_associated } }
        mycol.update_one(myquery, newvalues)


    def delete_feature(project_name, repository_name, feature_name):
        print("Features.update_feature_number_bug(" + project_name+ ", " + repository_name + ", " + feature_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_features']

        mycol.delete_one({ 'feature_name' : feature_name })

    def delete_table(project_name, repository_name):
        print("Features.delete_table(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_features']
        mycol.drop()