# HeartfeltCall Technical Design Document (TDD)

## 1. 개요

### 1.1 프로젝트 소개

HeartfeltCall(따뜻한 전화)은 독거노인을 위한 치매 건강 관리 시스템입니다. 음성 기반 건강 체크를 통해 인지 상태를 모니터링하고, 보호자에게 분석 결과를 제공합니다.

### 1.2 시스템 목표

- 독거노인의 일상적인 음성 응답을 통한 인지 상태 모니터링
- AI 기반 음성 분석으로 치매 조기 발견
- 보호자에게 실시간 분석 결과 및 히스토리 제공
- 간편한 피보호자-보호자 연결 시스템

### 1.3 기술 스택

| 구분 | 기술 |
|------|------|
| Backend | FastAPI (Python 3.10+) |
| Database | MySQL 8.0+ |
| AI Service | TensorFlow 2.15, librosa |
| Mobile (Dependent) | Flutter 3.24+ |
| Mobile (Caregiver) | Flutter 3.24+ |
| Authentication | JWT (python-jose) |
| TTS | Google Cloud Text-to-Speech |

---

## 2. 시스템 아키텍처

### 2.1 전체 구조

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                            │
├─────────────────────────────────┬───────────────────────────────┤
│     memorion (Flutter)          │    memorion_caregiver         │
│     (피보호자 앱)                │    (보호자 앱)                 │
└─────────────────┬───────────────┴───────────────┬───────────────┘
                  │                               │
                  ▼                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                         API Gateway                             │
│                    newserver (FastAPI)                          │
│                      :8000                                      │
├─────────────────────────────────────────────────────────────────┤
│  /auth/*     - 인증/인가                                        │
│  /dependents/* - 피보호자 관리                                   │
│  /voice/*    - 음성 세션/녹음                                    │
│  /analyses/* - 분석 결과 조회                                    │
│  /connections/* - 연결 코드 관리                                 │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Data Layer                                │
├─────────────────────────────────┬───────────────────────────────┤
│         MySQL 8.0               │      File Storage             │
│    (heartfeltcall DB)           │    (MEDIA_ROOT)               │
└─────────────────────────────────┴───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                       AI Service                                │
│                    ai (FastAPI)                                 │
│                      :8001                                      │
├─────────────────────────────────────────────────────────────────┤
│  POST /analyze  - 음성 분석                                      │
│  - TensorFlow 모델 기반 치매 위험도 분석                          │
│  - Mel Spectrogram 생성                                         │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 디렉토리 구조

```
heartfeltcall/
├── newserver/              # Backend API Server
│   ├── app/
│   │   ├── api/
│   │   │   ├── deps.py     # 의존성 주입 (인증, DB)
│   │   │   └── v1/         # API 라우터
│   │   │       ├── auth.py
│   │   │       ├── dependents.py
│   │   │       ├── voice.py
│   │   │       ├── analyses.py
│   │   │       ├── invitations.py
│   │   │       └── system.py
│   │   ├── core/
│   │   │   ├── config.py   # 환경 설정
│   │   │   ├── database.py # DB 연결
│   │   │   └── security.py # JWT, 비밀번호
│   │   ├── models/         # SQLAlchemy ORM
│   │   │   ├── user.py
│   │   │   ├── dependent.py
│   │   │   ├── voice_session.py
│   │   │   ├── call.py
│   │   │   ├── analysis.py
│   │   │   └── invitation.py
│   │   ├── schemas/        # Pydantic 스키마
│   │   └── services/       # 비즈니스 로직
│   │       ├── analysis.py
│   │       ├── questions.py
│   │       ├── tts.py
│   │       └── storage.py
│   └── requirements.txt
│
├── ai/                     # AI Analysis Service
│   ├── main.py
│   ├── model/              # TensorFlow 모델
│   └── requirements.txt
│
├── memorion/               # Flutter (Dependent App)
│   ├── lib/
│   │   ├── screens/
│   │   ├── services/
│   │   └── const/
│   └── pubspec.yaml
│
├── memorion_caregiver/     # Flutter (Caregiver App)
│   ├── lib/
│   │   ├── screens/
│   │   ├── services/
│   │   └── components/
│   └── pubspec.yaml
│
├── db/
│   └── create.sql          # DB 스키마
│
└── docs/
    ├── ERD.md
    └── TDD.md
```

---

## 3. 인증 시스템

### 3.1 토큰 유형

| 토큰 유형 | 발급 엔드포인트 | Subject 형식 | 용도 |
|----------|----------------|-------------|------|
| Caregiver Token | POST /auth/login | `{user_id}` | 보호자 API 접근 |
| Dependent Token | POST /auth/dependent/exchange | `dependent:{dependent_id}` | 피보호자 앱 API 접근 |

### 3.2 인증 흐름

```mermaid
sequenceDiagram
    participant CA as Caregiver App
    participant DA as Dependent App
    participant API as Backend API
    participant DB as Database

    Note over CA,DB: 1. 보호자 회원가입/로그인
    CA->>API: POST /auth/signup
    API->>DB: Create User (role=CAREGIVER)
    API-->>CA: {success: true}

    CA->>API: POST /auth/login
    API->>DB: Verify credentials
    API-->>CA: {access_token: "jwt..."}

    Note over CA,DB: 2. 피보호자 프로필 생성
    CA->>API: POST /dependents
    API->>DB: Create Dependent
    API-->>CA: {id, name, ...}

    Note over DA,DB: 3. 피보호자 앱 연결
    DA->>API: POST /connections
    API->>DB: Create Invitation (code, dependent_id)
    API-->>DA: {code: "ABC123", expires_at}

    CA->>API: POST /connections/accept {code}
    API->>DB: Update Invitation (caregiver_id, status=connected)
    API-->>CA: {success, auth_code}

    DA->>API: POST /auth/dependent/exchange {auth_code}
    API->>DB: Verify auth_code, mark used
    API-->>DA: {access_token: "jwt..."} (sub=dependent:{id})
```

### 3.3 JWT 토큰 구조

```json
{
  "sub": "123",           // 또는 "dependent:456"
  "exp": 1735689600,
  "iat": 1735603200
}
```

---

## 4. API 설계

### 4.1 엔드포인트 목록

#### 인증 (Auth)

| Method | Endpoint | 인증 | 설명 |
|--------|----------|------|------|
| POST | /auth/signup | - | 보호자 회원가입 |
| POST | /auth/login | - | 보호자 로그인 |
| GET | /auth/me | Caregiver | 내 정보 조회 |
| POST | /auth/dependent/exchange | - | 피보호자 토큰 교환 |
| GET | /auth/dependent/me | Dependent | 피보호자 프로필 조회 (NEW) |

#### 피보호자 (Dependents)

| Method | Endpoint | 인증 | 설명 |
|--------|----------|------|------|
| POST | /dependents | Caregiver | 피보호자 생성 |
| GET | /dependents | Caregiver | 피보호자 목록 |
| GET | /dependents/{id} | Caregiver | 피보호자 상세 |
| PUT | /dependents/{id} | Caregiver | 피보호자 수정 |
| DELETE | /dependents/{id} | Caregiver | 피보호자 삭제 (soft) |

#### 음성 세션 (Voice)

| Method | Endpoint | 인증 | 설명 |
|--------|----------|------|------|
| POST | /voice/sessions | Dependent | 세션 시작 |
| GET | /voice/sessions/{id}/question | Dependent | 질문 목록 조회 |
| GET | /voice/sessions/{id}/question/{file} | Dependent | 질문 오디오 다운로드 |
| POST | /voice/sessions/{id}/answer | Dependent | 응답 업로드 + 분석 |
| DELETE | /voice/sessions/{id} | Dependent | 세션 종료 |

#### 분석 (Analyses)

| Method | Endpoint | 인증 | 설명 |
|--------|----------|------|------|
| GET | /dependents/{id}/analyses/latest | Caregiver | 최신 분석 결과 |
| GET | /dependents/{id}/analyses/history | Caregiver | 분석 히스토리 |

#### 연결 (Connections)

| Method | Endpoint | 인증 | 설명 |
|--------|----------|------|------|
| POST | /connections | - | 연결 코드 생성 |
| GET | /connections/{code}/status | - | 연결 상태 조회 (폴링) |
| POST | /connections/accept | Caregiver | 연결 코드 수락 |

### 4.2 응답 형식

**성공 응답:**
```json
{
  "success": true,
  "data": { ... }
}
```

**에러 응답:**
```json
{
  "detail": "Error message"
}
```

**HTTP 상태 코드:**
- `200 OK` - 성공
- `201 Created` - 생성 성공
- `400 Bad Request` - 잘못된 요청
- `401 Unauthorized` - 인증 실패
- `403 Forbidden` - 권한 없음
- `404 Not Found` - 리소스 없음

---

## 5. 음성 분석 파이프라인

### 5.1 분석 흐름

```mermaid
sequenceDiagram
    participant App as Dependent App
    participant API as Backend API
    participant AI as AI Service
    participant DB as Database

    App->>API: POST /voice/sessions
    API-->>App: {session_id, token}

    App->>API: GET /voice/sessions/{id}/question
    API-->>App: [{name: "a1.wav", url: "..."}]

    App->>API: GET /voice/sessions/{id}/question/a1.wav
    API-->>App: [Audio File]

    Note over App: 사용자 음성 녹음

    App->>API: POST /voice/sessions/{id}/answer
    Note over API: 파일 저장 (MEDIA_ROOT)

    API->>AI: POST /analyze {audio_files}
    Note over AI: Mel Spectrogram 생성
    Note over AI: TensorFlow 모델 추론
    AI-->>API: {score: 0.35, mel_image: "base64..."}

    API->>DB: UPDATE dependent (last_state)
    API->>DB: INSERT analysis
    API-->>App: {success: true, score: 0.35}
```

### 5.2 AI 분석 로직

1. **전처리**
   - 오디오 파일 로드 (librosa)
   - 샘플링 레이트 정규화 (16kHz)
   - 노이즈 제거

2. **특징 추출**
   - Mel Spectrogram 생성
   - MFCC (Mel-Frequency Cepstral Coefficients)

3. **모델 추론**
   - TensorFlow CNN 모델
   - 입력: Mel Spectrogram 이미지
   - 출력: 치매 위험 점수 (0.0 ~ 1.0)

4. **결과 해석**
   - `0.0 ~ 0.3`: 정상 (NORMAL)
   - `0.3 ~ 0.7`: 경도 인지장애 (MCI)
   - `0.7 ~ 1.0`: 치매 의심 (DEMENTIA)

---

## 6. 피보호자-보호자 연결 흐름

### 6.1 시퀀스 다이어그램

```mermaid
sequenceDiagram
    participant DA as Dependent App
    participant CA as Caregiver App
    participant API as Backend API
    participant DB as Database

    Note over DA: 1. 피보호자 앱 설치 후 연결 시작
    DA->>API: POST /connections
    API->>DB: INSERT invitation (code, dependent_id=NULL)
    Note over DB: status = 'pending'
    API-->>DA: {code: "ABC123XYZ", expires_at}

    Note over DA,CA: 2. 연결 코드를 보호자에게 전달 (구두/문자)

    Note over CA: 3. 보호자 앱에서 코드 입력
    CA->>API: POST /connections/accept {code: "ABC123XYZ"}
    API->>DB: SELECT invitation WHERE code = ?
    API->>DB: UPDATE invitation SET caregiver_id, status='connected'
    API->>DB: INSERT/UPDATE dependent (caregiver_id)
    API-->>CA: {success, dependent_id, auth_code}

    Note over DA: 4. 피보호자 앱에서 토큰 교환
    DA->>API: POST /auth/dependent/exchange {auth_code}
    API->>DB: Verify auth_code, mark 'used'
    API-->>DA: {access_token: "jwt..."}

    Note over DA: 5. 이후 dependent 토큰으로 API 접근
```

### 6.2 초대 코드 상태

| 상태 | 설명 |
|------|------|
| pending | 코드 생성됨, 아직 수락 안 됨 |
| connected | 보호자가 수락함, auth_code 발급됨 |
| used | 피보호자가 토큰 교환 완료 |
| expired | 만료됨 |

---

## 7. 데이터 흐름

### 7.1 일일 건강 체크 흐름

```
┌─────────────────────────────────────────────────────────────────┐
│                    Daily Health Check Flow                      │
└─────────────────────────────────────────────────────────────────┘

[피보호자 앱]                [Backend]                 [AI Service]
     │                          │                          │
     │  1. 세션 시작            │                          │
     │  POST /voice/sessions    │                          │
     │ ─────────────────────────>                          │
     │                          │                          │
     │  2. 질문 오디오 다운로드  │                          │
     │  GET .../question/a1.wav │                          │
     │ <─────────────────────────                          │
     │                          │                          │
     │  3. (질문 재생, 응답 녹음)│                          │
     │                          │                          │
     │  4. 응답 업로드          │                          │
     │  POST .../answer         │                          │
     │ ─────────────────────────>                          │
     │                          │  5. 분석 요청            │
     │                          │  POST /analyze           │
     │                          │ ─────────────────────────>
     │                          │                          │
     │                          │  6. 분석 결과            │
     │                          │ <─────────────────────────
     │                          │                          │
     │  7. 결과 반환            │                          │
     │ <─────────────────────────                          │
     │                          │                          │

[보호자 앱]
     │
     │  8. 분석 결과 조회
     │  GET .../analyses/latest
     │ ─────────────────────────>
     │                          │
     │  9. 결과 표시            │
     │ <─────────────────────────
```

### 7.2 데이터 저장 흐름

```
음성 파일 → MEDIA_ROOT/call-{session}-{uuid}/answer{1-3}.wav
           ↓
AI 분석 → Mel Spectrogram 생성
           ↓
분석 결과 → DB: analyses 테이블
           ↓
최신 상태 → DB: dependents.last_state 업데이트
```

---

## 8. 보안 고려사항

### 8.1 인증/인가

- JWT 기반 stateless 인증
- 토큰 만료 시간: 24시간 (설정 가능)
- 비밀번호 해시: bcrypt (cost factor 12)
- 초대 코드 만료: 1시간

### 8.2 데이터 보호

- 민감 정보 (이메일, 전화번호) 암호화 권장
- 음성 파일 분석 후 즉시 삭제
- Soft delete로 복구 가능성 유지

### 8.3 API 보안

- CORS 설정 필수
- Rate limiting 권장
- HTTPS 필수 (프로덕션)

---

## 9. 환경 설정

### 9.1 Backend (.env)

```bash
# Database
DATABASE_URL=mysql+pymysql://castberry:qhdks@localhost/heartfeltcall

# Security
SECRET_KEY=your-256-bit-secret-key
ACCESS_TOKEN_EXPIRE_MINUTES=1440
ALGORITHM=HS256

# Storage
MEDIA_ROOT=./media
QUESTIONS_ROOT=q

# AI Service (for voice analysis)
AI_SERVICE_URL=http://localhost:8001

# Gemini LLM (for question generation)
GEMINI_API_KEY=your-gemini-api-key
GEMINI_MODEL=gemini-2.5-flash

# Google Cloud TTS (for question audio)
GOOGLE_TTS_ENABLED=true
GOOGLE_TTS_LANGUAGE=ko-KR
GOOGLE_TTS_VOICE=ko-KR-Wavenet-A
GOOGLE_APPLICATION_CREDENTIALS=./service-account.json

# Questions
DAILY_QUESTIONS_COUNT=3
```

### 9.2 Flutter Apps (.env)

```bash
BASE_URL=http://10.0.2.2:8000  # Android Emulator
# BASE_URL=http://localhost:8000  # Web
```

---

## 10. 배포 가이드

### 10.1 개발 환경

```bash
# Backend
cd newserver
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# AI Service
cd ai
pip install -r requirements.txt
uvicorn main:app --reload --port 8001

# Flutter
cd memorion
flutter run -d chrome --web-port=3000
```

### 10.2 프로덕션 권장사항

- Backend: Gunicorn + Uvicorn workers
- Database: MySQL 복제, 백업 설정
- 파일 스토리지: S3 또는 GCS
- 로드 밸런서: nginx
- 모니터링: Prometheus + Grafana

---

## 11. 향후 개선 사항

### 11.1 기능 개선

- [ ] 실시간 알림 (WebSocket/FCM)
- [ ] 다국어 지원
- [ ] 음성 인식 (STT) 통합
- [ ] 분석 결과 리포트 PDF 생성

### 11.2 기술 개선

- [ ] Redis 캐시 레이어
- [ ] GraphQL API 지원
- [ ] 마이크로서비스 분리
- [ ] CI/CD 파이프라인

### 11.3 AI 개선

- [ ] 모델 버전 관리
- [ ] A/B 테스트
- [ ] 지속적 학습 파이프라인
