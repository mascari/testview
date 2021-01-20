from config import MongoDBConnect
import pymongo
import collections


client = pymongo.MongoClient(MongoDBConnect)


class Reports():
    def __init__(project_name, repository_name):
        print("Reports.__init__(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_reports']


    def create_report(project_name, repository_name, date):
        try:
            from modelsFolder.model_Commits import Commits
        except ImportError:
            print("Repositories are already imported")

        try:
            from modelsFolder.model_Authors import Authors
        except ImportError:
            print("Authors are already imported")

        try:
            from modelsFolder.model_Files import Files
        except ImportError:
            print("Files are already imported")

        try:
            from modelsFolder.model_Associations import Associations
        except ImportError:
            print("Associations are already imported")

        try:
            from modelsFolder.model_Features import Features
        except ImportError:
            print("Features are already imported")


        mydb = client[project_name]
        mycol = mydb[repository_name + '_reports']

        mycol.drop()

        date_init = date.replace('-', '')
        date_init = int(date_init)

        author_dict = {}                # This dict is to save all the authors that make some commit in the date_range
        author_total_dict = {}          # This dict is to save all the authors in the repo and the number of commits
        author_percent_dict = {}        # This dict is to save the percent of commits that the author make compare to the total_commits
        total_commits = 0               # This int is to save the total number of commits

        commits = Commits.get_commits(project_name, repository_name)

        # Get the files modified in the range and see if was or not associated
        files_not_associated = []
        files_associated = []

        for c in commits:
            # print(str(c['date'])[0:9])
            date_commit = int(str(c['date'])[0:10].replace('-', ''))    # Convert to int to compare

            if date_commit >= date_init:
                author_dict[c['author']] = author_dict.get(c['author'], 0) + 1  # Count the number of commits 
                # Get the files modified in the commit
                files = Commits.get_files_commit(project_name, repository_name, c['hash'])
                for f in files:
                    # Get the File object from table Files
                    obj_file = Files.get_files(project_name, repository_name, file_path=f['file_path'])
                    if obj_file[0]['number_features_associated'] > 0:
                        files_associated.append(f['file_path'])
                    else:
                        files_not_associated.append(f['file_path'])

        authors = Authors.get_authors(project_name, repository_name)

        for a in authors:
            total_commits += a['number_commits']
            if a['author_name'] in author_dict:
                author_total_dict[a['author_name']] = a['number_commits']
                
        for a in author_total_dict:
            author_percent_dict[a] = author_total_dict[a] / total_commits

        print('Author percent dict: ' + str(author_percent_dict))


        print("The files " + str(files_associated) + " have been associated.")
        print("The files " + str(files_not_associated) + " have not been associated yet.")


        # Get the features of associated files
        features_modified = {}
        for file_associated in files_associated:
            associations = Associations.get_associations(project_name = project_name, repository_name= repository_name, file_path= file_associated)
            for a in associations:
                features_modified[a['feature_name']] = features_modified.get(a['feature_name'], 0) + 1
                    
        print('Features modified: ' + str(features_modified))


        # Init the Metric: 
        features = Features.get_features(project_name, repository_name)

        features_prio = {}          # This dict mesure the priorization of the feature

        for f in features:
            if f['feature_name'] in features_modified:
                features_prio[f['feature_name']] = f['number_bugs'] * 2 + f['number_files_associated'] * 1 +  features_modified[f['feature_name']] * 4
            else:
                features_prio[f['feature_name']] = f['number_bugs'] * 2 + f['number_files_associated'] * 1
        
        print(features_prio)
        for f in features:
            if f['feature_name'] in features_modified:
                mydict = { "feature_name": f['feature_name'], "prio": features_prio[f['feature_name']], "date": date, "number_files_associated": f['number_files_associated'], "number_bugs" : f['number_bugs'], "number_files_modified": features_modified[f['feature_name']]}
                x = mycol.insert_one(mydict)
            else:
                mydict = { "feature_name": f['feature_name'], "prio": features_prio[f['feature_name']], "date": date, "number_files_associated": f['number_files_associated'], "number_bugs" : f['number_bugs'], "number_files_modified": 0}
                x = mycol.insert_one(mydict)


        return { "features_prio": features_prio }





    # Receive the date in the pattern: yyyy-mm-dd
    def get_report(project_name, repository_name):
        mydb = client[project_name]
        mycol = mydb[repository_name + '_reports']
        result = mycol.find()

        myresult = []

        for x in result:
            myresult.append(x)            

        return myresult

    def delete_table(project_name, repository_name):
        print("Reports.delete_table(" + project_name+ ", " + repository_name + ")")
        mydb = client[project_name]
        mycol = mydb[repository_name + '_reports']
        mycol.drop()
