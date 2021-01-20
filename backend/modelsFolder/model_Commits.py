from config import MongoDBConnect
from pydriller import RepositoryMining
import datetime
from modelsFolder.model_Settings import ModelSettings
from modelsFolder.model_Files import Files
from modelsFolder.model_Authors import Authors
from modelsFolder.model_SettingsFiles import ModelSettingsFiles
import pymongo


client = pymongo.MongoClient(MongoDBConnect)


class Commits():
    def __init__(project_name, repository_name):
        print("Commits.__init__(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_commits']
        mycol_commit = mydb[repository_name + '_files_by_commit']
        Commits.initial_commit(project_name, repository_name)

    def initial_commit(project_name, repository_name):
        print("Commits.initial_commit(" + project_name+ ", " + repository_name + ")")

        try:
            from modelsFolder.model_Repositories import Repositories
        except ImportError:
            print("Repositories are already imported")


        mydb = client[project_name]
        mycol = mydb[repository_name + '_commits']
        mycol_commit = mydb[repository_name + '_files_by_commit']

        url = Repositories.get_url(project_name, repository_name)

        days_retrieval = ModelSettings.get_days_retrieval(project_name)

        date = datetime.datetime.today() - datetime.timedelta(days=days_retrieval) 

        for commit in RepositoryMining(url, since=date).traverse_commits():
            _hash = commit.hash
            author = commit.author.name
            date = commit.author_date
            number_files = len(commit.modifications)
            message = commit.msg

            number_lines = 0
            # Iterate the files of the commit
            for mod in commit.modifications:
                
                file_extensions = ModelSettingsFiles.get_file_extensions(project_name)

                for e in file_extensions:
                        if mod.filename.endswith(e):
                            if mod.new_path != '_None_':
                                # Add a new line linking the file with the commit
                                mycol_commit.insert_one({ "file_name": mod.filename, "file_path": mod.new_path, "hash": _hash, "number_lines": mod.added + mod.removed })
                
                # The number of files modifieds in this commit
                number_lines = number_lines + mod.added + mod.removed

                # Create the file in the table File (if already exists, the Files.new_file treats)
                Files.new_file( 
                    project_name = project_name,
                    repository_name = repository_name, 
                    file_name = mod.filename, 
                    file_path = mod.new_path,
                    last_modification = date
                )

            # Create the file in the table File (if already exists, the Files.new_file treats)
            Authors.new_author( 
                project_name = project_name, 
                repository_name = repository_name,
                author_name = author, 
                number_lines = number_lines,
                last_modification = date
                )

            mydict = { "hash": _hash, "message": message, "author": author, "date": date, "number_files": number_files, "number_lines": number_lines}
            x = mycol.insert_one(mydict)
            
    def update_commits(project_name, repository_name):
        print("Commits.update_commits(" + project_name+ ", " + repository_name + ")")
        
        
        try:
            from modelsFolder.model_Repositories import Repositories
        except ImportError:
            print("Repositories are already imported")


        mydb = client[project_name]
        mycol = mydb[repository_name + '_commits']
        mycol_commit = mydb[repository_name + '_files_by_commit']

        url = Repositories.get_url(project_name, repository_name)

        days_retrieval = ModelSettings.get_days_retrieval(project_name)

        date = datetime.datetime.today() - datetime.timedelta(days=days_retrieval) 

        for commit in RepositoryMining(url, since=date).traverse_commits():
            _hash = commit.hash
            author = commit.author.name
            date = commit.author_date
            number_files = len(commit.modifications)
            message = commit.msg
            number_lines = 0

            result = mycol.find({"hash" : _hash})
            if not result.count():
                # Insert a new line in the commits table (with the info of the commit)
                mycol.insert_one({ "hash": _hash, "message": message, "author": author, "date": date, "number_files": number_files, "number_lines": number_lines })
                
                # Iterate the files of the commit
                for mod in commit.modifications:

            
                    file_extensions = ModelSettingsFiles.get_file_extensions(project_name)

                    for e in file_extensions:
                            if mod.filename.endswith(e):
                                if mod.new_path != '_None_':
                                    # Add a new line linking the file with the commit
                                    mycol_commit.insert_one({ "file_name": mod.filename, "file_path" : mod.new_path, "hash": _hash, "number_lines": mod.added + mod.removed })
            

                    
                    # The number of files modifieds in this commit
                    number_lines = number_lines + mod.added + mod.removed
                    # Create the file in the table File (if already exists, the Files.new_file treats)
                    Files.new_file( 
                        project_name = project_name,
                        repository_name = repository_name, 
                        file_name = mod.filename, 
                        file_path = mod.new_path,
                        last_modification = date
                    )

                # Create the Author in the table author (if already exists, the Authors.new_author treats)
                Authors.new_author( 
                    project_name = project_name, 
                    repository_name = repository_name,
                    author_name = author, 
                    number_lines = number_lines,
                    last_modification = date
                    )



    def get_commits(project_name, repository_name):
        print("Commits.get_commits(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_commits']

        result = mycol.find()

        myresult = []

        for x in result:
            myresult.append(x)            

        return myresult

    def get_files_commit(project_name, repository_name, _hash):
        print("Commits.get_files_commit(" + project_name+ ", " + repository_name + ", " + _hash + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_commits']
        mycol_commit = mydb[repository_name + '_files_by_commit']

        result = mycol_commit.find({"hash" : _hash})

        myresult = []

        for x in result:
            myresult.append(x)      
 

        return myresult

    #Create a function to get the files from a specific commit

    def delete_table(project_name, repository_name):
        print("Commits.delete_table(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_commits']
        mycol_commit = mydb[repository_name + '_files_by_commit']
        mycol.drop()
        mycol_commit.drop()