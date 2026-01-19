# 따듯한 전화 (HeartfeltCall)

독거어르신을 위한 AI 기반 치매건강관리시스템

## Team Memorion

---

## 프로젝트 소개

**따듯한 전화**는 혼자 거주하시는 어르신들의 치매 건강 상태를 음성 통화 기반으로 모니터링하는 시스템입니다. AI가 음성을 분석하여 치매 위험도를 평가하고, 보호자가 실시간으로 어르신의 건강 상태를 확인할 수 있습니다.

---

## 주요 기능

- **음성 기반 건강 체크**: 매일 3개의 질문에 대한 음성 답변 녹음
- **AI 음성 분석**: 멜스펙트로그램 변환 + TensorFlow 딥러닝 모델로 치매 위험도 분석
- **치매 위험도 감지**: NORMAL(정상), MCI(경도인지장애), DEMENTIA(치매) 3단계 분류
- **보호자 대시보드**: 피보호자 목록, 검사 이력, 월별 추이 차트 제공
- **초대 코드 연결**: 피보호자 앱에서 생성한 코드로 보호자와 안전하게 연결
- **알림 기능**: 예약된 시간에 건강 체크 알림

---

## 시스템 구성

| 구성요소 | 설명 | 포트 |
|---------|------|------|
| **memorion** | 피보호자(어르신) Flutter 앱 | - |
| **memorion_caregiver** | 보호자 Flutter 앱 | - |
| **newserver** | FastAPI 백엔드 서버 | 8000 |
| **ai** | AI 음성 분석 서비스 | 8001 |

---

## 기술 스택

### Flutter 앱 (memorion, memorion_caregiver)
- Dart SDK: ^3.8.1
- 주요 패키지: flutter_dotenv, http, shared_preferences, record, audioplayers
- 차트: syncfusion_flutter_charts (보호자 앱)
- 폰트: Pretendard

### 백엔드 서버 (newserver)
- FastAPI >= 0.115.0
- SQLAlchemy >= 2.0.36
- MySQL (pymysql)
- JWT 인증 (python-jose, passlib)
- OpenAI TTS (선택사항)

### AI 분석 서비스 (ai)
- TensorFlow 2.15.0
- librosa 0.10.2.post1 (오디오 처리)
- numpy, matplotlib

### 데이터베이스
- MySQL 8.0
- 문자셋: utf8mb4 (한글 지원)

---

## 설치 및 실행

### 1. 사전 요구사항

| 구성요소 | 버전 | 비고 |
|---------|------|------|
| Python | 3.10 ~ 3.12 | ⚠️ 3.13은 numpy/tensorflow 호환 문제 |
| Flutter SDK | 3.38+ | Dart 3.10+ 필요 |
| MySQL | 8.0+ | 8.4 권장 |
| (선택) OpenAI API Key | - | TTS 기능용 |

### 2. MySQL 설치 및 설정

#### Windows (winget)
```bash
# MySQL 설치
winget install Oracle.MySQL

# 데이터 디렉토리 초기화 (Program Files 권한 문제 시)
mkdir C:\mysql_data
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqld" --initialize-insecure --datadir="C:/mysql_data"

# MySQL 서버 실행
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqld" --datadir="C:/mysql_data" --console

# 다른 터미널에서 데이터베이스 생성
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql" -u root -e "CREATE DATABASE IF NOT EXISTS heartfeltcall DEFAULT CHARACTER SET utf8mb4; CREATE USER IF NOT EXISTS 'castberry'@'%' IDENTIFIED BY 'qhdks'; GRANT ALL PRIVILEGES ON heartfeltcall.* TO 'castberry'@'%'; FLUSH PRIVILEGES;"
```

#### Linux/Mac
```bash
# MySQL 설치 후
mysql -u root -p < db/create.sql
```

### 3. 백엔드 서버 설정 및 실행

```bash
cd newserver

# 가상환경 생성 (권장)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 핵심 패키지 설치 (requirements.txt의 tensorflow 제외)
pip install fastapi "uvicorn[standard]" SQLAlchemy pymysql python-dotenv "passlib[bcrypt]" "python-jose[cryptography]" pydantic pydantic-settings httpx openai google-cloud-texttospeech

# ⚠️ 중요: 추가 패키지 설치 (requirements.txt에 누락됨)
pip install email-validator python-multipart

# ⚠️ bcrypt 호환성 문제 해결 (passlib와 bcrypt 5.0 충돌)
pip install "bcrypt<5.0.0"

# .env 파일 생성
cat > .env << 'EOF'
APP_ENV=development
SECRET_KEY=your-secret-key-change-in-production
ACCESS_TOKEN_EXPIRE_MINUTES=1440
ALGORITHM=HS256
DATABASE_URL=mysql+pymysql://castberry:qhdks@localhost:3306/heartfeltcall
MEDIA_ROOT=./media
QUESTIONS_ROOT=q
AI_SERVICE_URL=http://localhost:8001
DAILY_QUESTIONS_COUNT=3
GOOGLE_TTS_ENABLED=false
EOF

# 개발 서버 실행
uvicorn app.main:app --reload --port 8000

# 서버 확인
curl http://localhost:8000/system/health
# 응답: {"status":"ok"}
```

### 4. AI 분석 서비스 실행

> ⚠️ AI 서비스는 TensorFlow가 필요하며, Python 3.10~3.12에서만 동작합니다.

```bash
cd ai

# 패키지 설치
pip install tensorflow==2.15.0 librosa==0.10.2.post1 numpy==1.26.4 matplotlib

# 서버 실행
uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

### 5. Flutter SDK 설치

#### Windows
```bash
# 다운로드 및 설치
curl -L -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip
unzip flutter.zip -d C:\
rm flutter.zip

# Flutter 업그레이드 (Dart 3.10+ 필요)
C:\flutter\bin\flutter upgrade

# 환경 확인
C:\flutter\bin\flutter doctor
```

#### Mac/Linux
```bash
# https://docs.flutter.dev/get-started/install 참조
```

### 6. Flutter 앱 실행

```bash
# 피보호자 앱
cd memorion

# .env 파일 생성
echo "BASE_URL=http://10.0.2.2:8000" > .env  # Android 에뮬레이터
# echo "BASE_URL=http://192.168.x.x:8000" > .env  # 실제 기기

flutter pub get
flutter run -d chrome --web-port=3000  # 웹으로 테스트
# 또는
flutter run  # 연결된 기기/에뮬레이터

# 보호자 앱
cd memorion_caregiver
echo "BASE_URL=http://10.0.2.2:8000" > .env
flutter pub get
flutter run -d chrome --web-port=3001
```

### 7. Android Studio 설치 (APK 빌드용)

APK를 빌드하려면 Android SDK가 필요합니다.

```bash
# Windows - winget으로 설치
winget install Google.AndroidStudio
```

설치 후:
1. **Android Studio 실행** → Setup Wizard에서 **Standard** 선택
2. SDK 설치 완료 대기
3. **Tools → SDK Manager → SDK Tools** 탭
4. **Android SDK Command-line Tools (latest)** 체크 후 Apply

```bash
# Flutter에서 Android 라이선스 수락
flutter doctor --android-licenses
# 모든 라이선스에 'y' 입력

# 설정 확인
flutter doctor
# Android toolchain 항목이 ✓ 표시되어야 함
```

### 8. APK 빌드

```bash
# 피보호자 앱 빌드
cd memorion
flutter build apk --release
# 출력: build/app/outputs/flutter-apk/app-release.apk (약 48MB)

# 보호자 앱 빌드
cd memorion_caregiver
flutter build apk --release
# 출력: build/app/outputs/flutter-apk/app-release.apk (약 54MB)
```

### 9. 핸드폰에 APK 설치

#### 사전 설정
핸드폰에서 **설정 → 보안 → 알 수 없는 출처의 앱 설치** 허용

#### 방법 1: USB 케이블로 전송
1. 핸드폰을 USB로 PC에 연결
2. 파일 탐색기에서 APK 파일을 핸드폰 내부 저장소로 복사
3. 핸드폰 파일 관리자에서 APK 실행하여 설치

#### 방법 2: ADB로 설치
```bash
# 개발자 옵션 → USB 디버깅 활성화 필요
adb install memorion/build/app/outputs/flutter-apk/app-release.apk
adb install memorion_caregiver/build/app/outputs/flutter-apk/app-release.apk
```

#### 방법 3: 클라우드/메신저
- Google Drive, 카카오톡 등으로 APK 전송 후 핸드폰에서 다운로드하여 설치

---

## 트러블슈팅

### Python 관련

| 문제 | 해결 |
|------|------|
| `numpy` 설치 실패 (Python 3.13) | Python 3.11 또는 3.12 사용 |
| `bcrypt` 오류 (passlib 관련) | `pip install "bcrypt<5.0.0"` |
| `email-validator` 없음 | `pip install email-validator` |
| `python-multipart` 없음 | `pip install python-multipart` |

### MySQL 관련

| 문제 | 해결 |
|------|------|
| Permission denied (Windows) | 데이터 디렉토리를 사용자 폴더로 지정 |
| 서비스 등록 실패 | 관리자 권한 필요 또는 직접 실행 |
| 연결 거부 | MySQL 서버가 실행 중인지 확인 |

### Flutter 관련

| 문제 | 해결 |
|------|------|
| Dart SDK 버전 불일치 | `flutter upgrade` 실행 |
| Android SDK 없음 | 웹으로 테스트 (`flutter run -d chrome`) |
| 패키지 충돌 | `flutter clean && flutter pub get` |

---

## 프로젝트 구조

```
heartfeltcall/
├── memorion/                    # 피보호자 Flutter 앱
│   ├── lib/
│   │   ├── main.dart           # 앱 진입점
│   │   ├── screens/            # UI 화면
│   │   │   ├── init_screen.dart    # 초기화/초대코드 입력
│   │   │   ├── home_screen.dart    # 메인 홈
│   │   │   ├── call_screen.dart    # 음성 녹음
│   │   │   └── calling_screen.dart # 통화 중 화면
│   │   ├── services/           # API 클라이언트
│   │   │   ├── api_client.dart
│   │   │   ├── voice_service.dart
│   │   │   └── invitation_service.dart
│   │   └── const/              # 테마, 색상, 상수
│   ├── assets/                 # 이미지, 폰트, 음성 샘플
│   └── pubspec.yaml
│
├── memorion_caregiver/          # 보호자 Flutter 앱
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── signin_screen.dart  # 로그인
│   │   │   ├── signup_screen.dart  # 회원가입
│   │   │   ├── main_screen.dart    # 피보호자 목록
│   │   │   └── report_screen.dart  # 분석 리포트
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── dependent_service.dart
│   │   │   └── analyses_service.dart
│   │   └── components/         # 재사용 위젯
│   └── pubspec.yaml
│
├── newserver/                   # FastAPI 백엔드
│   ├── app/
│   │   ├── main.py             # FastAPI 앱 초기화
│   │   ├── api/v1/             # API 라우터
│   │   │   ├── auth.py         # 인증 (로그인, 회원가입)
│   │   │   ├── dependents.py   # 피보호자 관리
│   │   │   ├── voice.py        # 음성 세션
│   │   │   ├── analyses.py     # 분석 결과
│   │   │   └── invitations.py  # 초대 코드
│   │   ├── models/             # SQLAlchemy ORM 모델
│   │   ├── schemas/            # Pydantic 스키마
│   │   ├── services/           # 비즈니스 로직
│   │   └── core/               # 설정, DB, 보안
│   ├── q/                      # 질문 음성 파일 (a1.wav, a2.wav, a3.wav)
│   ├── requirements.txt
│   ├── run.sh                  # 개발 서버 실행
│   └── API_SPEC_KR.txt         # API 명세서 (한국어)
│
├── ai/                         # AI 분석 서비스
│   ├── main.py                 # FastAPI 엔드포인트
│   ├── analysis.py             # 멜스펙트로그램 + TensorFlow 분석
│   └── requirements.txt
│
├── db/
│   ├── create.sql              # 데이터베이스 스키마
│   └── erd.png                 # ERD 다이어그램
│
├── CLAUDE.md                   # Claude Code 개발 가이드
└── README.md                   # 이 문서
```

---

## 인증 흐름

### 보호자 인증
1. `POST /auth/signup` - 회원가입
2. `POST /auth/login` - 로그인 → JWT 토큰 발급 (sub=user_id)
3. `GET /auth/me` - 현재 사용자 정보 조회

### 피보호자 연결
1. 피보호자 앱: `POST /connections` - 초대 코드 생성 (15분 유효)
2. 보호자 앱: `POST /connections/accept` - 초대 수락 + 피보호자 생성
3. 피보호자 앱: `GET /connections/{code}/status` - 상태 폴링
4. 연결 완료 시: `POST /auth/dependent/exchange` - 피보호자 토큰 발급

---

## 음성 분석 파이프라인

```
┌─────────────────┐
│  피보호자 앱     │
│  (memorion)     │
└────────┬────────┘
         │ 1. 음성 녹음 (3개 질문 답변)
         ▼
┌─────────────────┐
│  백엔드 서버     │
│  (newserver)    │
└────────┬────────┘
         │ 2. POST /voice/sessions/{id}/answer
         │    음성 파일 저장
         ▼
┌─────────────────┐
│  AI 분석 서비스  │
│  (ai)           │
│  ┌────────────┐ │
│  │ librosa    │ │ 3. 음성 → 멜스펙트로그램 변환
│  └────────────┘ │
│  ┌────────────┐ │
│  │ TensorFlow │ │ 4. VGG16 모델로 치매 위험도 예측
│  └────────────┘ │
└────────┬────────┘
         │ 5. 결과 반환 (score, mel_image)
         ▼
┌─────────────────┐
│  백엔드 서버     │
│  DB 저장        │
└────────┬────────┘
         │ 6. 분석 결과 저장
         ▼
┌─────────────────┐
│  보호자 앱      │
│  결과 조회      │
└─────────────────┘
```

---

## API 문서

상세한 API 명세는 `newserver/API_SPEC_KR.txt` 파일을 참조하세요.

주요 엔드포인트:
- `/auth` - 인증 (로그인, 회원가입, 토큰 교환)
- `/dependents` - 피보호자 CRUD
- `/dependents/{id}/analyses` - 분석 결과 조회
- `/voice` - 음성 세션 관리
- `/connections` - 초대 코드 관리
- `/system/health` - 헬스체크

---

## 환경 변수

### 백엔드 서버 (.env)
| 변수 | 설명 | 예시 |
|------|------|------|
| `APP_ENV` | 환경 | development, production |
| `SECRET_KEY` | JWT 서명 키 (32자 이상) | your-secret-key |
| `DATABASE_URL` | MySQL 연결 문자열 | mysql+pymysql://user:pass@host/db |
| `MEDIA_ROOT` | 미디어 저장 경로 | ./media |
| `AI_SERVICE_URL` | AI 서비스 URL | http://localhost:8001 |
| `OPENAI_API_KEY` | OpenAI API 키 (선택) | sk-... |

### Flutter 앱 (.env)
| 변수 | 설명 | 예시 |
|------|------|------|
| `BASE_URL` | 백엔드 서버 URL | http://192.168.0.10:8000 |

---

## 데이터베이스 스키마

주요 테이블:
- `users` - 사용자 (보호자/피보호자/관리자)
- `dependents` - 피보호자 상세 정보
- `voice_sessions` - 음성 녹음 세션
- `calls` - 통화 기록
- `analyses` - 분석 결과 (상태, 점수, 멜스펙트로그램 이미지)
- `connection_codes` - 초대 코드

상세 스키마: `db/create.sql`

---

## 라이선스

Team Memorion
