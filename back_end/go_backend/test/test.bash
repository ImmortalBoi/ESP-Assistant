# curl http://localhost:8080/v1/config \
#     --include \
#     --header "Content-Type: application/json" \
#     --request "POST" \
#     --data '{"Peripherals":[{"Pin":2,"Name":"lights","Type":"LED","Value":0},{"Pin":5,"Name":"serve","Type":"Servo","Value":180}],"Request":"I want the light to keep on blinking on and off every 1 second interval while swinging the motor left and right","Result":"No results","Result_Datatype":"void"}'\
#     -o data.json
# echo


# curl http://localhost:8080/v2/user \
#     --include \
#     --header "Content-Type: application/json" \
#     --request "POST" \
#     --data '{"Name":"test","Password":"test"}'\
#     -o data.json
# echo


# curl http://localhost:8080/v2/session/test/test -o data2.json
# echo

curl http://localhost:8080/v2/config \
    --include \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data '{"Config":{"Peripherals":[{"Pin":27,"Name":"IN1_PIN","Type":"IN_PIN","Value":0},{"Pin":26,"Name":"IN2_PIN","Type":"IN_PIN","Value":0},{"Pin":25,"Name":"IN3_PIN","Type":"IN_PIN","Value":0},{"Pin":33,"Name":"IN4_PIN","Type":"IN_PIN","Value":0},{"Pin":14,"Name":"ENA_PIN","Type":"IN_PIN","Value":0},{"Pin":32,"Name":"ENB_PIN","Type":"IN_PIN","Value":0}],"Request":"My pins are connected to an H-bridge connected to two motors to make a car, create code to run the car","Result":"No results","Result_Datatype":"void"},"Username":"test"}'\
    -o data.json
echo