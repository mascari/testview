
How to execute the backend service: 

    in backend/ run: (with python 3.6) 
    
        python -m venv env
        
        
    then: (You will need to do this every new terminal)
    
        source env/bin/activate     (Linux/MacOS)
        
        or
        
        env\Scripts\activate        (Windows)


    Now, install the requirements:
    
        pip install -r requirements.txt

    
    Change the username and password of the database in config.py

    run:
        python migrate.py

    Now the project is ready, you can run:
        python app.py