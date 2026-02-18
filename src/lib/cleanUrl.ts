/**
 * Clean and normalize URL string for admin forms.
 * - Trims whitespace
 * - Returns null for empty strings
 * - Optionally ensures https:// prefix for URLs
 */
export function cleanUrl(url: string | null | undefined): string | null {
  if (url == null) return null;
  const trimmed = String(url).trim();
  if (trimmed === '') return null;
  return trimmed;
}

/**
 * Clean URL and ensure it has a protocol (https://) if it looks like a URL
 */
export function cleanUrlWithProtocol(url: string | null | undefined): string | null {
  const cleaned = cleanUrl(url);
  if (!cleaned) return null;
  if (/^https?:\/\//i.test(cleaned)) return cleaned;
  if (cleaned.includes('.') && !cleaned.startsWith('www.')) {
    return `https://${cleaned}`;
  }
  return cleaned;
}
