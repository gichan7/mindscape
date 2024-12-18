# 나만의 스마트 온습도 모니터링 시스템 구축 프로젝트 (1/4)

발행일: November 28, 2024
작성자: Gichan Nam
카테고리: 와탭모니터링

# 프로젝트 소개

스마트홈 시대가 본격적으로 도래하면서 온습도 모니터링 IoT 기기와 관련 서비스들이 넘쳐나고 있습니다. Tuya의 SmartLife, 국내 헤이홈, TP-Link의 Tapo, 삼성이 인수한 SmartThings 등 다양한 선택지가 존재합니다. 이러한 제품들은 Wi-Fi 연결과 모바일 앱 등록만으로도 손쉽게 사용할 수 있는 장점이 있지만, 개발자의 관점에서 보면 몇 가지 아쉬운 점도 있습니다. 

**대부분의 서비스는 데이터를 1분 또는 1시간 단위로 수집하는데, 이러한 데이터 수집 주기는 세밀한 모니터링이 필요한 상황에서는 충분하지 않을 수 있습니다.** 

이와 같은 문제를 해결하려는 목적에서 이번 프로젝트를 진행하게 되었습니다. 더 세밀한 데이터 수집과 실시간 알림을 통해 스마트홈 환경을 보다 효율적으로 관리하고자 하며, 이를 와탭을 활용하여 구현해보려고 합니다. 

# 왜 와탭으로 구축해야 할까?

와탭을 활용하면 다음과 같은 장점들이 있습니다. 

- **5초 단위**까지 데이터 수집 주기 설정 가능
- **직관적인 대시보드**를 통한 데이터 시각화
- **Open API**를 통한 데이터 접근성 제공
- **Grafana 연동**으로 커스텀 대시보드 구성 가능
- **실시간 알림 설정** 기능 제공

이러한 시스템은 단순한 취미 프로젝트를 넘어 스마트팜과 같은 실용적인 프로젝트로 확장할 수 있는 가능성도 제공합니다. 

# 프로젝트 구현 과정

이 시리즈에서는 총 세 가지 단계로 나누어 프로젝트를 진행할 예정입니다. 

### **1. 하드웨어 구성**

- 라즈베리파이 셋업
- 온습도 센서 연결 및 테스트
- 데이터 수집 환경 구축

### **2. 와탭 연동**

- 수집한 데이터 와탭으로 전송 구현
- 대시보드 구성
- 알림 설정

### **3. 모바일 앱 개발**

- 와탭 Open API 활용
- 실시간 모니터링 앱 구현

# 사용할 하드웨어

### **라즈베리파이(**Raspberry Pi)

라즈베리파이는 영국의 라즈베리 재단에서 개발한 교육용 미니 컴퓨터입니다. 2012년 1세대 Model B 출시 이후, 현재는 Raspberry Pi 5까지 출시했고, 최신 버전은 개인용 PC로도 사용 가능한 성능을 제공합니다. 작은 크기와 저전력 특성으로 산업용으로도 활용되고 있습니다. 

이번 프로젝트에서는 Zero 2 W 모델을 사용합니다. 이 모델은 6.5cm x 3cm의 크기, 1GHZ quad-core 64-bit Arm 프로세서, 512MB SDRAM을 탑재했으며 Wi-Fi를 지원합니다. 작은 크기와 저렴한 가격이 특징입니다. 직접 지원하는 Raspberry Pi OS 를 비롯한 다양한 리눅스 배포판을 사용할 수 있습니다. 

[https://lh7-rt.googleusercontent.com/docsz/AD_4nXfyHpIkXJ0if-OVmqOfcJelpzWzbrhKIgdOAeNpsGBtEexY69htOQN7plZdueLBZ-y-euE-THOKwFeiuRCHHIgCnI1j8uHVvObnR8fOfO0c_S8ktZKcPh9NqygOKvttppkQoeFvQw?key=SLMFdQr2JwT98xCRr8VO5N3b](https://lh7-rt.googleusercontent.com/docsz/AD_4nXfyHpIkXJ0if-OVmqOfcJelpzWzbrhKIgdOAeNpsGBtEexY69htOQN7plZdueLBZ-y-euE-THOKwFeiuRCHHIgCnI1j8uHVvObnR8fOfO0c_S8ktZKcPh9NqygOKvttppkQoeFvQw?key=SLMFdQr2JwT98xCRr8VO5N3b)

이미지 설명: Raspberry Pi Zero 2 W

### 온습도 센서

다양한 온습도 센서들이 있으며, DHT11, DHT22, SHT31, BME280 등이 국내에서 쉽게 구할 수 있습니다. 그 중에서 경제적이고 설치가 용이한 DHT22(AM2302)를 선택했습니다. 

**DHT22(AM2302) 주요 스펙**

- 온도 측정 범위: -40~80°C ( ±0.5°C )
- 습도 측정 범위: 0-100% RH ( ±2-5% )
- Digital 1-Wire 방식
- 샘플링 주기: 2초

[https://lh7-rt.googleusercontent.com/docsz/AD_4nXc0LIP-XDpoVo_fVv7W5OR2RCdBh00O2tkDCobV2U_IzeHQ1b_IHQV-Zq-Yff8ZuU2cQVFoIU2le_208ONiHU5FZYvX86_Bs58Xl_MMoXn_BzxHUpl3wXEzF8UbrwDLRhp43yi9?key=SLMFdQr2JwT98xCRr8VO5N3b](https://lh7-rt.googleusercontent.com/docsz/AD_4nXc0LIP-XDpoVo_fVv7W5OR2RCdBh00O2tkDCobV2U_IzeHQ1b_IHQV-Zq-Yff8ZuU2cQVFoIU2le_208ONiHU5FZYvX86_Bs58Xl_MMoXn_BzxHUpl3wXEzF8UbrwDLRhp43yi9?key=SLMFdQr2JwT98xCRr8VO5N3b)

# 사용할 소프트웨어

### WhaTap Focus

https://docs.whatap.io/focus/introduction

WhaTap Focus는 외부 시계열 데이터를 와탭 서비스로 손쉽게 전송할 수 있는 기능을 제공합니다. 이 기능을 통해 에이전트가 기본적으로 수집하지 않는 사용자 데이터를 모니터링할 수 있습니다.

### WhaTap Server

https://docs.whatap.io/server/introduction

WhaTap Server는 서버에 에이전트를 설치하여 기본적인 시스템 메트릭을 수집할 수 있으며, WhaTap Focus를 통해 추가 데이터 모니터링도 가능합니다.

### WhaTap Open API

https://docs.whatap.io/openapi-spec

와탭에 저장된 데이터를 REST API를 통해 조회할 수 있습니다. 와탭의 쿼리 언어인 MXQL([https://docs.whatap.io/mxql/mxql-overview](https://docs.whatap.io/mxql/mxql-overview))을 지원하여 다양한 데이터도 쉽게 검색하고 활용할 수 있습니다.

# 다음 글 예고

이 시리즈에서는 와탭의 다양한 기능들을 활용하여 온습도 모니터링 시스템을 구축할 예정입니다. 라즈베리파이에서 수집한 센서 데이터는 WhaTap Focus를 통해 전송하고, WhaTap Server로 라즈베리파이의 상태를 감시하며, Open API를 통해 모바일 앱에서 데이터를 시각화할 것입니다. 

# 시리즈 구성

### **1부: 프로젝트 개요 (현재)**

- 프로젝트 소개
- 사용할 하드웨어
- 사용할 소프트웨어

### **2부: 하드웨어 구성**

- 라즈베리파이 (Zero 2 W) 설정
- 온습도 센서 (DHT22) 연결
- 데이터 수집 환경 구축

### **3부: 와탭 연동**

- WhaTap Focus 설정
- 데이터 전송 구현
- WhaTap 대시보드 및 알림 구성

### **4부: 모바일 앱 개발**

- WhaTap Open API 연동
- 실시간 모니터링 앱 구현

이번 시리즈를 통해 IoT 디바이스부터 모니터링 시스템, 모바일 앱까지 통합된 스마트 모니터링 솔루션을 단계별로 구현해보겠습니다. 기대해주세요!