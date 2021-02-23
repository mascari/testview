import os

basedir = os.path.abspath(os.path.dirname(__file__))

MongoDBConnect = "mongodb://localhost:27017/test?retryWrites=true&w=majority"

FILE_EXTENSIONS_PERMITED = [".py", ".java", ".kv", ".dart", ".js", ".*"]
DAYS_DELTA = 15