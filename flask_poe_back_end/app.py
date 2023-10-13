from flask import Flask, request, jsonify
import pprint
import google.generativeai as palm


app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, World!"


@app.route('/command', methods=['POST'])
def command():
    if request.method == 'POST':

        palm.configure(api_key='AIzaSyDS6MJnQ9pai5Na_ifyNBXfRElsHt434js')

        try:
            # Get regime data from POST req
            data = request.get_json()
            url = data["regime_url"]

            # Get message from drf
        
        except Exception as error:
            print(error)
            return jsonify({'Transcript': 'Please supply this parameter'})
        

        return jsonify({
            "Command": "Command"
        })

    else:
        return jsonify({'message': 'Invalid method'})

if __name__ == '__main__':
    app.run()

