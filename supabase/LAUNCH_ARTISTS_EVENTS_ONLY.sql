-- =============================================================================
-- LAUNCH: Artists + Events + Contact only. Run ONCE in Supabase SQL Editor.
-- This creates the tables and allows the admin dashboard (anon key) to write.
-- =============================================================================

-- 1. Profiles (required for RLS; admin uses anon so we add anon policies below)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  is_admin BOOLEAN DEFAULT false,
  PRIMARY KEY (id)
);
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
CREATE POLICY "Users can view their own profile" ON profiles FOR SELECT USING (auth.uid() = id);
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
CREATE POLICY "Admins can view all profiles" ON profiles FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));

-- 2. Events
CREATE TABLE IF NOT EXISTS events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  event_date TIMESTAMP WITH TIME ZONE NOT NULL,
  location TEXT,
  image_url TEXT,
  status TEXT NOT NULL CHECK (status IN ('draft', 'published', 'cancelled')) DEFAULT 'draft',
  ticket_price INTEGER,
  tickets_url TEXT
);
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view published events" ON events;
CREATE POLICY "Anyone can view published events" ON events FOR SELECT USING (status = 'published');
DROP POLICY IF EXISTS "Admins can manage events" ON events;
CREATE POLICY "Admins can manage events" ON events FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
DROP POLICY IF EXISTS "Anon can manage events for admin dashboard" ON events;
CREATE POLICY "Anon can manage events for admin dashboard" ON events FOR ALL TO anon USING (true) WITH CHECK (true);

-- 3. Artists
CREATE TABLE IF NOT EXISTS artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  name TEXT NOT NULL,
  bio TEXT,
  image_url TEXT,
  spotify_url TEXT,
  spotify_embed_url TEXT,
  website_url TEXT,
  instagram_url TEXT,
  facebook_url TEXT,
  youtube_url TEXT,
  other_links JSONB DEFAULT '[]'::jsonb,
  status TEXT NOT NULL CHECK (status IN ('draft', 'published')) DEFAULT 'published',
  featured BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0
);
ALTER TABLE artists ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view published artists" ON artists;
CREATE POLICY "Anyone can view published artists" ON artists FOR SELECT USING (status = 'published');
DROP POLICY IF EXISTS "Admins can manage artists" ON artists;
CREATE POLICY "Admins can manage artists" ON artists FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
DROP POLICY IF EXISTS "Anon can manage artists for admin dashboard" ON artists;
CREATE POLICY "Anon can manage artists for admin dashboard" ON artists FOR ALL TO anon USING (true) WITH CHECK (true);


-- 4. Event artists (many-to-many) + extra event columns for admin form
ALTER TABLE events ADD COLUMN IF NOT EXISTS title_nb TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS title_en TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS description_nb TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS description_en TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS venue_name TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS venue_address TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS venue_city TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS venue_country TEXT DEFAULT 'Norway';
ALTER TABLE events ADD COLUMN IF NOT EXISTS tour_name TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS event_type TEXT CHECK (event_type IN ('tour', 'festival', 'concert', 'other')) DEFAULT 'concert';
ALTER TABLE events ADD COLUMN IF NOT EXISTS capacity INTEGER;
ALTER TABLE events ADD COLUMN IF NOT EXISTS doors_open TIMESTAMP WITH TIME ZONE;
ALTER TABLE events ADD COLUMN IF NOT EXISTS promoter TEXT;

CREATE TABLE IF NOT EXISTS event_artists (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
  is_headliner BOOLEAN DEFAULT false,
  performance_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(event_id, artist_id)
);
ALTER TABLE event_artists ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view event artists for published events" ON event_artists;
CREATE POLICY "Anyone can view event artists for published events" ON event_artists FOR SELECT
  USING (EXISTS (SELECT 1 FROM events WHERE events.id = event_artists.event_id AND events.status = 'published'));
DROP POLICY IF EXISTS "Admins can manage event artists" ON event_artists;
CREATE POLICY "Admins can manage event artists" ON event_artists FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
DROP POLICY IF EXISTS "Anon can manage event_artists for admin dashboard" ON event_artists;
CREATE POLICY "Anon can manage event_artists for admin dashboard" ON event_artists FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE INDEX IF NOT EXISTS idx_event_artists_event_id ON event_artists(event_id);
CREATE INDEX IF NOT EXISTS idx_event_artists_artist_id ON event_artists(artist_id);

-- 5. Contact messages
CREATE TABLE IF NOT EXISTS contact_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('unread', 'read', 'replied')) DEFAULT 'unread',
  admin_notes TEXT
);
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can submit contact messages" ON contact_messages;
CREATE POLICY "Anyone can submit contact messages" ON contact_messages FOR INSERT TO authenticated, anon WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can view contact messages" ON contact_messages;
CREATE POLICY "Admins can view contact messages" ON contact_messages FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
DROP POLICY IF EXISTS "Admins can update contact messages" ON contact_messages;
CREATE POLICY "Admins can update contact messages" ON contact_messages FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
DROP POLICY IF EXISTS "Anon can view and update contact messages for admin" ON contact_messages;
CREATE POLICY "Anon can view and update contact messages for admin" ON contact_messages FOR ALL TO anon USING (true) WITH CHECK (true);


CREATE INDEX IF NOT EXISTS idx_artists_status ON artists(status);
CREATE INDEX IF NOT EXISTS idx_artists_display_order ON artists(display_order);
