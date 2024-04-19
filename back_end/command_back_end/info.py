from threading import Lock
import re
import google.generativeai as palm

class Info:
    def __init__(self, transcript:str, peripherals) -> None:
        self.processed_counter = 0
        self.url = "" 
        self.lock = Lock()
        self.prompt = f"""
I have an application that requires a formatted answer, you are to answer all prompts in this format: [Peripheral type]-[Pin number]-[Pin value] 
DO NOT add any other lines that are not in the format: [Peripheral type]-[Pin number]-[Pin value] 
DO NOT add explanations 
My user's request is "{transcript}"~ 
His connected peripherals are{self.peripheralPrompt(peripherals)}
Please reply with the pin number and pin value that would fulfill their request keeping in mind that this is an arduino application 
"""
        self.transcript = ""

    def understand(self):
        palm.configure(api_key='AIzaSyDS6MJnQ9pai5Na_ifyNBXfRElsHt434js')
        model = "models/text-bison-001"

        completion:palm.types.Completion = palm.generate_text(
            model=model,
            prompt=self.prompt,
            temperature=0,
            # The maximum length of the response
            max_output_tokens=100,
        )

        if completion.result:
            print('Generation was successful: ')
            print(completion.result)
            self.transcript = completion.result

        else:
            print('Whoops: ')
            print( completion.safety_feedback)

        pattern = r"([a-zA-Z0-9-]+)-([a-zA-Z0-9-]+)-+([a-zA-Z0-9-]+)"
        matches = re.findall(pattern, completion.result)
        print(matches)
        data = {}

        for match in matches:
            print(f"Name: {match[0]}, Pin: {match[1]}, Value: {match[2]}")
            peripheral = match[0]
            pin = match[1]
            value = match[2]

            if peripheral in data:
                data[peripheral].append([pin,value])

            data[peripheral] = [[pin,value]]
        
        print(data)
        # Convert the dictionary to a JSON object

        return data

    def peripheralPrompt(self,peripherals):
        prompt = ""
        for peripheral in peripherals:
            print(peripheral)
            prompt += f" type {peripheral['component']} of name {peripheral['name']} at pin(s) {','.join([str(x) for x in peripheral['pin']])} with value: {peripheral['value']},"
        return prompt
    # def create_exercise_instance(self, exercise_name, exercise_day, exercise_data):
    #     hyperlink = "https://gym-gpt-zeta.vercel.app/exercise/"
    #     headers = {'content-type': 'application/json'}
    #     # Initialize your data
    #     data = {
    #         'regime': self.url,
    #         'exercise_name': exercise_name, 
    #         'exercise_day': exercise_day,
    #         'exercise_data': exercise_data
    #     }
    #     response = requests.post(hyperlink, json=data, headers=headers)
    #     if response.status_code == requests.codes.created:
    #         print('Request was successful')
    #     else:
    #         print('Whoops: ', response.status_code)
    #         print('Details: ', response.json())

    #     return response.json()

    # def extract_and_create_exercise(self, lines):
        
    #     with self.lock:
    #         self.processed_counter += 2
    #         exercise_info = []

    #         lines[self.processed_counter-2].split('-')
    #         # Extract the exercise name and day using a regular expression
    #         match = re.match(r'- ?(.*)-(.*)', lines[self.processed_counter-2])
    #         if match:
    #             name, day = match.groups()

    #             # Extract the exercise information
    #             info = lines[self.processed_counter+1-2].strip('-- ')

    #             # Add the exercise to the list
    #             exercise_info.append((name, day, info))
            
    #         print(exercise_info)
    #         self.create_exercise_instance(exercise_info[0][0],exercise_info[0][1],exercise_info[0][2])
