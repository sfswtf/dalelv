-- Linktree-style links (custom link-in-bio page)
CREATE TABLE IF NOT EXISTS linktree_links (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  label TEXT NOT NULL,
  url TEXT NOT NULL,
  display_order INTEGER DEFAULT 0,
  status TEXT NOT NULL CHECK (status IN ('draft', 'published')) DEFAULT 'published'
);

ALTER TABLE linktree_links ENABLE ROW LEVEL SECURITY;

-- Anon full access (admin uses anon key; public reads published)
CREATE POLICY "Anon full access linktree_links" ON linktree_links
  FOR ALL TO anon USING (true) WITH CHECK (true);
