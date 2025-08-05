#!/bin/bash

PORT="COM3"   # Update based on your adapter
INITIAL_BAUD="9600"
NEW_BAUD="19200"

# Configure serial port
configure_serial() {
    stty -F "$1" $2 cs8 -cstopb -parenb -echo -ixon -crtscts raw
}

# Function to send and read response
send_command() {
    local CMD=$1
    echo -ne "${CMD}\r\n" > "$PORT"
    echo ">>> Sent: $CMD"

    # Wait and read response (max 2 seconds)
    RESPONSE=$(timeout 2 cat < "$PORT")
    if [[ -n "$RESPONSE" ]]; then
        echo "<<< Response: $RESPONSE"
    else
        echo "⚠️ No response received."
    fi

    sleep 0.5
}

echo "🔌 Setting up serial port at $INITIAL_BAUD..."
configure_serial "$PORT" "$INITIAL_BAUD"
sleep 1

# Step 1: Send baud rate change command
send_command "AT+BAUDR=19200"

echo "⏳ Waiting for Dragino to apply new baud rate..."
sleep 2

# Step 2: Switch to new baud rate
echo "🔁 Switching serial to $NEW_BAUD..."
configure_serial "$PORT" "$NEW_BAUD"
sleep 1

# Remaining commands
AT_COMMANDS=(
  "AT+PARITY=2"
  "AT+DATABIT=8"
  "AT+STOPBIT=0"
  "AT+COMMAND1=01 03 0b b8 00 06,1"
  "AT+SEARCH1=0,0"
  "AT+DATACUT1=17,2,4~15"
  "AT+CMDDL1=0"
  "AT+COMMAND2=01 03 0b cc 00 0c,1"
  "AT+SEARCH2=0,0"
  "AT+DATACUT2=29,2,4~27"
  "AT+CMDDL2=0"
  "AT+COMMAND3=01 03 0b ee 00 06,1"
  "AT+SEARCH3=0,0"
  "AT+DATACUT3=17,2,4~15"
  "AT+CMDDL3=0"
  "AT+COMMAND4=01 03 0b 06 00 06,1"
  "AT+SEARCH4=0,0"
  "AT+DATACUT4=17,2,4~15"
  "AT+CMDDL4=0"
  "AT+COMMAND5=01 03 0c 26 00 02,1"
  "AT+SEARCH5=0,0"
  "AT+DATACUT5=9,2,4~7"
  "AT+CMDDL5=0"
)

for CMD in "${AT_COMMANDS[@]}"; do
    send_command "$CMD"
done

echo "✅ RS485-BL configuration completed with ACK check."
