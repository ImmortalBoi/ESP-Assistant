from threading import Lock
import re
import requests

class Info:
    def __init__(self) -> None:
        self.processed_counter = 0
        self.url = "" 
        self.lock = Lock()

    def get_prompt(self, url):
        url = url + "prompt/"
        headers = {'content-type': 'application/json'}
        response = requests.get(url, headers=headers)

        if response.status_code == requests.codes.ok:
            print('Prompt Request was successful')
            # print(response.json())
        else:
            print('Whoops: ', response.status_code)

        return response.json()["message"]

    def create_exercise_instance(self, exercise_name, exercise_day, exercise_data):
        hyperlink = "https://gym-gpt-zeta.vercel.app/exercise/"
        headers = {'content-type': 'application/json'}
        # Initialize your data
        data = {
            'regime': self.url,
            'exercise_name': exercise_name, 
            'exercise_day': exercise_day,
            'exercise_data': exercise_data
        }
        response = requests.post(hyperlink, json=data, headers=headers)
        if response.status_code == requests.codes.created:
            print('Request was successful')
        else:
            print('Whoops: ', response.status_code)
            print('Details: ', response.json())

        return response.json()

    def extract_and_create_exercise(self, lines):
        
        with self.lock:
            self.processed_counter += 2
            exercise_info = []

            lines[self.processed_counter-2].split('-')
            # Extract the exercise name and day using a regular expression
            match = re.match(r'- ?(.*) - (.*)', lines[self.processed_counter-2])
            if match:
                name, day = match.groups()

                # Extract the exercise information
                info = lines[self.processed_counter+1-2].strip('-- ')

                # Add the exercise to the list
                exercise_info.append((name, day, info))
            
            print(exercise_info)
            self.create_exercise_instance(exercise_info[0][0],exercise_info[0][1],exercise_info[0][2])
