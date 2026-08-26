-- ============================================================================
-- Migration: 001_create_hospital_admin_schema.sql
-- Description: Hospital Onboarding, Verification Lifecycle & Admin Portal Schema
-- Database: PostgreSQL (Supabase)
-- ============================================================================

-- 1. Enable UUID Extension (Available by default in Supabase)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- REUSABLE TRIGGER FUNCTION: Updated At Timestamp
-- ============================================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TABLE 1: hospitals
-- Core entity storing AYUSH hospital facility registration & verification status
-- ============================================================================
CREATE TABLE IF NOT EXISTS hospitals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id VARCHAR(50) NOT NULL UNIQUE,
  facility_name VARCHAR(255) NOT NULL,
  facility_type VARCHAR(100) NOT NULL,
  ayush_system VARCHAR(100) NOT NULL DEFAULT 'Ayurveda',
  state VARCHAR(100) NOT NULL,
  district VARCHAR(100) NOT NULL,
  address TEXT NOT NULL,
  pin_code VARCHAR(10),
  official_email VARCHAR(255) NOT NULL UNIQUE,
  official_phone VARCHAR(20) NOT NULL,
  
  -- Regulatory IDs (HFR ID is explicitly OPTIONAL)
  registration_number VARCHAR(100) NOT NULL,
  ayush_id VARCHAR(100),
  hfr_id VARCHAR(100),
  
  -- Verification Lifecycle Status
  verification_status VARCHAR(30) NOT NULL DEFAULT 'pending'
    CHECK (verification_status IN ('pending', 'under_review', 'verified', 'rejected')),
  
  rejection_reason TEXT,
  verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Partial Unique Index for optional HFR ID (enforces uniqueness only when HFR ID is provided)
CREATE UNIQUE INDEX IF NOT EXISTS idx_hospitals_hfr_id_unique 
  ON hospitals(hfr_id) 
  WHERE hfr_id IS NOT NULL AND hfr_id <> '';

-- Indexes for frequent queries (Status filtering, State/District analytics, Search)
CREATE INDEX IF NOT EXISTS idx_hospitals_verification_status ON hospitals(verification_status);
CREATE INDEX IF NOT EXISTS idx_hospitals_state_district ON hospitals(state, district);
CREATE INDEX IF NOT EXISTS idx_hospitals_official_email ON hospitals(official_email);
CREATE INDEX IF NOT EXISTS idx_hospitals_created_at ON hospitals(created_at DESC);

-- Trigger for auto-updating updated_at on hospitals
DROP TRIGGER IF EXISTS trg_hospitals_updated_at ON hospitals;
CREATE TRIGGER trg_hospitals_updated_at
  BEFORE UPDATE ON hospitals
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- TABLE 2: user_profiles (Supabase Auth Mapping & Role-Based Access Control)
-- Links Supabase auth.users to application roles (system_admin, hospital_admin)
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role VARCHAR(30) NOT NULL DEFAULT 'hospital_admin'
    CHECK (role IN ('system_admin', 'hospital_admin')),
  hospital_id UUID REFERENCES hospitals(id) ON DELETE SET NULL,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone_number VARCHAR(20),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_user_profiles_hospital_id ON user_profiles(hospital_id);

DROP TRIGGER IF EXISTS trg_user_profiles_updated_at ON user_profiles;
CREATE TRIGGER trg_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- TABLE 3: hospital_officials
-- Medical Superintendents, Nodal Officers & Authorized Representatives
-- ============================================================================
CREATE TABLE IF NOT EXISTS hospital_officials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
  full_name VARCHAR(255) NOT NULL,
  designation VARCHAR(100) NOT NULL,
  official_email VARCHAR(255) NOT NULL,
  official_phone VARCHAR(20) NOT NULL,
  is_primary BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hospital_officials_hospital_id ON hospital_officials(hospital_id);

DROP TRIGGER IF EXISTS trg_hospital_officials_updated_at ON hospital_officials;
CREATE TRIGGER trg_hospital_officials_updated_at
  BEFORE UPDATE ON hospital_officials
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- ============================================================================
-- TABLE 4: hospital_documents
-- Metadata for uploaded verification certificates (Stored in Supabase Storage)
-- ============================================================================
CREATE TABLE IF NOT EXISTS hospital_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
  document_type VARCHAR(50) NOT NULL
    CHECK (document_type IN ('registration_certificate', 'authorized_official_id', 'ayush_accreditation', 'other')),
  storage_path TEXT NOT NULL,
  original_filename VARCHAR(255) NOT NULL,
  mime_type VARCHAR(100),
  file_size_bytes BIGINT,
  document_status VARCHAR(30) NOT NULL DEFAULT 'pending'
    CHECK (document_status IN ('pending', 'approved', 'rejected')),
  rejection_reason TEXT,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hospital_documents_hospital_id ON hospital_documents(hospital_id);
CREATE INDEX IF NOT EXISTS idx_hospital_documents_type ON hospital_documents(document_type);

-- ============================================================================
-- TABLE 5: hospital_verification_history
-- Immutable audit ledger of all verification reviews, status transitions & notes
-- ============================================================================
CREATE TABLE IF NOT EXISTS hospital_verification_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  hospital_id UUID NOT NULL REFERENCES hospitals(id) ON DELETE CASCADE,
  previous_status VARCHAR(30),
  new_status VARCHAR(30) NOT NULL
    CHECK (new_status IN ('pending', 'under_review', 'verified', 'rejected')),
  action VARCHAR(50) NOT NULL,
  rejection_reason TEXT,
  notes TEXT,
  admin_auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_verification_history_hospital_id ON hospital_verification_history(hospital_id);
CREATE INDEX IF NOT EXISTS idx_verification_history_created_at ON hospital_verification_history(created_at DESC);
