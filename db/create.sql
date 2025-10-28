CREATE DATABASE IF NOT EXISTS heartfeltcall
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

CREATE USER IF NOT EXISTS 'castberry'@'%'
  IDENTIFIED BY 'qhdks';

GRANT ALL PRIVILEGES ON heartfeltcall.* TO 'castberry'@'%';

FLUSH PRIVILEGES;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  role            ENUM('CAREGIVER','DEPENDENT','ADMIN') NOT NULL,
  name            VARCHAR(100) NOT NULL,
  email           VARCHAR(255) UNIQUE,
  phone_e164      VARCHAR(30),
  password_hash   VARCHAR(255),
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  created_at      DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at      DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at      DATETIME(6) NULL,
  INDEX idx_users_role (role),
  INDEX idx_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS dependents;
CREATE TABLE dependents (
  id                   BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id              BIGINT UNSIGNED NOT NULL,
  caregiver_id         BIGINT UNSIGNED NOT NULL,
  birth_date           DATE NULL,
  sex                  ENUM('M','F','OTHER') NULL,
  preferred_call_time  TIME NULL,
  retry_count          INT NOT NULL DEFAULT 3,
  retry_interval_min   INT NOT NULL DEFAULT 840,
  created_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at           DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  deleted_at           DATETIME(6) NULL,
  CONSTRAINT fk_dep_user    FOREIGN KEY (user_id)     REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_dep_caregiv FOREIGN KEY (caregiver_id) REFERENCES users(id) ON DELETE RESTRICT,
  UNIQUE KEY uq_dependent_user (user_id),
  INDEX idx_dep_caregiver (caregiver_id),
  INDEX idx_dep_calltime (preferred_call_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS connection_codes;
CREATE TABLE connection_codes (
  code            VARCHAR(16) PRIMARY KEY,
  dependent_id    BIGINT UNSIGNED NOT NULL,
  expires_at      DATETIME(6) NOT NULL,
  used_by         BIGINT UNSIGNED NULL,
  used_at         DATETIME(6) NULL,
  created_at      DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_cc_dependent FOREIGN KEY (dependent_id) REFERENCES dependents(id) ON DELETE CASCADE,
  CONSTRAINT fk_cc_usedby    FOREIGN KEY (used_by)     REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_cc_expires (expires_at),
  INDEX idx_cc_dependent (dependent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS voice_sessions;
CREATE TABLE voice_sessions (
  id              BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  dependent_id    BIGINT UNSIGNED NOT NULL,
  started_at      DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  ended_at        DATETIME(6) NULL,
  status          ENUM('OPEN','CLOSED','EXPIRED') NOT NULL DEFAULT 'OPEN',
  token_hash      VARCHAR(255) NULL,
  meta            JSON NULL,
  CONSTRAINT fk_vs_dep FOREIGN KEY (dependent_id) REFERENCES dependents(id) ON DELETE CASCADE,
  INDEX idx_vs_dep_started (dependent_id, started_at DESC),
  INDEX idx_vs_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS calls;
CREATE TABLE calls (
  id               BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  voice_session_id BIGINT UNSIGNED NULL,
  dependent_id     BIGINT UNSIGNED NOT NULL,
  scheduled_at     DATETIME(6) NOT NULL,
  attempt_no       INT NOT NULL DEFAULT 1,
  status           ENUM('SCHEDULED','RINGING','CONNECTED','NO_ANSWER','FAILED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
  question_audio   VARCHAR(512) NULL,
  answer_audio     VARCHAR(512) NULL,
  transcript       LONGTEXT NULL,
  diarization      JSON NULL,
  features         JSON NULL,
  connected_at     DATETIME(6) NULL,
  ended_at         DATETIME(6) NULL,
  fail_reason      VARCHAR(255) NULL,
  created_at       DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at       DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_calls_vs  FOREIGN KEY (voice_session_id) REFERENCES voice_sessions(id) ON DELETE SET NULL,
  CONSTRAINT fk_calls_dep FOREIGN KEY (dependent_id)     REFERENCES dependents(id) ON DELETE CASCADE,
  INDEX idx_calls_dep_sched (dependent_id, scheduled_at DESC),
  INDEX idx_calls_status (status),
  INDEX idx_calls_session (voice_session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP TABLE IF EXISTS analyses;
CREATE TABLE analyses (
  id             BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  call_id        BIGINT UNSIGNED NOT NULL UNIQUE,
  state          ENUM('NORMAL','MCI','DEMENTIA') NOT NULL,
  risk_score     DECIMAL(5,4) NOT NULL,
  model_version  VARCHAR(64) NOT NULL,
  reasoning      JSON NULL,
  graph_points   JSON NULL,
  created_at     DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_an_call FOREIGN KEY (call_id) REFERENCES calls(id) ON DELETE CASCADE,
  INDEX idx_an_state (state),
  INDEX idx_an_model (model_version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;