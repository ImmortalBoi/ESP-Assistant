# curl http://localhost:8080/v1/config \
#     --include \
#     --header "Content-Type: application/json" \
#     --request "POST" \
#     --data '{"Peripherals":[{"Pin":2,"Name":"lights","Type":"LED","Value":0},{"Pin":5,"Name":"serve","Type":"Servo","Value":180}],"Request":"I want the light to keep on blinking on and off every 1 second interval while swinging the motor left and right","Result":"No results","Result_Datatype":"void"}'\
#     -o data.json
# echo

curl http://localhost:8080/v2/user \
    --include \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data '{"Name":"test8","Password":"test"}'\
    -o data.json
echo


# curl http://localhost:8080/v2/session/test/test -o data2.json
# echo

# curl http://localhost:8080/v2/config \
#     --include \
#     --header "Content-Type: application/json" \
#     --request "POST" \
#     --data '{"Config":{"Peripherals":[{"Pin":27,"Name":"IN1_PIN","Type":"IN_PIN","Value":0},{"Pin":26,"Name":"IN2_PIN","Type":"IN_PIN","Value":0},{"Pin":25,"Name":"IN3_PIN","Type":"IN_PIN","Value":0},{"Pin":33,"Name":"IN4_PIN","Type":"IN_PIN","Value":0},{"Pin":14,"Name":"ENA_PIN","Type":"IN_PIN","Value":0},{"Pin":32,"Name":"ENB_PIN","Type":"IN_PIN","Value":0}],"Request":"My pins are connected to an H-bridge connected to two motors to make a car, create code to run the car","Result":"No results","Result_Datatype":"void"},"Username":"test"}'\
#     -o data.json
# echo

# curl http://localhost:8080/v2/config \
#     --include \
#     --header "Content-Type: application/json" \
#     --request "POST" \
#     --data '{"Config":{"Peripherals":[{"Pin": 5, "Name": "TRIG_PIN", "Type": "OUTPUT", "Value": 0}, {"Pin": 18, "Name": "ECHO_PIN", "Type": "OUTPUT", "Value": 0}, {"Pin": 14, "Name": "relay", "Type": "PUMP_PIN", "Value": 0}],"Request":"My ESP32 is connected to a Water Tank of size 100 cm through a pump, the speed of sound is 0.034, My ESP is also connected to an ultrasonic sensor HC-SR04 that is above the pump that detects the height of it, generate code to control the water Tank","Result":"On the press of active I want the pump to push water out such that if the distance exceeds a threshold of 20 cm, indicating a low water level, activate the pump through a relay module until the water level reaches a desired level of around 80 cm.","Result_Datatype":"void"},"Username":"test"}'\
#     -o data.json
# echo

# curl http://localhost:8080/v2/config \
#     --include \
#     --header "Content-Type: application/json" \
#     --request "POST" \
#     --data '{"Config":{"Peripherals":[{"Pin": 21, "Name": "FAN", "Type": "FAN_Pin", "Value": 0}, {"Pin": 32, "Name": "LDR", "Type": "LDR_PIN", "Value": 0}, {"Pin": 27, "Name": "DHT 11", "Type": "DHT11_PIN", "Value": 0}, {"Pin": 33, "Name": "LED", "Type": "LED_PIN", "Value": 0}],"Request":"My ESP32 is connected to a fan that turns on and off and a LED that also turns on and off, alongside them are sensors for light using LDR and sensors for temperature and humidity, generate code to control fan and LED","Result":"On the press of active I want to read the humidity and temperature and if the ight level is low turn on the led and if the temp or humidity is high turn on the fan","Result_Datatype":"void"},"Username":"test"}' \
#     -o data.json
# echo