-- =============================================================================
-- DALELV RECORDS – Run this ONCE in Supabase SQL Editor to create all tables
-- Dashboard → SQL Editor → New query → paste this → Run
-- =============================================================================

-- 1. Profiles (needed for admin checks)
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

-- 3. Membership applications
CREATE TABLE IF NOT EXISTS membership_applications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  age_group TEXT NOT NULL DEFAULT 'other',
  music_genres TEXT[] NOT NULL DEFAULT '{}',
  motivation TEXT,
  status TEXT NOT NULL CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
  location TEXT NOT NULL DEFAULT '',
  member_type TEXT CHECK (member_type IN ('local', 'casual')) DEFAULT 'casual'
);
ALTER TABLE membership_applications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create membership applications" ON membership_applications;
CREATE POLICY "Users can create membership applications" ON membership_applications FOR INSERT TO authenticated, anon WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can view membership applications" ON membership_applications;
CREATE POLICY "Admins can view membership applications" ON membership_applications FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
DROP POLICY IF EXISTS "Admins can update membership applications" ON membership_applications;
CREATE POLICY "Admins can update membership applications" ON membership_applications FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));

-- 4. Contact messages
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
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true))
  WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));

-- 5. About page
CREATE TABLE IF NOT EXISTS about_page (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  content JSONB NOT NULL,
  version INTEGER NOT NULL DEFAULT 1
);
ALTER TABLE about_page ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view about page content" ON about_page;
CREATE POLICY "Anyone can view about page content" ON about_page FOR SELECT TO authenticated, anon USING (true);
DROP POLICY IF EXISTS "Admins can manage about page content" ON about_page;
CREATE POLICY "Admins can manage about page content" ON about_page FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));

-- 6. Social media posts
CREATE TABLE IF NOT EXISTS social_media_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('instagram', 'youtube', 'tiktok', 'image')),
  url TEXT NOT NULL,
  title TEXT NOT NULL,
  active BOOLEAN DEFAULT true,
  display_order INTEGER
);
ALTER TABLE social_media_posts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active social media posts" ON social_media_posts;
CREATE POLICY "Anyone can view active social media posts" ON social_media_posts FOR SELECT USING (active = true);
DROP POLICY IF EXISTS "Admins can manage social media posts" ON social_media_posts;
CREATE POLICY "Admins can manage social media posts" ON social_media_posts FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));

-- 7. Artists
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

-- 8. Merch
CREATE TABLE IF NOT EXISTS merch (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'NOK',
  image_urls TEXT[] DEFAULT '{}',
  category TEXT,
  sizes TEXT[],
  colors TEXT[],
  stock_quantity INTEGER,
  status TEXT NOT NULL CHECK (status IN ('draft', 'published', 'out_of_stock')) DEFAULT 'published',
  featured BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0
);
ALTER TABLE merch ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view published merch" ON merch;
CREATE POLICY "Anyone can view published merch" ON merch FOR SELECT USING (status = 'published');
DROP POLICY IF EXISTS "Admins can manage merch" ON merch;
CREATE POLICY "Admins can manage merch" ON merch FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));

-- 9. Orders
CREATE TABLE IF NOT EXISTS orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  customer_name TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  customer_phone TEXT,
  customer_address TEXT NOT NULL,
  customer_postal_code TEXT NOT NULL,
  customer_city TEXT NOT NULL,
  customer_country TEXT NOT NULL DEFAULT 'Norway',
  order_items JSONB NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'NOK',
  status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')) DEFAULT 'pending',
  shipping_method TEXT,
  tracking_number TEXT,
  notes TEXT,
  admin_notes TEXT
);
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can create orders" ON orders;
CREATE POLICY "Users can create orders" ON orders FOR INSERT TO authenticated, anon WITH CHECK (true);
DROP POLICY IF EXISTS "Admins can view all orders" ON orders;
CREATE POLICY "Admins can view all orders" ON orders FOR SELECT
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
DROP POLICY IF EXISTS "Admins can update orders" ON orders;
CREATE POLICY "Admins can update orders" ON orders FOR UPDATE
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));

-- 10. Add event columns (venue, tour, etc.)
ALTER TABLE events ADD COLUMN IF NOT EXISTS festival TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS venue_name TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS venue_address TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS venue_city TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS venue_country TEXT DEFAULT 'Norway';
ALTER TABLE events ADD COLUMN IF NOT EXISTS tour_name TEXT;
ALTER TABLE events ADD COLUMN IF NOT EXISTS event_type TEXT CHECK (event_type IN ('tour', 'festival', 'concert', 'other')) DEFAULT 'concert';
ALTER TABLE events ADD COLUMN IF NOT EXISTS capacity INTEGER;
ALTER TABLE events ADD COLUMN IF NOT EXISTS doors_open TIMESTAMP WITH TIME ZONE;
ALTER TABLE events ADD COLUMN IF NOT EXISTS promoter TEXT;

-- 11. Event–artist junction (many-to-many)
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
CREATE INDEX IF NOT EXISTS idx_event_artists_event_id ON event_artists(event_id);
CREATE INDEX IF NOT EXISTS idx_event_artists_artist_id ON event_artists(artist_id);

CREATE INDEX IF NOT EXISTS idx_artists_status ON artists(status);
CREATE INDEX IF NOT EXISTS idx_artists_display_order ON artists(display_order);
CREATE INDEX IF NOT EXISTS idx_merch_status ON merch(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
