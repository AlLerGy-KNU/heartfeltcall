# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HeartfeltCall (따듯한 전화) is a dementia health management system for elderly people living alone. The system consists of:

- **memorion**: Flutter app for dependents (elderly users) - handles voice-based health check calls
- **memorion_caregiver**: Flutter app for caregivers - monitors dependents' health status and analysis results
- **newserver**: FastAPI backend server with JWT authentication, MySQL database
- **ai**: Standalone FastAPI service for voice analysis using TensorFlow/librosa

## Development Commands

### Backend Server (newserver)
```bash
cd newserver

# Install dependencies
pip install -r requirements.txt

# Development server (hot reload)
./run.sh                    # or: uvicorn app.main:app --reload --port 8000

# Start in background
./start.sh
```

### AI Analysis Service
```bash
cd ai
uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

### Flutter Apps
```bash
cd memorion          # or memorion_caregiver
flutter pub get
flutter run
flutter build apk   # Android release
```

### Database
MySQL schema is in `db/create.sql`. Tables auto-create on server startup via SQLAlchemy.

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
