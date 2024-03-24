curl http://localhost:8080/config \
    --include \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data '{"pin": 2,"value": 1,"component": "led"}'

curl http://localhost:8080/