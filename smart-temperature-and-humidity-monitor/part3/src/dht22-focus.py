import adafruit_dht
import board
import time
import json
import os
import sys
import subprocess
import logging
from datetime import datetime

# 로깅 설정
def setup_logging():
    log_dir = 'logs'
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)

    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(
                os.path.join(log_dir, f'sensor_{datetime.now().strftime("%Y%m%d")}.log')
            ),
            logging.StreamHandler(sys.stderr)
        ]
    )
    return logging.getLogger(__name__)

def read_dht22_sensor():
    stderr = sys.stderr
    sys.stderr = open(os.devnull, 'w')
    sensor = adafruit_dht.DHT22(board.D4)
    max_attempts = 10
    attempts = 0

    try:
        while attempts < max_attempts:
            try:
                temperature = sensor.temperature
                humidity = sensor.humidity

                # 센서 데이터 유효성 검사
                if not (isinstance(temperature, (int, float)) and isinstance(humidity, (int, float))):
                    raise ValueError("Invalid sensor data types")
                if not (-40 <= temperature <= 80 and 0 <= humidity <= 100):
                    raise ValueError("Sensor values out of valid range")

                return {
                    "temperature": round(temperature, 1),
                    "humidity": round(humidity, 1),
                    "result": True
                }
            except Exception as e:
                attempts += 1
                if attempts < max_attempts:
                    time.sleep(2)
                continue

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

def send_to_focus(data, logger):
    try:
        # result 키 제거 및 JSON 문자열 생성
        send_data = {k: v for k, v in data.items() if k != 'result'}
        json_str = json.dumps(send_data)

        # focus 명령어 구성
        focus_cmd = [
            'echo',
            json_str,
            '|',
            './focus',
            '-license', 'x479s23j7it9r-*************-z4dan9rfga5htf',
            '-pcode', '7*****',
            '-server.host', '13.124.*.*',
            '-category', 'sensor',
            '-onetime'
        ]

        # 명령어 실행
        cmd = ' '.join(focus_cmd)
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

        if result.returncode == 0:
            logger.info(f"Data sent successfully: {json_str}")
            return True
        else:
            logger.error(f"Focus command failed: {result.stderr}")
            return False

    except Exception as e:
        logger.error(f"Error sending data: {str(e)}")
        return False

def main():
    logger = setup_logging()
    logger.info("Starting DHT22 sensor monitoring")

    # 종료 핸들링을 위한 플래그
    running = True

    try:
        while running:
            try:
                # 센서 데이터 읽기
                sensor_data = read_dht22_sensor()

                # 유효한 데이터인 경우에만 전송
                if sensor_data["result"]:
                    success = send_to_focus(sensor_data, logger)
                    if not success:
                        logger.warning("Failed to send data, will retry in next iteration")
                else:
                    logger.warning("Failed to read sensor data")

                # 다음 읽기까지 대기
                time.sleep(2)

            except KeyboardInterrupt:
                logger.info("Program terminated by user")
                running = False
            except Exception as e:
                logger.error(f"Unexpected error in main loop: {str(e)}")
                time.sleep(2)  # 오류 발생 시 잠시 대기 후 재시도

    except Exception as e:
        logger.critical(f"Critical error in main program: {str(e)}")
    finally:
        logger.info("Program terminated")

if __name__ == "__main__":
    main()