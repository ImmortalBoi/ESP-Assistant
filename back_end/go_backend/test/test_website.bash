curl http://ec2-18-191-97-70.us-east-2.compute.amazonaws.com:8080/config \
    --include \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data '{"Peripherals":[{"Pin":2,"Name":"lights","Type":"LED","Value":0},{"Pin":5,"Name":"serve","Type":"Servo","Value":180}],"Request":"I want the light to keep on blinking on and off every 1 second interval while swinging the motor left and right","Result":"No results","Result_Datatype":"void"}'\
    -o data.json
echo

# curl http://ec2-18-191-97-70.us-east-2.compute.amazonaws.com:8080/

# curl http://ec2-3-70-238-15.eu-central-1.compute.amazonaws.com:5000/compile \
#     --include \
#     --header "Content-Type: application/x-www-form-urlencoded" \
#     --request POST \
#     --data-urlencode "code=void setup() {\npinMode(2, OUTPUT);\n}\nvoid loop() {\ndigitalWrite(2, HIGH);\ndelay(1000);\ndigitalWrite(2, LOW);\ndelay(1000);\n}"
# echo