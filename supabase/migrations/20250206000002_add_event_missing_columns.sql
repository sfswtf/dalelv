-- Add missing columns to events table (run in Supabase SQL Editor if you get "production_notes column not found")
ALTER TABLE events ADD COLUMN IF NOT EXISTS production_notes TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS support_acts TEXT[];
