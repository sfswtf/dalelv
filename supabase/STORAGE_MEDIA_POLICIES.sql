-- Run this in Supabase SQL Editor to allow uploads to the "media" bucket.
-- Ensure the bucket exists: Dashboard → Storage → New bucket → name: media, Public: yes.

-- Drop existing policies if re-running
DROP POLICY IF EXISTS "Public read media" ON storage.objects;
DROP POLICY IF EXISTS "Anon upload media" ON storage.objects;
DROP POLICY IF EXISTS "Anon update media" ON storage.objects;
DROP POLICY IF EXISTS "Anon delete media" ON storage.objects;

-- Allow public read
CREATE POLICY "Public read media"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'media');

-- Allow anon upload (admin uses anon key)
CREATE POLICY "Anon upload media"
ON storage.objects FOR INSERT
TO anon
WITH CHECK (bucket_id = 'media');

-- Allow anon update/delete
CREATE POLICY "Anon update media"
ON storage.objects FOR UPDATE
TO anon
USING (bucket_id = 'media');

CREATE POLICY "Anon delete media"
ON storage.objects FOR DELETE
TO anon
USING (bucket_id = 'media');
