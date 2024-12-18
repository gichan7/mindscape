import adafruit_dht
import board
import time
import json
import os
import sys

def read_dht22_sensor():
    stderr = sys.stderr
    sys.stderr = open(os.devnull, 'w')

    sensor = adafruit_dht.DHT22(board.D4)

    max_attempts = 5
    attempts = 0

    try:
        while attempts < max_attempts:
            try:
                temperature = sensor.temperature
                humidity = sensor.humidity

                sensor_data = {
                    "temperature": round(temperature, 1),
                    "humidity": round(humidity, 1),
                    "result": True
                }

                return sensor_data

            except:
                attempts += 1
                time.sleep(2)

        return {
            "temperature": 0,
            "humidity": 0,
            "result": False
        }

    finally:
        sys.stderr = stderr

        try:
            sensor.exit()
        except:
            pass

def main():
    sensor_data = read_dht22_sensor()
    print(json.dumps(sensor_data, indent=2))

if __name__ == "__main__":
    main()
