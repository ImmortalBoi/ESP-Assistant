aws s3 cp s3://esp32-assistant-bucket/ESP32-Backend/ /home/ec2-user/backend/ --recursive
sudo systemctl stop web-service
go build -o main main.go
sudo systemctl daemon-reload && sudo systemctl enable web-service && sudo systemctl start web-service