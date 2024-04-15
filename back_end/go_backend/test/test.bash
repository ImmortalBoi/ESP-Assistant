curl http://localhost:8080/config \
    --include \
    --header "Content-Type: application/json" \
    --request "POST" \
    --data '{"Peripherals":[{"Pin":2,"Name":"lights","Type":"LED","Value":0},{"Pin":5,"Name":"serve","Type":"Servo","Value":180}],"Request":"I want the light to keep on blinking on and off every 1 second interval while swinging the motor left and right","Result":"No results","Result_Datatype":"void"}'\
    -o data.json
echo

# curl http://localhost:8080/