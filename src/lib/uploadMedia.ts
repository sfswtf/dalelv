import { supabase } from './supabase';

const BUCKET = 'media';

/**
 * Upload a file to Supabase Storage and return the public URL.
 * Uses folder structure: {folder}/{timestamp}-{sanitizedFilename}
 */
export async function uploadMedia(
  file: File,
  folder: string = 'uploads'
): Promise<string> {
  const ext = file.name.split('.').pop()?.toLowerCase() || 'jpg';
  const baseName = file.name.replace(/\.[^/.]+$/, '').replace(/[^a-zA-Z0-9-_]/g, '_').slice(0, 50);
  const path = `${folder}/${Date.now()}-${baseName}.${ext}`;

  const { error } = await supabase.storage.from(BUCKET).upload(path, file, {
    cacheControl: '3600',
    upsert: true,
  });

  if (error) throw error;

  const { data } = supabase.storage.from(BUCKET).getPublicUrl(path);
  return data.publicUrl;
}
