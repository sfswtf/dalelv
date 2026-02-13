import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { siteConfig } from '../config/siteConfig';
import { ExternalLink, ArrowLeft } from 'lucide-react';

interface LinktreeItem {
  id: string;
  label: string;
  url: string;
  display_order: number;
  status: string;
}

export function LinktreePage() {
  const [links, setLinks] = useState<LinktreeItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchLinks();
  }, []);

  async function fetchLinks() {
    try {
      const { data, error } = await supabase
        .from('linktree_links')
        .select('*')
        .eq('status', 'published')
        .order('display_order', { ascending: true })
        .order('label', { ascending: true });

      if (error) throw error;
      setLinks(data || []);
    } catch (error) {
      console.error('Error fetching linktree:', error);
      setLinks([]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-neutral-900 text-white">
      <div className="max-w-md mx-auto px-4 py-12">
        <Link
          to="/"
          className="inline-flex items-center gap-2 text-neutral-400 hover:text-white mb-8 transition-colors"
        >
          <ArrowLeft size={18} />
          Tilbake til forsiden
        </Link>

        <div className="text-center mb-10">
          <img
            src={siteConfig.logo.header || siteConfig.logo.primary}
            alt={siteConfig.name}
            className="h-20 w-auto mx-auto mb-4"
            style={{ filter: 'drop-shadow(0 0 8px rgba(0,0,0,0.5))' }}
          />
          <h1 className="text-xl font-medium text-neutral-300">{siteConfig.name}</h1>
        </div>

        {loading ? (
          <div className="space-y-3">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="h-14 bg-neutral-800 rounded-lg animate-pulse" />
            ))}
          </div>
        ) : links.length === 0 ? (
          <p className="text-center text-neutral-500 py-12">Ingen lenker ennå.</p>
        ) : (
          <div className="space-y-3">
            {links.map((item) => (
              <a
                key={item.id}
                href={item.url}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center justify-between w-full px-6 py-4 bg-neutral-800 hover:bg-[#FF4D00] rounded-lg text-white font-medium transition-colors group"
              >
                <span>{item.label}</span>
                <ExternalLink size={18} className="opacity-70 group-hover:opacity-100" />
              </a>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
