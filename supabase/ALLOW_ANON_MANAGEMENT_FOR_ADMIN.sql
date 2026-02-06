-- Run this AFTER RUN_FIRST_IN_SQL_EDITOR.sql
-- Your admin dashboard uses local login (not Supabase Auth), so requests use the anon key.
-- These policies allow anon to insert/update/delete so admin content reaches the live site.
-- For stronger security later, switch admin to Supabase Auth and remove these anon policies.

-- Artists: anon can manage (admin dashboard writes here)
DROP POLICY IF EXISTS "Admins can manage artists" ON artists;
CREATE POLICY "Admins can manage artists" ON artists FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
CREATE POLICY "Anon can manage artists for admin dashboard" ON artists
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Events: anon can manage
DROP POLICY IF EXISTS "Admins can manage events" ON events;
CREATE POLICY "Admins can manage events" ON events FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
CREATE POLICY "Anon can manage events for admin dashboard" ON events
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Event artists: anon can manage
DROP POLICY IF EXISTS "Admins can manage event artists" ON event_artists;
CREATE POLICY "Admins can manage event artists" ON event_artists FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
CREATE POLICY "Anon can manage event_artists for admin dashboard" ON event_artists
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Merch: anon can manage
DROP POLICY IF EXISTS "Admins can manage merch" ON merch;
CREATE POLICY "Admins can manage merch" ON merch FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
CREATE POLICY "Anon can manage merch for admin dashboard" ON merch
  FOR ALL TO anon USING (true) WITH CHECK (true);

-- Orders: anon can insert (checkout), authenticated admins can select/update (keep existing)
-- So we only need anon to insert; admins need to read/update. Current policy "Admins can view/update" uses auth.uid().
-- "Users can create orders" already allows anon INSERT. So orders are fine.

-- Contact messages: anon can already insert. Allow anon to SELECT and UPDATE so admin dashboard can view/reply.
DROP POLICY IF EXISTS "Admins can view contact messages" ON contact_messages;
DROP POLICY IF EXISTS "Admins can update contact messages" ON contact_messages;
CREATE POLICY "Admins can view contact messages" ON contact_messages FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
CREATE POLICY "Admins can update contact messages" ON contact_messages FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true));
CREATE POLICY "Anon can view and update contact messages for admin" ON contact_messages
  FOR ALL TO anon USING (true) WITH CHECK (true);
