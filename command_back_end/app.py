from flask import Flask, request, jsonify
from flask_mqtt import Mqtt
from info import Info
import json

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, World!"

@app.route('/command', methods=['POST'])
def command():
    app.config['MQTT_BROKER_URL'] = 'broker.emqx.io'
    app.config['MQTT_BROKER_PORT'] = 1883
    app.config['MQTT_USERNAME'] = 'ESP32testing'  # Set your username here
    app.config['MQTT_PASSWORD'] = '123456'  # Set your password here

    mqtt = Mqtt(app)
    mqtt.init_app(app)
    if request.method == 'POST':
        try:
            # Get regime data from POST req
            data = request.get_json()
            print(data)
            transcript = data["Transcript"]
        except Exception as error:
            print(error)
            return jsonify({'Transcript': 'Please supply this parameter'})

        try:
            peripherals = data["Peripherals"]
        except Exception as error:
            print(error)
            return jsonify({'Peripherals': 'Please supply this parameter'})    

        print(f"Transcript: {transcript}, Peripherals: {peripherals}")       
        voice:Info = Info(transcript,peripherals) 
        print(voice.prompt)
        results = voice.understand()
        for result in results:
            if "servo" in result.lower():
                for i in range(len(results[result])):
                    dataJson = {}
                    dataJson[results[result][i][0]] = results[result][i][1]
                    print(dataJson)
                    mqtt.publish('emqx/esp32/SERVO',json.dumps(dataJson))

            if "led" in result.lower():
                for i in range(len(results[result])):
                    dataJson = {}
                    dataJson[results[result][i][0]] = results[result][i][1]
                    print(dataJson)
                    mqtt.publish('emqx/esp32/LED',json.dumps(dataJson))

            if "temperature" in result.lower():
                for i in range(len(results[result])):
                    dataJson = {}
                    dataJson[results[result][i][0]] = results[result][i][1]
                    mqtt.publish('emqx/esp32/TEMPERATURE',json.dumps(dataJson))

        mqtt.publish('emqx/esp32/p',voice.transcript)

        return jsonify({
            "Valid": "Sent succefully"
        })

    else:
        return jsonify({'message': 'Invalid method'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

