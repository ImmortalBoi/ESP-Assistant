#!/bin/bash

# Install Go
wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.22.1
source ~/.bashrc

# Create a directory to store the project
mkdir -p /home/ec2-user/backend

# Download the backend code from S3
aws s3 cp s3://esp32-assistant-bucket/ESP32-Backend/ /home/ec2-user/backend/ --recursive

sudo chmod 777 /home/ec2-user/backend/build.bash
./home/ec2-user/backend/build.bash

cd /home/ec2-user/backend/
go build -o main main.go
sudo systemctl daemon-reload && sudo systemctl enable web-service && sudo systemctl start web-service

sudo yum install docker
sudo systemctl start docker
sudo systemctl enable docker

mkdir -p /home/ec2-user/Container
aws s3 cp s3://esp32-assistant-bucket/Container/ /home/ec2-user/Container/ --recursive

cd /home/ec2-user/Container/
sudo docker build -t arduino-cli-compile:v2 .
docker run -d -p 5000:5000 arduino-cli-compile:v2


# Compile the Go code
# go build -o main main.go

# Start a service
# sudo mv /home/ec2-user/backend/web-service.service /etc/systemd/system/web-service.service
# sudo systemctl daemon-reload && sudo systemctl enable web-service && sudo systemctl start web-service



# Run the compiled executable
./main
