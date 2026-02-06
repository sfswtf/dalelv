-- If tables exist but data still doesn't save: run this in SQL Editor.
-- It adds policies so the anon key (used by your app) can insert/update/delete.

-- Artists
DROP POLICY IF EXISTS "Anon can manage artists for admin dashboard" ON artists;
CREATE POLICY "Anon can manage artists for admin dashboard" ON artists
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Events
DROP POLICY IF EXISTS "Anon can manage events for admin dashboard" ON events;
CREATE POLICY "Anon can manage events for admin dashboard" ON events
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Event artists
DROP POLICY IF EXISTS "Anon can manage event_artists for admin dashboard" ON event_artists;
CREATE POLICY "Anon can manage event_artists for admin dashboard" ON event_artists
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Contact messages (so contact form and admin can read/write)
DROP POLICY IF EXISTS "Anon can view and update contact messages for admin" ON contact_messages;
CREATE POLICY "Anon can view and update contact messages for admin" ON contact_messages
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Contact form needs anon to INSERT (if not already allowed)
DROP POLICY IF EXISTS "Anyone can submit contact messages" ON contact_messages;
CREATE POLICY "Anyone can submit contact messages" ON contact_messages
  FOR INSERT TO anon, authenticated WITH CHECK (true);
