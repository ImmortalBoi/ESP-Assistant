# curl http://localhost:8080/v1/config \
#     --include \
#     --header "Content-Type: application/json" \
#     --request "POST" \
#     --data '{"Peripherals":[{"Pin":2,"Name":"lights","Type":"LED","Value":0},{"Pin":5,"Name":"serve","Type":"Servo","Value":180}],"Request":"I want the light to keep on blinking on and off every 1 second interval while swinging the motor left and right","Result":"No results","Result_Datatype":"void"}'\
#     -o data.json
# echo

# curl http://localhost:8080/v1/config \
#     --include \
#     --header "Content-Type: application/json" \
#     --request "POST" \
#     --data '{"Peripherals":[{"Pin":27,"Name":"motor1pin1","Type":"DC Motor","Value":0},{"Pin":26,"Name":"motor1pin2","Type":"DC Motor","Value":0},{"Pin":25,"Name":"motor2pin1","Type":"DC Motor","Value":0},{"Pin":33,"Name":"motor2pin2","Type":"DC Motor","Value":0},{"Pin":14,"Name":"motor1En","Type":"motorEnable","Value":0},{"Pin":32,"Name":"motor2En","Type":"motorEnable","Value":0}],"Request":"Without using ESP32Servo give me a code for motor drive for a car project with pin declarations","Result":"No results","Result_Datatype":"void"}'\
#     -o data.json
# echo

# curl http://localhost:8080/v2/user \
#     --include \
#     --header "Content-Type: application/json" \
#     --request "POST" \
#     --data '{"Name":"test","Password":"test"}'\
#     -o data.json
# echo


curl http://localhost:8080/v2/session/test/test -o data.json
echo