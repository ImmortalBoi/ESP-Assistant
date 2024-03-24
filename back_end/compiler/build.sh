docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -a -q)
aws s3 cp s3://esp32-assistant-bucket/Container/ /home/ec2-user/Container/ --recursive
sudo docker build -t arduino-cli-compile:v2 .
docker run -d -p 5000:5000 arduino-cli-compile:v2
docker logs --follow $(docker ps -a -q)