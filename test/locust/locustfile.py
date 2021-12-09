from src import config
from locust import HttpUser, task, between
from datetime import datetime
from termcolor import colored
from bs4 import BeautifulSoup
import re

import resource
resource.setrlimit(resource.RLIMIT_NOFILE, (4096, 4096))

class LoginWithUniqueUserSteps(HttpUser):
    wait_time = between(1, 2)
    host = config.HOST
    tiempo_inicial = datetime.now()
    session = False

    @task
    def login(self):

        try:
            t1 = datetime.now()
            if self.session == False:
                respuesta = self.client.get("/login")
                print(respuesta.text)
                soup = BeautifulSoup(respuesta.text)
                token = soup.find('input', {'name':'authenticity_token'})['value']
                print(token)

                headers ={
                    "Content-Type": "application/x-www-form-urlencoded"
                } 
                data = {

                    "authenticity_token": token,
                    "user[username]": config.USER,
                    "user[password]": config.PASSWORD,
                    "commit": "Ingresar"
                }
            
                respuesta = self.client.post("/login", data=data, headers=headers)
                self.session = True
                print(respuesta)
            else:
                respuesta = self.client.get("/subarticles")
                print(respuesta)
            t2 = datetime.now()
            print(colored("Tarea completada en: {}".format(t2 - t1), 'green', attrs=["bold"]))
        except Exception as e:
            print(colored("Se ha producido un error: {}".format(e), 'red', attrs=["bold"]))