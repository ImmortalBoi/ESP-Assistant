import pprint
import google.generativeai as palm

palm.configure(api_key='AIzaSyDS6MJnQ9pai5Na_ifyNBXfRElsHt434js')

models = [m for m in palm.list_models() if 'generateText' in m.supported_generation_methods]
model = models[0].name
print(model)

prompt = """
I have an application that requires a formatted answer, you are to answer all prompts in this format: -[Pin number]-[Pin value] 
DO NOT add any other lines that are not in the format: -[Pin number]-[Pin value] 
DO NOT add explanations 
My user's request is "Rotate the motor by another 30 degrees and turn off the lights" 
His connected peripherals are Servo motor at pin A0 with value: 512, LED at pin 14 with value:1
Please reply with the pin number and pin value that would fulfill their request keeping in mind that this is an arduino application 
"""

completion = palm.generate_text(
    model=model,
    prompt=prompt,
    temperature=0,
    # The maximum length of the response
    max_output_tokens=800,
)

print(completion.result)


