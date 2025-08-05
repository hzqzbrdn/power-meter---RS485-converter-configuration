import serial
import time

# Common baud rates for Dragino
baud_rates = [9600, 19200, 115200]
PORT = "/dev/ttyUSB0"  # Update if needed

def test_baudrate(baud):
    try:
        print(f"🔌 Testing {baud} baud...")
        with serial.Serial(PORT, baud, timeout=2) as ser:
            time.sleep(1)  # Allow device to initialize
            ser.write(b"AT\r\n")
            print(">>> Sent: AT")
            time.sleep(0.5)

            if ser.in_waiting:
                response = ser.read_all().decode(errors="ignore").strip()
                print(f"<<< Received: {response}")
                return True
            else:
                print("⚠️  No response at this baud rate.")
                return False
    except Exception as e:
        print(f"Error testing {baud} baud: {e}")
        return False

if __name__ == "__main__":
    for baud in baud_rates:
        if test_baudrate(baud):
            print(f"✅ Device responded successfully at {baud} baud.")
            break
    else:
        print("❌ No response from device. Check wiring or adapter type.")
