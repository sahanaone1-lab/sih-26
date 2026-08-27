-- Migration: 002_create_consultation_schema.sql
-- Description: Creates temporary consultation sessions and documents tables.

CREATE TABLE IF NOT EXISTS consultation_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
  patient_id UUID, -- Optional, if logged in
  qr_token VARCHAR(255) UNIQUE NOT NULL,
  fallback_code VARCHAR(20),
  status VARCHAR(20) NOT NULL DEFAULT 'WAITING' CHECK (status IN ('WAITING', 'ACTIVE', 'COMPLETED', 'CANCELLED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_consultation_sessions_token ON consultation_sessions(qr_token);
CREATE INDEX IF NOT EXISTS idx_consultation_sessions_doc ON consultation_sessions(doctor_id);

CREATE TABLE IF NOT EXISTS temporary_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES consultation_sessions(id) ON DELETE CASCADE,
  original_filename VARCHAR(255) NOT NULL,
  storage_key TEXT NOT NULL,
  mime_type VARCHAR(100),
  file_size BIGINT,
  status VARCHAR(20) NOT NULL DEFAULT 'UPLOADED' CHECK (status IN ('UPLOADED', 'DELETED')),
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_temporary_documents_session ON temporary_documents(session_id);
