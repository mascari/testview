from config import MongoDBConnect
from pydriller import RepositoryMining
import datetime
from modelsFolder.model_Settings import ModelSettings
from modelsFolder.model_Projects import Projects
from modelsFolder.model_Repository import Repositories
from modelsFolder.model_Commits import Commits
from modelsFolder.model_Files import Files
from modelsFolder.model_Features import Features
from modelsFolder.model_Associations import Associations
from modelsFolder.model_Authors import Authors
from modelsFolder.model_SettingsFiles import ModelSettingsFiles
import pymongo


client = pymongo.MongoClient(MongoDBConnect)



