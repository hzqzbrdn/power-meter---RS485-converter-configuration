#!/bin/bash

PORT="/dev/ttyUSB0"   # Update if needed
BAUD="19200"           # Try 9600 first, then 19200 or 115200

# Configure serial port
stty -F "$PORT" $BAUD cs8 -cstopb -parenb -echo -ixon -crtscts raw

# Send basic AT command
echo "Sending AT command to $PORT at $BAUD baud..."
echo -ne "AT\r\n" > "$PORT"

# Read response (2-second timeout)
RESPONSE=$(timeout 2 cat < "$PORT")

if [[ -n "$RESPONSE" ]]; then
    echo "✅ Device responded:"
    echo "$RESPONSE"
else
    echo "❌ No response received. Check wiring, adapter type, or baud rate."
fi
