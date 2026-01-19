# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HeartfeltCall (따듯한 전화) is a dementia health management system for elderly people living alone. The system consists of:

- **memorion**: Flutter app for dependents (elderly users) - handles voice-based health check calls
- **memorion_caregiver**: Flutter app for caregivers - monitors dependents' health status and analysis results
- **newserver**: FastAPI backend server with JWT authentication, MySQL database
- **ai**: Standalone FastAPI service for voice analysis using TensorFlow/librosa

## Quick Start (Windows)

### 1. MySQL Setup
```bash
# Install MySQL
winget install Oracle.MySQL

# Initialize data directory (avoid Program Files permission issues)
mkdir C:\mysql_data
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqld" --initialize-insecure --datadir="C:/mysql_data"

# Start MySQL server (run in separate terminal)
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqld" --datadir="C:/mysql_data" --console

# Create database and user
"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql" -u root -e "CREATE DATABASE IF NOT EXISTS heartfeltcall DEFAULT CHARACTER SET utf8mb4; CREATE USER IF NOT EXISTS 'castberry'@'%' IDENTIFIED BY 'qhdks'; GRANT ALL PRIVILEGES ON heartfeltcall.* TO 'castberry'@'%'; FLUSH PRIVILEGES;"
```

### 2. Backend Server Setup
```bash
cd newserver

# Install core dependencies (skip tensorflow for backend-only)
pip install fastapi "uvicorn[standard]" SQLAlchemy pymysql python-dotenv "passlib[bcrypt]" "python-jose[cryptography]" pydantic pydantic-settings httpx openai google-cloud-texttospeech

# IMPORTANT: Install missing packages
pip install email-validator python-multipart

# IMPORTANT: Fix bcrypt compatibility (passlib + bcrypt 5.0 conflict)
pip install "bcrypt<5.0.0"

# Create .env file
# (see Environment Configuration section below)

# Start server
uvicorn app.main:app --reload --port 8000
```

### 3. Flutter Setup
```bash
# Download and install Flutter (if not installed)
curl -L -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip
unzip flutter.zip -d C:\

# Upgrade to latest (requires Dart 3.10+ for this project)
C:\flutter\bin\flutter upgrade

# Run apps
cd memorion
echo "BASE_URL=http://10.0.2.2:8000" > .env
flutter pub get
flutter run -d chrome --web-port=3000

cd memorion_caregiver
echo "BASE_URL=http://10.0.2.2:8000" > .env
flutter pub get
flutter run -d chrome --web-port=3001
```

## Development Commands

### Backend Server (newserver)
```bash
cd newserver

# Install dependencies
pip install -r requirements.txt
pip install email-validator python-multipart "bcrypt<5.0.0"  # Required extras

# Development server (hot reload)
uvicorn app.main:app --reload --port 8000

# Verify server
curl http://localhost:8000/system/health
# Expected: {"status":"ok"}
```

### AI Analysis Service
```bash
cd ai

# Requires Python 3.10-3.12 (NOT 3.13 - numpy/tensorflow incompatible)
pip install tensorflow==2.15.0 librosa==0.10.2.post1 numpy==1.26.4 matplotlib

uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

### Flutter Apps
```bash
cd memorion          # or memorion_caregiver
flutter pub get
flutter run -d chrome --web-port=3000  # Web testing (no Android SDK needed)
flutter run                             # Device/emulator
flutter build apk                       # Android release
```

### Database
MySQL schema is in `db/create.sql`. Tables auto-create on server startup via SQLAlchemy.

## Known Issues & Solutions

### Python Version Compatibility
- **Problem**: Python 3.13 fails to install `numpy==1.26.4` and `tensorflow==2.15.0`
- **Solution**: Use Python 3.10, 3.11, or 3.12

### bcrypt + passlib Conflict
- **Problem**: `bcrypt>=5.0.0` breaks passlib password hashing
- **Solution**: `pip install "bcrypt<5.0.0"`

### Missing Dependencies in requirements.txt
- **Problem**: Server fails with missing `email-validator` or `python-multipart`
- **Solution**: `pip install email-validator python-multipart`

### MySQL Permission Denied (Windows)
- **Problem**: Cannot create data directory in Program Files
- **Solution**: Use custom data directory in user folder: `--datadir="C:/Users/USERNAME/mysql_data"`

### Flutter SDK Version
- **Problem**: `SDK version ^3.8.1` error
- **Solution**: Run `flutter upgrade` to get Dart 3.10+

## Building APK for Android

### 1. Install Android Studio (for Android SDK)
```bash
winget install Google.AndroidStudio
```

After installation:
1. Run Android Studio → Complete Setup Wizard (Standard)
2. Go to **Tools → SDK Manager → SDK Tools**
3. Check **Android SDK Command-line Tools (latest)** → Apply

### 2. Accept Android Licenses
```bash
flutter doctor --android-licenses
# Answer 'y' to all

flutter doctor
# Verify: Android toolchain shows ✓
```

### 3. Build APK
```bash
# Dependent app (memorion)
cd memorion
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (~48MB)

# Caregiver app (memorion_caregiver)
cd memorion_caregiver
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (~54MB)
```

### 4. Install on Phone
```bash
# Via ADB (requires USB debugging enabled)
adb install memorion/build/app/outputs/flutter-apk/app-release.apk
adb install memorion_caregiver/build/app/outputs/flutter-apk/app-release.apk
```

Or manually copy APK to phone and install via file manager.

**Note**: Enable "Install from unknown sources" in phone settings.

## Architecture

### Backend (newserver/app/)
- `api/v1/` - Route handlers (auth, dependents, voice, analyses, invitations, system)
- `models/` - SQLAlchemy ORM models (User, Dependent, Call, Analysis, VoiceSession, Invitation)
- `schemas/` - Pydantic request/response schemas
- `services/` - Business logic (analysis, questions, tts, storage)
- `core/` - Config, database, security (JWT auth)

### Authentication Flow
Two token types:
1. **Caregiver token**: Via `/auth/login`, JWT sub=user_id
2. **Dependent token**: Via `/auth/dependent/exchange` after invitation code acceptance, sub="dependent:{id}"

### Invitation/Connection Flow
1. Dependent app creates invitation code (`POST /connections`)
2. Caregiver accepts with their token (`POST /connections/accept`)
3. Dependent exchanges for access token (`POST /auth/dependent/exchange`)

### Flutter Apps Structure
Both apps follow similar patterns:
- `lib/screens/` - UI screens
- `lib/services/` - API clients, local storage, voice handling
- `lib/const/` - Theme, colors, constants
- `lib/components/` - Reusable widgets (caregiver app only)

### Voice Analysis Pipeline
1. Dependent records voice answers via memorion app
2. Audio uploaded to newserver (`POST /voice/sessions/{id}/answer`)
3. Server calls AI service (`POST /system/voice-analysis`)
4. AI runs TensorFlow analysis on mel spectrograms → returns dementia risk score
5. Results stored in `analyses` table with state: NORMAL/MCI/DEMENTIA

## Environment Configuration

Both servers require `.env` files. Key variables:
- `DATABASE_URL` - MySQL connection string
- `SECRET_KEY` - JWT signing key
- `MEDIA_ROOT` - File storage path
- `OPENAI_API_KEY` - For TTS/question generation (optional)

Flutter apps load `.env` via flutter_dotenv for API base URL configuration.

## API Reference

See `newserver/API_SPEC_KR.txt` for complete endpoint documentation in Korean.

## Database Schema

See `db/create.sql` for full schema. Key tables:
- `users` - Caregivers and dependents (role-based)
- `dependents` - Dependent profiles linked to caregivers
- `voice_sessions` - Voice recording sessions
- `calls` - Individual call records with audio files
- `analyses` - Dementia risk analysis results
- `connection_codes` - Invitation code management
