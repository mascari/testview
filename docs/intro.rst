.. _intro_toplevel:

==================
Overview / Install
==================

TestView is a framework that helps developers to select and prioritize quality assurance efforts, combining information from source code versioning repositories with a maintainability model.

Requirements
===========

* `Python`_ 3.6 or newer
* `Git`_
* `MongoDB`_
* `Flutter`_

.. _Python: https://www.python.org
.. _Git: https://git-scm.com/
.. _MongoDB: https://www.mongodb.com/
.. _Flutter: https://flutter.dev/

Backend API Source Code
===========

TestView's git repo is available on GitHub, which can be browsed at:

 * https://github.com/mascari/testview

and cloned using::

    $ git clone https://github.com/mascari/testview.git

Optionally (but suggested), make use of virtualenv:
    
    $ python3 -m venv venv
    $ env\Scripts\activate

Install the requirements::
    
    $ pip install -r requirements.txt

Configure the username and password for backend mongodb service:
Edit the file backend\config.py and include the credentials for the mongodb service.

Execute the database migration and start the backend service:

    $ cd backend
    
    $ python migrate.py
    
    $ python app.py

Install Flutter for web run the Frontend web UI:

    $ cd testview
    
    $ cd frontend
    
    $ flutter run -d chrome


How to cite TestView
=====================

.. sourcecode:: none

    @inbook{TestView,
        title = "TestView: Framework for Test Selection and Prioritization"
        doi = "",
        booktitle = "",
    }

