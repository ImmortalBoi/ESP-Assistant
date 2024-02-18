from flask import Flask, request, jsonify
from supabase_py import create_client, Client
from flask_mqtt import Mqtt
from info import Info
import json

app = Flask(__name__)

url: str = "https://miozzuklzvrdoxedlxgd.supabase.co"
key: str = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pb3p6dWtsenZyZG94ZWRseGdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTk4NjEzMjcsImV4cCI6MjAxNTQzNzMyN30.BdbUVnw3wi7K1hdPEwDCMdYWaCtL_fwsFime0kxBWv4"
supabase: Client = create_client(url, key)

app.config['MQTT_BROKER_URL'] = 'broker.emqx.io'
app.config['MQTT_BROKER_PORT'] = 1883
app.config['MQTT_USERNAME'] = 'ESP32testing'  # Set your username here
app.config['MQTT_PASSWORD'] = '123456'  # Set your password here

mqtt = Mqtt(app)
mqtt.init_app(app)

@app.route('/')
def list_routes():
    return ['%s' % rule for rule in app.url_map.iter_rules()]

@app.route('/command', methods=['POST'])
def command():
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
            return jsonify({'Peripheral': 'Please supply this parameter'})    

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

@app.route('/session', methods=['POST'])
def session():
    data = request.get_json()
    user_name = data['user_name']
    user_password = data['user_password']

    # Query the 'User' table
    users = supabase.table('User').select().execute()
    for user in users['data']:
        if user['user_name'] == user_name and user['user_password'] == user_password:
            return jsonify({"message": "Login successful.","user_id":user['user_id']}), 200
    return jsonify({"message": "Invalid username or password.","user_name":user_name,"user_password":user_password}), 401

# Users Routes
@app.route('/users', methods=['POST'])
def create_user():
    data = request.get_json()
    res  = supabase.table('User').insert(data).execute()
    print(res)
    return jsonify(res["data"]), res['status_code']

@app.route('/users/<id>', methods=['GET'])
def get_user(id):
    user = supabase.table('User').select().eq('user_ID', id).execute()
    return jsonify(user), user['status_code']

@app.route('/users/<id>', methods=['PUT'])
def update_user(id):
    data = request.get_json()
    supabase.table('User').update(data).eq('user_ID', id).execute()
    return jsonify({"message": "User updated successfully."}), 200

@app.route('/users/<id>', methods=['DELETE'])
def delete_user(id):
    supabase.table('User').delete().eq('user_ID', id).execute()
    return jsonify({"message": "User deleted successfully."}), 200

# Peripherals Routes
@app.route('/peripherals', methods=['POST'])
def create_peripheral():
    data = request.get_json()
    try:
        supabase.table('Peripheral').insert([data])
    except:
        return jsonify({"message": "Improper format"}), 400
    
    return jsonify({"message": "Peripheral created successfully."}), 201

@app.route('/peripherals/<id>', methods=['GET'])
def get_peripheral(id):
    peripheral = supabase.table('Peripheral').select().eq('peripheral_ID', id).execute()
    return jsonify(peripheral), 200

@app.route('/peripherals/<id>', methods=['PUT'])
def update_peripheral(id):
    data = request.get_json()
    supabase.table('Peripheral').update(data).eq('peripheral_ID', id).execute()
    return jsonify({"message": "Peripheral updated successfully."}), 200

@app.route('/peripherals/<id>', methods=['DELETE'])
def delete_peripheral(id):
    supabase.table('Peripheral').delete().eq('peripheral_ID', id).execute()
    return jsonify({"message": "Peripheral deleted successfully."}), 200

# Captions Routes
@app.route('/captions', methods=['POST'])
def create_caption():
    data = request.get_json()
    # Insert data into the 'Caption' table
    supabase.table('Caption').insert([data])
    return jsonify({"message": "Caption created successfully."}), 201

@app.route('/captions/<id>', methods=['GET'])
def get_caption(id):
    caption = supabase.table('Caption').select().eq('caption_ID', id).execute()
    return jsonify(caption), 200

@app.route('/captions/<id>', methods=['PUT'])
def update_caption(id):
    data = request.get_json()
    supabase.table('Caption').update(data).eq('caption_ID', id).execute()
    return jsonify({"message": "Caption updated successfully."}), 200

@app.route('/captions/<id>', methods=['DELETE'])
def delete_caption(id):
    supabase.table('Caption').delete().eq('caption_ID', id).execute()
    return jsonify({"message": "Caption deleted successfully."}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

