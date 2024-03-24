aws s3 cp s3://esp32-assistant-bucket/Container/ /home/ec2-user/Container/ --recursive
docker build -t arduino-cli-compile:latest .
docker commit -t arduino-cli-compile:latest .
docker run arduino-cli-compile:latest