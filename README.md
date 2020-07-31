# JOOR DevOps Challenge

## Project Description

We want to develop a small Django webapp that allows users to view our pizza menu. We have started to build a locally running app, and we want to run it inside a Docker container so that we can deploy it to our Kubernetes cluster.

## Constraints

* For this project we will be using Django and Docker.
* Because of the time limit, it is NOT important to have a fully functional application at the end.
* Your interviewer is your pair! Be sure to ask questions and talk through your thoughts.

## Requirements

1. On our webpage, we will display each pizza with ingredients, price, and other information like whether the pizza is gluten-free or vegetarian. The app is backed by a SQLite database (`pizza_app/db.sqlite3`) with fixture data to be loaded from `pizza_app/pizza_data.json`.
  * In the project directory, you can run `python manage.py` to see a list of available Django management commands. Django management commmands can be used to do things like:
    - Run database migrations: `manage.py migrate`
    - Load fixture data into the database: `manage.py loaddata pizza_data.json`
  * Run `python manage.py runserver` to start the app in developer mode, and visit in the browser at: http://localhost:8000/pizza/

2. Once the application runs locally without error, let's get it running in a Docker container.

3. Once we have the Dockerized app running, let's see if we can deploy it to our Kubernetes cluster!
