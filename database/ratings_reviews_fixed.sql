-- Ratings and Reviews Table
-- This table stores patient ratings and reviews for doctors
-- Updated to match actual database schema

CREATE TABLE IF NOT EXISTS ratings_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id INTEGER NOT NULL REFERENCES doctor_accounts(id) ON DELETE CASCADE,
  patient_id INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  appointment_id INTEGER REFERENCES appointment(id) ON DELETE SET NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  is_anonymous BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT TRUE, -- True if patient actually had an appointment
  is_approved BOOLEAN DEFAULT TRUE, -- For moderation (can be false initially)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE NULL,
  
  -- Ensure a patient can't review themselves (if doctor is also a patient)
  CONSTRAINT no_self_review CHECK (doctor_id != patient_id)
);

-- Indexes for better query performance
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

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_ratings_reviews_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at on row update
CREATE TRIGGER trigger_update_ratings_reviews_updated_at
  BEFORE UPDATE ON ratings_reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_ratings_reviews_updated_at();

-- View for doctor ratings summary
CREATE OR REPLACE VIEW doctor_ratings_summary AS
SELECT 
  doctor_id,
  COUNT(*) as total_reviews,
  AVG(rating) as average_rating,
  COUNT(CASE WHEN rating = 5 THEN 1 END) as five_star,
  COUNT(CASE WHEN rating = 4 THEN 1 END) as four_star,
  COUNT(CASE WHEN rating = 3 THEN 1 END) as three_star,
  COUNT(CASE WHEN rating = 2 THEN 1 END) as two_star,
  COUNT(CASE WHEN rating = 1 THEN 1 END) as one_star,
  MAX(created_at) as latest_review_date
FROM ratings_reviews
WHERE deleted_at IS NULL 
  AND is_approved = TRUE
GROUP BY doctor_id;

-- Enable Row Level Security (RLS)
ALTER TABLE ratings_reviews ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Patients can read approved reviews" ON ratings_reviews;
DROP POLICY IF EXISTS "Patients can create their own reviews" ON ratings_reviews;
DROP POLICY IF EXISTS "Patients can update their own reviews" ON ratings_reviews;
DROP POLICY IF EXISTS "Patients can delete their own reviews" ON ratings_reviews;
DROP POLICY IF EXISTS "Doctors can read their own reviews" ON ratings_reviews;

-- Policy: Patients can read all approved reviews
CREATE POLICY "Patients can read approved reviews"
  ON ratings_reviews FOR SELECT
  TO authenticated
  USING (
    deleted_at IS NULL 
    AND is_approved = TRUE
  );

-- Policy: Patients can create their own reviews
CREATE POLICY "Patients can create their own reviews"
  ON ratings_reviews FOR INSERT
  TO authenticated
  WITH CHECK (
    patient_id = (SELECT user_id FROM users WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid()))
  );

-- Policy: Patients can update their own reviews
CREATE POLICY "Patients can update their own reviews"
  ON ratings_reviews FOR UPDATE
  TO authenticated
  USING (
    patient_id = (SELECT user_id FROM users WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid()))
    AND deleted_at IS NULL
  )
  WITH CHECK (
    patient_id = (SELECT user_id FROM users WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid()))
  );

-- Policy: Patients can delete their own reviews (soft delete)
CREATE POLICY "Patients can delete their own reviews"
  ON ratings_reviews FOR UPDATE
  TO authenticated
  USING (
    patient_id = (SELECT user_id FROM users WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid()))
  );

-- Policy: Doctors can read reviews about themselves
CREATE POLICY "Doctors can read their own reviews"
  ON ratings_reviews FOR SELECT
  TO authenticated
  USING (
    deleted_at IS NULL
    AND (is_approved = TRUE OR doctor_id IN (SELECT id FROM doctor_accounts WHERE email = (SELECT email FROM auth.users WHERE id = auth.uid())))
  );

-- Comments for documentation
COMMENT ON TABLE ratings_reviews IS 'Stores patient ratings and reviews for doctors';
COMMENT ON COLUMN ratings_reviews.rating IS 'Rating from 1 to 5 stars';
COMMENT ON COLUMN ratings_reviews.is_anonymous IS 'Whether the review should be displayed anonymously';
COMMENT ON COLUMN ratings_reviews.is_verified IS 'Whether the patient had an actual appointment (verified review)';
COMMENT ON COLUMN ratings_reviews.is_approved IS 'Whether the review has been approved by moderators';

