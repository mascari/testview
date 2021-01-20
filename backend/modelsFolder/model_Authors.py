from config import MongoDBConnect
import pymongo

client = pymongo.MongoClient(MongoDBConnect)

class Authors():
    def __init__(project_name, repository_name):
        print("Authors.__init__(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_authors']

    def new_author(project_name, repository_name, author_name, number_commits = 1, number_lines = 0, last_modification = 0):
        print("Authors.new_author(" + project_name+ ", " + repository_name + ", " + author_name + ", " + str(number_commits) + ", " + str(number_lines) + ", " + str(last_modification) + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_authors']

        myresult = []
        result = mycol.find()

        for x in result:
            myresult.append(x)

        found = False

        for y in myresult:
            if y['author_name'] == author_name:
                number_commits_old = y['number_commits']
                number_lines_old = y['number_lines']
                found = True
            

        if found: 
            number_commits_updated = int(number_commits_old) + number_commits
            number_lines_updated = int(number_lines_old) + number_lines
            myquery = { "author_name": author_name }
            newvalues = { "$set": { "number_commits": number_commits_updated, "number_lines" : number_lines_updated, "last_modification" : last_modification } }

            mycol.update_one(myquery, newvalues)
            
        else:
            mydict = { "author_name" : author_name, "number_commits" : number_commits, "number_lines" : number_lines, "last_modification": last_modification}
            x = mycol.insert_one(mydict)

    def get_authors(project_name, repository_name, author_name = 0):
        mydb = client[project_name]
        mycol = mydb[repository_name + '_authors']

        if author_name:
            result = mycol.find({}, {'author_name' : author_name})
        else:
            result = mycol.find()
        
        myresult = []
        for x in result:
            myresult.append(x)

        return myresult

    def delete_table(project_name, repository_name):
        print("Authors.delete_table(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_authors']
        mycol.drop()