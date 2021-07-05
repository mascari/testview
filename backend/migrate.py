
import pymongo


client = pymongo.MongoClient("mongodb://localhost:27017/test?retryWrites=true&w=majority")

mydb = client['all_projects']
mycol = mydb['projects']

