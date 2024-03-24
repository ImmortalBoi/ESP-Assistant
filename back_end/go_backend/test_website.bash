curl http://ec2-35-158-225-188.eu-central-1.compute.amazonaws.com:8080/config \
    --include \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data '{"id": "4","title": "The Modern Sound of Betty Carter","artist": "Betty Carter","price": 49.99}'

curl http://ec2-35-158-225-188.eu-central-1.compute.amazonaws.com:8080/

curl http://ec2-35-158-225-188.eu-central-1.compute.amazonaws.com:5000/compile \
    --include \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data '{"id": "4"}'