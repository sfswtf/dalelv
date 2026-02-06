-- Fix "infinite recursion in policy for relation profiles":
-- The "Admins can manage" policies read from profiles, and profiles RLS reads profiles again = recursion.
-- Remove those admin policies so anon can write without touching profiles. Your app uses anon only.

-- Artists: drop admin policy (references profiles), keep only anon
DROP POLICY IF EXISTS "Admins can manage artists" ON artists;
DROP POLICY IF EXISTS "Anon can manage artists for admin dashboard" ON artists;
CREATE POLICY "Anon can manage artists for admin dashboard" ON artists
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Events
DROP POLICY IF EXISTS "Admins can manage events" ON events;
DROP POLICY IF EXISTS "Anon can manage events for admin dashboard" ON events;
CREATE POLICY "Anon can manage events for admin dashboard" ON events
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Event artists
DROP POLICY IF EXISTS "Admins can manage event artists" ON event_artists;
DROP POLICY IF EXISTS "Anon can manage event_artists for admin dashboard" ON event_artists;
CREATE POLICY "Anon can manage event_artists for admin dashboard" ON event_artists
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Contact messages: drop admin policies (reference profiles), anon only
DROP POLICY IF EXISTS "Admins can view contact messages" ON contact_messages;
DROP POLICY IF EXISTS "Admins can update contact messages" ON contact_messages;
DROP POLICY IF EXISTS "Anon can view and update contact messages for admin" ON contact_messages;
DROP POLICY IF EXISTS "Anyone can submit contact messages" ON contact_messages;
CREATE POLICY "Anon full access contact_messages" ON contact_messages
  FOR ALL TO anon USING (true) WITH CHECK (true);
