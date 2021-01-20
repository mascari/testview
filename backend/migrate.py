
import pymongo


client = pymongo.MongoClient("mongodb+srv://testview:sdf56JKL!@test-stsy1.gcp.mongodb.net/test?retryWrites=true&w=majority")

mydb = client['all_projects']
mycol = mydb['projects']

