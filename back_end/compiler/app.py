import os
import boto3
import yaml
from flask import Flask, jsonify
import compile
import uuid
import shutil

app = Flask(__name__)


@app.route("/compile", methods=["GET"])
def compile_upload():
    dir_name = uuid.uuid4().hex
    folder_path = os.mkdir(os.path(f"/usr/src/sketch/dist/{dir_name}"))
    sketch_file = open("sketch.ino").read()
    with open(os.join(folder_path,"sketch.ino"),"x") as f:
        f.write(sketch_file)

    try:
        f = open("project.yaml", "r")
        spec = yaml.safe_load(f)
        result,success = compile.compile_sketch(spec)

    except IOError as e:
        print("Specification file project.yaml not found", flush=True)
        return jsonify({"msg": "Specification file project.yaml not found"}), 500

    except yaml.YAMLError as e:
        print("Something wrong with the syntax of project.yaml: %s" % e, flush=True)
        return jsonify({"msg": "Something wrong with the syntax of project.yaml: %s" % e}), 500

    if success == True:
        bucket_name = 'esp32-assistant-bucket'
        folder_name = 'Container/dist'

        status, message = upload_directory_to_s3(bucket_name, folder_path, folder_name)
        return jsonify({"msg": message}), status
    else:
        return jsonify({"msg": result}), 500

def upload_directory_to_s3(bucket_name, folder_name, bucket_folder):
    s3 = boto3.client('s3')
    for root, dirs, files in os.walk(folder_name):
        for file in files:
            local_file_path = os.path.join(root, file)
            s3_key = os.path.join(folder_name, file)
            try:
                s3.upload_file(local_file_path, bucket_name, f"{bucket_folder}/{file.split('/')[-1]}")
                print(f"File {local_file_path} uploaded to {bucket_name}/{s3_key} successfully.")

            except Exception as e:
                print(f"Error uploading file {local_file_path} to S3: {e}")
                return 500, f"Some bin files may have been uploaded successfully"

    return 200, f"Bin files uploaded successfully."

if __name__ == "__main__":
    # Please do not set debug=True in production
    app.run(host="0.0.0.0", port=5000, debug=True)

