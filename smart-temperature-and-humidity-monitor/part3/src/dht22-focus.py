import adafruit_dht
import board
import time
import json
import os
import sys
import subprocess

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
    while True:  # 무한 루프 추가
        try:
            sensor_data = read_dht22_sensor()
            
            if sensor_data["result"]:
                del sensor_data["result"]
                json_str = json.dumps(sensor_data)
                focus_cmd = f'echo \'{json_str}\' | ./focus -license x479s23j7it9r-xd9j6pp9juk78-z4dan9rfga5htf -pcode 7484 -server.host 13.124.11.223 -category sensor -onetime'
                
                try:
                    subprocess.run(focus_cmd, shell=True)
                    print(f"Data sent to focus: {json_str}", file=sys.stderr)  # 전송 성공 로그 추가
                except Exception as e:
                    print(f"Error sending data to focus: {e}", file=sys.stderr)
            else:
                print("Failed to read sensor data", file=sys.stderr)
            
            time.sleep(10)  # 10초 대기
            
        except KeyboardInterrupt:  # Ctrl+C로 프로그램 종료 가능하도록 처리
            print("\nProgram terminated by user", file=sys.stderr)
            break
        except Exception as e:
            print(f"Unexpected error: {e}", file=sys.stderr)
            time.sleep(10)  # 오류 발생시에도 10초 대기 후 재시도 

if __name__ == "__main__":
    main()