#!/bin/bash

# Install Go
wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.22.1

# Create a directory to store the project
mkdir -p /home/ec2-user/backend

# Download the backend code from S3
aws s3 cp s3://esp32-assistant-bucket/ESP32-Backend/ /home/ec2-user/backend/ --recursive

# Navigate to the project directory
cd /home/ec2-user/

sudo chmod 777 backend/

# Navigate to the project directory
cd /home/ec2-user/backend

# Compile the Go code
go build -o main main.go

# Start a service
sudo mv /home/ec2-user/backend/web-service.service /etc/systemd/system/web-service.service
sudo systemctl daemon-reload && sudo systemctl enable web-service && sudo systemctl start web-service

sudo yum install nginx

# Run the compiled executable
./main
