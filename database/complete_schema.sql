-- ============================================================================
-- COMPLETE DATABASE SCHEMA FOR DOC O'CLOCK TELEMEDICINE APP
-- ============================================================================
-- This schema matches exactly with the Flutter models in the codebase
-- Run this script in Supabase SQL Editor to set up your database
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. USERS TABLE (for patients)
-- ============================================================================
-- Matches: lib/models/user_model.dart (UserModel)
CREATE TABLE IF NOT EXISTS users (
  user_id SERIAL PRIMARY KEY,
  full_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone_number VARCHAR(20) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'patient' CHECK (role IN ('patient', 'doctor')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone_number);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- ============================================================================
-- 2. DOCTOR_ACCOUNTS TABLE (for doctors)
-- ============================================================================
-- Matches: lib/models/doctor_model.dart (DoctorModel)
CREATE TABLE IF NOT EXISTS doctor_accounts (
  id SERIAL PRIMARY KEY,
  auth_user_id INTEGER UNIQUE, -- Links to Supabase auth.users if using auth
  fullname VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  mobile VARCHAR(20) NOT NULL,
  password VARCHAR(255) NOT NULL, -- Bcrypt hashed password
  role VARCHAR(20) NOT NULL DEFAULT 'doctor',
  specialization VARCHAR(255),
  bio TEXT,
  profile VARCHAR(500), -- Profile image URL
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for doctor_accounts table
CREATE INDEX IF NOT EXISTS idx_doctor_accounts_email ON doctor_accounts(email);
CREATE INDEX IF NOT EXISTS idx_doctor_accounts_mobile ON doctor_accounts(mobile);

-- ============================================================================
-- 3. DOCTORS TABLE (additional doctor details)
-- ============================================================================
-- Used for storing additional doctor information
CREATE TABLE IF NOT EXISTS doctors (
  id SERIAL PRIMARY KEY,
  doctor_account_id INTEGER NOT NULL REFERENCES doctor_accounts(id) ON DELETE CASCADE,
  specialization VARCHAR(255),
  bio TEXT,
  profile_image_url VARCHAR(500),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(doctor_account_id)
);

-- ============================================================================
-- 4. APPOINTMENT TABLE (appointments and availability slots)
-- ============================================================================
-- Matches: lib/models/appointment_model.dart (AppointmentModel)
-- Also used for: lib/models/availability_model.dart (AvailabilityModel)
-- Note: When patient_id is NULL, it's an availability slot
--       When patient_id is NOT NULL, it's a booked appointment
CREATE TABLE IF NOT EXISTS appointment (
  id SERIAL PRIMARY KEY,
  patient_id INTEGER REFERENCES users(user_id) ON DELETE SET NULL, -- NULL = available slot
  patient_name VARCHAR(255), -- Denormalized for performance
  doctor_id INTEGER NOT NULL REFERENCES doctor_accounts(id) ON DELETE CASCADE,
  doctor_name VARCHAR(255) NOT NULL, -- Denormalized for performance
  date DATE NOT NULL, -- Appointment date (used as 'date' in queries, mapped to 'appointment_date' in model)
  time VARCHAR(10), -- Time slot (e.g., "09:00", "14:30")
  start_time TIME, -- Start time for availability slots
  end_time TIME, -- End time for availability slots
  type VARCHAR(20) NOT NULL DEFAULT 'video' CHECK (type IN ('video', 'voice')),
  status VARCHAR(20) NOT NULL DEFAULT 'booked' CHECK (status IN ('booked', 'completed', 'cancelled', 'rescheduled')),
  consultation_fee DECIMAL(10, 2) DEFAULT 0.00,
  payment_made BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for appointment table
CREATE INDEX IF NOT EXISTS idx_appointment_patient_id ON appointment(patient_id) WHERE patient_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_appointment_doctor_id ON appointment(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointment_date ON appointment(date);
CREATE INDEX IF NOT EXISTS idx_appointment_status ON appointment(status);
CREATE INDEX IF NOT EXISTS idx_appointment_available ON appointment(doctor_id, date) WHERE patient_id IS NULL;

-- ============================================================================
-- 5. EHR TABLE (Electronic Health Records)
-- ============================================================================
-- Matches: lib/models/ehr_model.dart (EhrModel)
CREATE TABLE IF NOT EXISTS ehr (
  record_id SERIAL PRIMARY KEY,
  patient_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  doctor_id INTEGER NOT NULL REFERENCES doctor_accounts(id) ON DELETE CASCADE,
  diagnosis TEXT NOT NULL,
  treatment TEXT NOT NULL, -- Maps to 'prescription' in model
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for ehr table
CREATE INDEX IF NOT EXISTS idx_ehr_patient_id ON ehr(patient_id);
CREATE INDEX IF NOT EXISTS idx_ehr_doctor_id ON ehr(doctor_id);
CREATE INDEX IF NOT EXISTS idx_ehr_created_at ON ehr(created_at DESC);

-- ============================================================================
-- 6. PRESCRIPTIONS TABLE
-- ============================================================================
-- Matches: lib/models/prescription_model.dart (PrescriptionModel & PrescriptionItem)
-- Note: Each medication is stored as a separate row, grouped by appointment_id
CREATE TABLE IF NOT EXISTS prescriptions (
  prescription_id SERIAL PRIMARY KEY,
  appointment_id INTEGER REFERENCES appointment(id) ON DELETE SET NULL,
  patient_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  doctor_id INTEGER NOT NULL REFERENCES doctor_accounts(id) ON DELETE CASCADE,
  diagnosis TEXT NOT NULL,
  medication_name VARCHAR(255) NOT NULL,
  dosage VARCHAR(100) NOT NULL,
  frequency VARCHAR(100) NOT NULL,
  duration VARCHAR(100) NOT NULL,
  instructions TEXT,
  notes TEXT, -- Additional prescription notes
  is_ordered BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for prescriptions table
CREATE INDEX IF NOT EXISTS idx_prescriptions_appointment_id ON prescriptions(appointment_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_patient_id ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_doctor_id ON prescriptions(doctor_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_created_at ON prescriptions(created_at DESC);

-- ============================================================================
-- 7. RATINGS_REVIEWS TABLE
-- ============================================================================
-- Matches: lib/models/rating_review_model.dart (RatingReviewModel)
CREATE TABLE IF NOT EXISTS ratings_reviews (
  id SERIAL PRIMARY KEY,
  doctor_id INTEGER NOT NULL REFERENCES doctor_accounts(id) ON DELETE CASCADE,
  patient_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  appointment_id INTEGER REFERENCES appointment(id) ON DELETE SET NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  is_anonymous BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT TRUE,
  is_approved BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL,
  
  -- Ensure a patient can't review themselves
  CONSTRAINT no_self_review CHECK (doctor_id != patient_id)
);

-- Indexes for ratings_reviews table
CREATE INDEX IF NOT EXISTS idx_ratings_reviews_doctor_id ON ratings_reviews(doctor_id) 
  WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_ratings_reviews_patient_id ON ratings_reviews(patient_id) 
  WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_ratings_reviews_appointment_id ON ratings_reviews(appointment_id) 
  WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_ratings_reviews_created_at ON ratings_reviews(created_at DESC) 
  WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_ratings_reviews_approved ON ratings_reviews(is_approved) 
  WHERE deleted_at IS NULL;

-- Partial unique index: Ensure a patient can only review a doctor once per appointment
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_appointment_review 
  ON ratings_reviews(appointment_id) 
  WHERE appointment_id IS NOT NULL AND deleted_at IS NULL;

-- ============================================================================
-- 8. MESSAGES TABLE
-- ============================================================================
-- Matches: lib/models/message_model.dart (MessageModel)
-- Note: Uses appointment_id as chat_id (no separate chats table)
CREATE TABLE IF NOT EXISTS messages (
  message_id SERIAL PRIMARY KEY,
  appointment_id INTEGER NOT NULL REFERENCES appointment(id) ON DELETE CASCADE,
  sender_id INTEGER NOT NULL, -- Can be user_id or doctor_accounts.id
  receiver_id INTEGER NOT NULL, -- Can be user_id or doctor_accounts.id
  message TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_read BOOLEAN DEFAULT FALSE,
  message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'prescription', 'image', 'file'))
);

-- Indexes for messages table
CREATE INDEX IF NOT EXISTS idx_messages_appointment_id ON messages(appointment_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_sent_at ON messages(sent_at DESC);

-- ============================================================================
-- 9. PAYMENTS TABLE
-- ============================================================================
-- Matches: lib/models/payment_model.dart (PaymentModel)
CREATE TABLE IF NOT EXISTS payments (
  payment_id SERIAL PRIMARY KEY,
  appointment_id INTEGER NOT NULL REFERENCES appointment(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL, -- Patient who made the payment (references users.user_id)
  doctor_id INTEGER NOT NULL REFERENCES doctor_accounts(id) ON DELETE CASCADE,
  amount DECIMAL(10, 2) NOT NULL,
  payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('mpesa', 'card')),
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
  transaction_id VARCHAR(255),
  phone_number VARCHAR(20), -- For M-Pesa payments
  paid_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for payments table
CREATE INDEX IF NOT EXISTS idx_payments_appointment_id ON payments(appointment_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_doctor_id ON payments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_transaction_id ON payments(transaction_id);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at DESC);

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_doctor_accounts_updated_at BEFORE UPDATE ON doctor_accounts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_doctors_updated_at BEFORE UPDATE ON doctors
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointment_updated_at BEFORE UPDATE ON appointment
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ehr_updated_at BEFORE UPDATE ON ehr
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prescriptions_updated_at BEFORE UPDATE ON prescriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ratings_reviews_updated_at BEFORE UPDATE ON ratings_reviews
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctor_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointment ENABLE ROW LEVEL SECURITY;
ALTER TABLE ehr ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- USERS TABLE POLICIES
-- ============================================================================

-- Users can read their own data
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid()::text = user_id::text OR auth.role() = 'service_role');

-- Users can update their own data
CREATE POLICY "Users can update own data" ON users
  FOR UPDATE USING (auth.uid()::text = user_id::text);

-- Anyone can insert (for sign-up)
CREATE POLICY "Anyone can insert users" ON users
  FOR INSERT WITH CHECK (true);

-- ============================================================================
-- DOCTOR_ACCOUNTS TABLE POLICIES
-- ============================================================================

-- Doctors can read their own data
CREATE POLICY "Doctors can read own data" ON doctor_accounts
  FOR SELECT USING (auth.uid()::text = id::text OR auth.role() = 'service_role');

-- Anyone can read doctor accounts (for patient booking)
CREATE POLICY "Anyone can read doctor accounts" ON doctor_accounts
  FOR SELECT USING (true);

-- Doctors can update their own data
CREATE POLICY "Doctors can update own data" ON doctor_accounts
  FOR UPDATE USING (auth.uid()::text = id::text OR auth.role() = 'service_role');

-- Only service role can insert doctors
CREATE POLICY "Service role can insert doctors" ON doctor_accounts
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

-- ============================================================================
-- DOCTORS TABLE POLICIES
-- ============================================================================

-- Anyone can read doctor details
CREATE POLICY "Anyone can read doctors" ON doctors
  FOR SELECT USING (true);

-- Doctors can update their own details
CREATE POLICY "Doctors can update own details" ON doctors
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM doctor_accounts 
      WHERE doctor_accounts.id = doctors.doctor_account_id 
      AND doctor_accounts.id::text = auth.uid()::text
    )
  );

-- ============================================================================
-- APPOINTMENT TABLE POLICIES
-- ============================================================================

-- Patients can read their own appointments
CREATE POLICY "Patients can read own appointments" ON appointment
  FOR SELECT USING (
    patient_id::text = auth.uid()::text 
    OR doctor_id::text = auth.uid()::text
    OR auth.role() = 'service_role'
  );

-- Doctors can read all appointments (their own and availability slots)
CREATE POLICY "Doctors can read all appointments" ON appointment
  FOR SELECT USING (
    doctor_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- Patients can insert appointments (book)
CREATE POLICY "Patients can book appointments" ON appointment
  FOR INSERT WITH CHECK (
    patient_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- Doctors can insert availability slots
CREATE POLICY "Doctors can add availability" ON appointment
  FOR INSERT WITH CHECK (
    (doctor_id::text = auth.uid()::text AND patient_id IS NULL)
    OR auth.role() = 'service_role'
  );

-- Patients can update their own appointments (cancel, reschedule)
CREATE POLICY "Patients can update own appointments" ON appointment
  FOR UPDATE USING (
    patient_id::text = auth.uid()::text 
    OR doctor_id::text = auth.uid()::text
    OR auth.role() = 'service_role'
  );

-- Doctors can delete availability slots (not booked appointments)
CREATE POLICY "Doctors can delete availability" ON appointment
  FOR DELETE USING (
    (doctor_id::text = auth.uid()::text AND patient_id IS NULL)
    OR auth.role() = 'service_role'
  );

-- ============================================================================
-- EHR TABLE POLICIES
-- ============================================================================

-- Patients can read their own EHR records
CREATE POLICY "Patients can read own EHR" ON ehr
  FOR SELECT USING (
    patient_id::text = auth.uid()::text 
    OR doctor_id::text = auth.uid()::text
    OR auth.role() = 'service_role'
  );

-- Doctors can insert EHR records for their patients
CREATE POLICY "Doctors can create EHR" ON ehr
  FOR INSERT WITH CHECK (
    doctor_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- Doctors can update EHR records they created
CREATE POLICY "Doctors can update own EHR" ON ehr
  FOR UPDATE USING (
    doctor_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- Doctors can delete EHR records they created
CREATE POLICY "Doctors can delete own EHR" ON ehr
  FOR DELETE USING (
    doctor_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- ============================================================================
-- PRESCRIPTIONS TABLE POLICIES
-- ============================================================================

-- Patients can read their own prescriptions
CREATE POLICY "Patients can read own prescriptions" ON prescriptions
  FOR SELECT USING (
    patient_id::text = auth.uid()::text 
    OR doctor_id::text = auth.uid()::text
    OR auth.role() = 'service_role'
  );

-- Doctors can create prescriptions for their patients
CREATE POLICY "Doctors can create prescriptions" ON prescriptions
  FOR INSERT WITH CHECK (
    doctor_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- Patients can update is_ordered status
CREATE POLICY "Patients can update prescription order status" ON prescriptions
  FOR UPDATE USING (
    patient_id::text = auth.uid()::text 
    OR doctor_id::text = auth.uid()::text
    OR auth.role() = 'service_role'
  );

-- ============================================================================
-- RATINGS_REVIEWS TABLE POLICIES
-- ============================================================================

-- Anyone can read approved reviews
CREATE POLICY "Anyone can read approved reviews" ON ratings_reviews
  FOR SELECT USING (
    (is_approved = true AND deleted_at IS NULL)
    OR patient_id::text = auth.uid()::text
    OR doctor_id::text = auth.uid()::text
    OR auth.role() = 'service_role'
  );

-- Patients can create reviews
CREATE POLICY "Patients can create reviews" ON ratings_reviews
  FOR INSERT WITH CHECK (
    patient_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- Patients can update their own reviews
CREATE POLICY "Patients can update own reviews" ON ratings_reviews
  FOR UPDATE USING (
    patient_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- Patients can soft-delete their own reviews
CREATE POLICY "Patients can delete own reviews" ON ratings_reviews
  FOR UPDATE USING (
    patient_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  ) WITH CHECK (
    patient_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- ============================================================================
-- MESSAGES TABLE POLICIES
-- ============================================================================

-- Users can read messages where they are sender or receiver
CREATE POLICY "Users can read own messages" ON messages
  FOR SELECT USING (
    sender_id::text = auth.uid()::text 
    OR receiver_id::text = auth.uid()::text
    OR auth.role() = 'service_role'
  );

-- Users can send messages
CREATE POLICY "Users can send messages" ON messages
  FOR INSERT WITH CHECK (
    sender_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- Users can update read status of messages they received
CREATE POLICY "Users can update message read status" ON messages
  FOR UPDATE USING (
    receiver_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- ============================================================================
-- PAYMENTS TABLE POLICIES
-- ============================================================================

-- Users can read their own payments
CREATE POLICY "Users can read own payments" ON payments
  FOR SELECT USING (
    user_id::text = auth.uid()::text 
    OR doctor_id::text = auth.uid()::text
    OR auth.role() = 'service_role'
  );

-- Users can create payments
CREATE POLICY "Users can create payments" ON payments
  FOR INSERT WITH CHECK (
    user_id::text = auth.uid()::text 
    OR auth.role() = 'service_role'
  );

-- Service role can update payment status
CREATE POLICY "Service role can update payments" ON payments
  FOR UPDATE USING (auth.role() = 'service_role');

-- ============================================================================
-- NOTES AND MAPPINGS
-- ============================================================================

-- IMPORTANT COLUMN NAME MAPPINGS:
-- 
-- 1. Appointment Model:
--    - Model field: appointment_date
--    - Database column: date
--    - Service maps: response['date'] -> 'appointment_date' in model
--
-- 2. EHR Model:
--    - Model field: prescription
--    - Database column: treatment
--    - Service maps: response['treatment'] -> 'prescription' in model
--
-- 3. Prescription Model:
--    - Medications stored as separate rows
--    - Grouped by appointment_id when fetching
--    - Each row = one PrescriptionItem
--
-- 4. Availability vs Appointment:
--    - Same table (appointment)
--    - patient_id IS NULL = availability slot
--    - patient_id IS NOT NULL = booked appointment
--
-- 5. Messages:
--    - Uses appointment_id as chat_id
--    - No separate chats table
--
-- 6. ID Types:
--    - All IDs are INTEGER (SERIAL) in database
--    - Converted to String in Flutter models
--    - Use int.tryParse() when querying

-- ============================================================================
-- SAMPLE DATA INSERTION
-- ============================================================================
-- Insert existing data and minimal sample data for testing
-- ============================================================================

-- Reset sequences to avoid ID conflicts
-- Set sequences to start after the highest existing ID
SELECT setval('doctor_accounts_id_seq', (SELECT COALESCE(MAX(id), 0) FROM doctor_accounts) + 1, false);
SELECT setval('users_user_id_seq', (SELECT COALESCE(MAX(user_id), 0) FROM users) + 1, false);

-- ============================================================================
-- 1. INSERT EXISTING DOCTOR ACCOUNTS
-- ============================================================================
INSERT INTO doctor_accounts (id, fullname, email, mobile, password, role, profile, created_at, updated_at)
VALUES
  (1, 'Dr. Hope Simiyu', 'hopesimiyu@dococlock.com', '0700000000', '$2y$10$vJxxIDC50o0P9Quj3L.d9eKYfWY2MddItObbtPGH94UnQD7U0aUxi', 'doctor', 'assets/logo.png', '2025-11-11 16:54:15+00', '2025-11-11 16:54:15+00'),
  (2, 'Dr. Bartholomew Mutiso', 'bartholomew.mutiso@dococlock.com', '0700000000', '$2y$10$WZH5pZJXlkfc829rS0vuSej7y4isCHefG1KOiy4KLiZfBuD0XYYaG', 'doctor', 'assets/profiles/profile_1763988648_8726.png', '2025-11-24 12:50:51.862017+00', '2025-11-24 12:50:51.862017+00'),
  (3, 'Dr Myles Baraka', 'myles.baraka@dococlock.com', '0700000000', '$2y$10$Q/zuddejnoIHdyTj04.3zeE.LUn2e2EoS4tnyTZ6sBqCeXJiLL.RG', 'doctor', 'assets/logo.png', '2025-11-24 12:52:49.595968+00', '2025-11-24 12:52:49.595968+00'),
  (4, 'Dr Halliet Kalimi', 'halliet.kalimi@dococlock.com', '0712345678', 'w^ru-na-p0tat03s', 'doctor', 'assets/logo.png', '2025-11-24 13:19:49.762775+00', '2025-11-24 13:19:49.762775+00')
ON CONFLICT (id) DO UPDATE SET
  fullname = EXCLUDED.fullname,
  email = EXCLUDED.email,
  mobile = EXCLUDED.mobile,
  password = EXCLUDED.password,
  profile = EXCLUDED.profile,
  updated_at = EXCLUDED.updated_at;

-- ============================================================================
-- 2. INSERT EXISTING USER (PATIENT)
-- ============================================================================
INSERT INTO users (user_id, full_name, email, phone_number, role, created_at)
VALUES
  (7, 'Ndanu Kyalo', 'traceyndanukyalo@gmail.com', '0701003355', 'patient', '2025-11-24 19:34:28.302+00')
ON CONFLICT (user_id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  email = EXCLUDED.email,
  phone_number = EXCLUDED.phone_number,
  role = EXCLUDED.role;

-- ============================================================================
-- 3. INSERT DOCTOR DETAILS (Additional doctor information)
-- ============================================================================
INSERT INTO doctors (doctor_account_id, specialization, bio, profile_image_url, created_at, updated_at)
VALUES
  (1, 'General Practitioner', 'Experienced general practitioner with over 10 years of practice.', NULL, NOW(), NOW()),
  (2, 'Cardiologist', 'Specialized in heart health and cardiovascular diseases.', 'assets/profiles/profile_1763988648_8726.png', NOW(), NOW()),
  (3, 'Pediatrician', 'Dedicated to children''s health and wellness.', NULL, NOW(), NOW()),
  (4, 'Dermatologist', 'Expert in skin care and dermatological conditions.', NULL, NOW(), NOW())
ON CONFLICT (doctor_account_id) DO UPDATE SET
  specialization = EXCLUDED.specialization,
  bio = EXCLUDED.bio,
  profile_image_url = EXCLUDED.profile_image_url,
  updated_at = EXCLUDED.updated_at;

-- ============================================================================
-- 4. INSERT APPOINTMENT SLOTS (Availability and Booked Appointments)
-- ============================================================================
-- First, insert availability slots (patient_id IS NULL)
INSERT INTO appointment (doctor_id, doctor_name, date, start_time, end_time, type, status, consultation_fee, payment_made, created_at, updated_at)
VALUES
  -- Dr. Hope Simiyu availability slots
  (1, 'Dr. Hope Simiyu', CURRENT_DATE + INTERVAL '1 day', '09:00:00', '10:00:00', 'video', 'booked', 2000.00, false, NOW(), NOW()),
  (1, 'Dr. Hope Simiyu', CURRENT_DATE + INTERVAL '1 day', '10:00:00', '11:00:00', 'video', 'booked', 2000.00, false, NOW(), NOW()),
  (1, 'Dr. Hope Simiyu', CURRENT_DATE + INTERVAL '2 days', '14:00:00', '15:00:00', 'voice', 'booked', 1500.00, false, NOW(), NOW()),
  -- Dr. Bartholomew Mutiso availability slots
  (2, 'Dr. Bartholomew Mutiso', CURRENT_DATE + INTERVAL '1 day', '11:00:00', '12:00:00', 'video', 'booked', 2500.00, false, NOW(), NOW()),
  (2, 'Dr. Bartholomew Mutiso', CURRENT_DATE + INTERVAL '3 days', '09:00:00', '10:00:00', 'video', 'booked', 2500.00, false, NOW(), NOW()),
  -- Dr Myles Baraka availability slots
  (3, 'Dr Myles Baraka', CURRENT_DATE + INTERVAL '2 days', '10:00:00', '11:00:00', 'video', 'booked', 1800.00, false, NOW(), NOW()),
  -- Dr Halliet Kalimi availability slots
  (4, 'Dr Halliet Kalimi', CURRENT_DATE + INTERVAL '1 day', '15:00:00', '16:00:00', 'voice', 'booked', 2200.00, false, NOW(), NOW());

-- Now update some slots to be booked appointments (set patient_id and patient_name)
-- Book first appointment with Dr. Hope Simiyu
UPDATE appointment 
SET 
  patient_id = 7,
  patient_name = 'Ndanu Kyalo',
  time = '09:00',
  status = 'booked'
WHERE id = (SELECT id FROM appointment WHERE doctor_id = 1 AND patient_id IS NULL ORDER BY id LIMIT 1);

-- Book appointment with Dr. Bartholomew Mutiso (paid)
UPDATE appointment 
SET 
  patient_id = 7,
  patient_name = 'Ndanu Kyalo',
  time = '11:00',
  status = 'booked',
  payment_made = true
WHERE id = (SELECT id FROM appointment WHERE doctor_id = 2 AND patient_id IS NULL ORDER BY id LIMIT 1);

-- ============================================================================
-- 5. INSERT EHR RECORDS
-- ============================================================================
INSERT INTO ehr (patient_id, doctor_id, diagnosis, treatment, notes, created_at, updated_at)
VALUES
  (7, 1, 'Common cold with mild fever', 'Paracetamol 500mg twice daily for 3 days. Rest and plenty of fluids.', 'Patient should follow up if symptoms persist beyond 5 days.', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
  (7, 2, 'Routine checkup - Normal', 'No medication required. Continue healthy lifestyle.', 'Blood pressure and heart rate within normal range.', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days');

-- ============================================================================
-- 6. INSERT PRESCRIPTIONS
-- ============================================================================
-- Get appointment IDs for prescriptions
DO $$
DECLARE
  appt_id_1 INTEGER;
  appt_id_2 INTEGER;
BEGIN
  -- Get first booked appointment
  SELECT id INTO appt_id_1 FROM appointment WHERE patient_id = 7 LIMIT 1;
  -- Get second booked appointment
  SELECT id INTO appt_id_2 FROM appointment WHERE patient_id = 7 ORDER BY id DESC LIMIT 1;
  
  -- Insert prescription items for first appointment
  IF appt_id_1 IS NOT NULL THEN
    INSERT INTO prescriptions (appointment_id, patient_id, doctor_id, diagnosis, medication_name, dosage, frequency, duration, instructions, notes, is_ordered, created_at, updated_at)
    VALUES
      (appt_id_1, 7, 1, 'Common cold with mild fever', 'Paracetamol', '500mg', 'Twice daily', '3 days', 'Take with food', 'Prescription for cold symptoms', false, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
      (appt_id_1, 7, 1, 'Common cold with mild fever', 'Vitamin C', '1000mg', 'Once daily', '7 days', 'Take in the morning', NULL, false, NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days');
  END IF;
  
  -- Insert prescription items for second appointment
  IF appt_id_2 IS NOT NULL THEN
    INSERT INTO prescriptions (appointment_id, patient_id, doctor_id, diagnosis, medication_name, dosage, frequency, duration, instructions, notes, is_ordered, created_at, updated_at)
    VALUES
      (appt_id_2, 7, 2, 'Routine checkup - Normal', 'Multivitamin', '1 tablet', 'Once daily', '30 days', 'Take with breakfast', 'General health supplement', true, NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days');
  END IF;
END $$;

-- ============================================================================
-- 7. INSERT RATINGS AND REVIEWS
-- ============================================================================
DO $$
DECLARE
  appt_id INTEGER;
BEGIN
  -- Get a completed appointment for review
  SELECT id INTO appt_id FROM appointment WHERE patient_id = 7 AND status = 'booked' LIMIT 1;
  
  IF appt_id IS NOT NULL THEN
    INSERT INTO ratings_reviews (doctor_id, patient_id, appointment_id, rating, review_text, is_anonymous, is_verified, is_approved, created_at, updated_at)
    VALUES
      (1, 7, appt_id, 5, 'Excellent doctor! Very professional and caring. Explained everything clearly.', false, true, true, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days');
  END IF;
END $$;

-- ============================================================================
-- 8. INSERT MESSAGES
-- ============================================================================
DO $$
DECLARE
  appt_id INTEGER;
BEGIN
  -- Get a booked appointment for messages
  SELECT id INTO appt_id FROM appointment WHERE patient_id = 7 LIMIT 1;
  
  IF appt_id IS NOT NULL THEN
    INSERT INTO messages (appointment_id, sender_id, receiver_id, message, sent_at, is_read, message_type)
    VALUES
      (appt_id, 7, 1, 'Hello Doctor, I have a question about my prescription.', NOW() - INTERVAL '2 days', true, 'text'),
      (appt_id, 1, 7, 'Hello! I''m here to help. What would you like to know?', NOW() - INTERVAL '2 days' + INTERVAL '5 minutes', true, 'text'),
      (appt_id, 7, 1, 'Can I take the medication with food?', NOW() - INTERVAL '2 days' + INTERVAL '10 minutes', true, 'text'),
      (appt_id, 1, 7, 'Yes, it''s recommended to take it with food to avoid stomach upset.', NOW() - INTERVAL '2 days' + INTERVAL '15 minutes', false, 'text');
  END IF;
END $$;

-- ============================================================================
-- 9. INSERT PAYMENTS
-- ============================================================================
DO $$
DECLARE
  appt_id_paid INTEGER;
  appt_id_unpaid INTEGER;
BEGIN
  -- Get paid appointment
  SELECT id INTO appt_id_paid FROM appointment WHERE patient_id = 7 AND payment_made = true LIMIT 1;
  -- Get unpaid appointment
  SELECT id INTO appt_id_unpaid FROM appointment WHERE patient_id = 7 AND payment_made = false LIMIT 1;
  
  -- Insert payment for paid appointment
  IF appt_id_paid IS NOT NULL THEN
    INSERT INTO payments (appointment_id, user_id, doctor_id, amount, payment_method, status, transaction_id, phone_number, paid_at, created_at, updated_at)
    VALUES
      (appt_id_paid, 7, 2, 2500.00, 'mpesa', 'completed', 'MPX123456789', '0701003355', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');
  END IF;
  
  -- Insert pending payment for unpaid appointment
  IF appt_id_unpaid IS NOT NULL THEN
    INSERT INTO payments (appointment_id, user_id, doctor_id, amount, payment_method, status, phone_number, created_at, updated_at)
    VALUES
      (appt_id_unpaid, 7, 1, 2000.00, 'mpesa', 'pending', '0701003355', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days');
  END IF;
END $$;

-- ============================================================================
-- RESET SEQUENCES AFTER DATA INSERTION
-- ============================================================================
-- Ensure sequences are set correctly for future auto-generated IDs
SELECT setval('doctor_accounts_id_seq', (SELECT COALESCE(MAX(id), 0) FROM doctor_accounts), true);
SELECT setval('users_user_id_seq', (SELECT COALESCE(MAX(user_id), 0) FROM users), true);
SELECT setval('appointment_id_seq', (SELECT COALESCE(MAX(id), 0) FROM appointment), true);
SELECT setval('ehr_record_id_seq', (SELECT COALESCE(MAX(record_id), 0) FROM ehr), true);
SELECT setval('prescriptions_prescription_id_seq', (SELECT COALESCE(MAX(prescription_id), 0) FROM prescriptions), true);
SELECT setval('ratings_reviews_id_seq', (SELECT COALESCE(MAX(id), 0) FROM ratings_reviews), true);
SELECT setval('messages_message_id_seq', (SELECT COALESCE(MAX(message_id), 0) FROM messages), true);
SELECT setval('payments_payment_id_seq', (SELECT COALESCE(MAX(payment_id), 0) FROM payments), true);

-- ============================================================================
-- END OF SAMPLE DATA
-- ============================================================================

