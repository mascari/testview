# TestView
TestView is a framework that helps developers to select and prioritize quality assurance efforts, combining information from source code versioning repositories with a maintainability model.

## How to install and contribute

1) Install a local MongoDB database: 

   https://docs.mongodb.com/manual/installation/

2) Clone the repository:
```
git clone https://github.com/mascari/testview.git
```

3) Go to the backend service folder:
```
cd testview\backend
```

4) Create a Virtual Environment (Python 3.6):
```
python3 -m venv venv
source venv/bin/activate
```

5) Activate the Virtual Environment:
```
source env/bin/activate (Linux/macOS)
or
env\Scripts\activate (Windows)
```

6) Install the requirements:
```
pip install -r requirements.txt
```
7) Configure the username and password for mongodb service:

Edit the file backend\config.py and include the credentials for the mongodb service.

8) Execute the database migration and start the backend service
```
python migrate.py
python app.py
```

9) Install Flutter for web:
https://flutter.dev/docs/get-started/install

10) Run the Frontend web UI:
```
cd testview\frontend
flutter run -d chrome
```
