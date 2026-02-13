import { useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { supabase } from '../../lib/supabase';
import { Plus, Pencil, Trash2, ExternalLink } from 'lucide-react';
import { useLanguageStore } from '../../stores/languageStore';

interface LinktreeItem {
  id: string;
  label: string;
  url: string;
  display_order: number;
  status: 'draft' | 'published';
  created_at?: string;
}

export function LinktreeManager() {
  const { t } = useLanguageStore();
  const [items, setItems] = useState<LinktreeItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingItem, setEditingItem] = useState<LinktreeItem | null>(null);
  const [formData, setFormData] = useState({ label: '', url: '', display_order: 0, status: 'published' as const });

  useEffect(() => {
    fetchItems();
  }, []);

  async function fetchItems() {
    try {
      const { data, error } = await supabase
        .from('linktree_links')
        .select('*')
        .order('display_order', { ascending: true })
        .order('label', { ascending: true });

      if (error) throw error;
      setItems(data || []);
    } catch (error) {
      console.error('Error fetching linktree:', error);
      setItems([]);
      toast.error('Kunne ikke hente lenker');
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!formData.label.trim() || !formData.url.trim()) {
      toast.error('Fyll ut label og URL');
      return;
    }

    const payload = {
      label: formData.label.trim(),
      url: formData.url.trim(),
      display_order: formData.display_order,
      status: formData.status,
      updated_at: new Date().toISOString(),
    };

    try {
      if (editingItem?.id) {
        const { error } = await supabase
          .from('linktree_links')
          .update(payload)
          .eq('id', editingItem.id);
        if (error) throw error;
        toast.success('Lenke oppdatert');
      } else {
        const { error } = await supabase.from('linktree_links').insert([payload]);
        if (error) throw error;
        toast.success('Lenke lagt til');
      }
      setEditingItem(null);
      setFormData({ label: '', url: '', display_order: items.length, status: 'published' });
      fetchItems();
    } catch (error: any) {
      toast.error(error?.message || 'Kunne ikke lagre');
    }
  }

  async function handleDelete(id: string) {
    if (!confirm('Slette denne lenken?')) return;
    try {
      const { error } = await supabase.from('linktree_links').delete().eq('id', id);
      if (error) throw error;
      toast.success('Lenke slettet');
      fetchItems();
    } catch (error: any) {
      toast.error(error?.message || 'Kunne ikke slette');
    }
  }

  function handleEdit(item: LinktreeItem) {
    setEditingItem(item);
    setFormData({
      label: item.label,
      url: item.url,
      display_order: item.display_order,
      status: item.status,
    });
  }

  function handleNew() {
    setEditingItem(null);
    setFormData({ label: '', url: '', display_order: items.length, status: 'published' });
  }

  if (loading) {
    return <div className="text-center py-12">{t('common.loading')}</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold">Linktree-lenker</h2>
        <div className="flex gap-2">
          <a
            href="/linktree"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1 px-3 py-2 text-sm bg-neutral-100 hover:bg-neutral-200 rounded-md"
          >
            <ExternalLink size={16} />
            Se siden
          </a>
          <button
            onClick={handleNew}
            className="inline-flex items-center gap-1 bg-[#FF4D00] text-white px-4 py-2 rounded-md hover:bg-[#e64400]"
          >
            <Plus size={18} />
            Ny lenke
          </button>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="bg-neutral-50 p-4 rounded-lg space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium mb-1">Label (tekst på knappen)</label>
            <input
              type="text"
              value={formData.label}
              onChange={(e) => setFormData({ ...formData, label: e.target.value })}
              placeholder="f.eks. Spotify, Instagram"
              className="w-full p-2 border rounded-md"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">URL</label>
            <input
              type="url"
              value={formData.url}
              onChange={(e) => setFormData({ ...formData, url: e.target.value })}
              placeholder="https://..."
              className="w-full p-2 border rounded-md"
              required
            />
          </div>
        </div>
        <div className="flex gap-4 items-center">
          <div>
            <label className="block text-sm font-medium mb-1">Rekkefølge</label>
            <input
              type="number"
              value={formData.display_order}
              onChange={(e) => setFormData({ ...formData, display_order: parseInt(e.target.value) || 0 })}
              className="w-20 p-2 border rounded-md"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Status</label>
            <select
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value as 'draft' | 'published' })}
              className="p-2 border rounded-md"
            >
              <option value="published">Publisert</option>
              <option value="draft">Utkast</option>
            </select>
          </div>
          <button type="submit" className="mt-6 px-4 py-2 bg-[#FF4D00] text-white rounded-md hover:bg-[#e64400]">
            {editingItem ? 'Oppdater' : 'Legg til'}
          </button>
          {editingItem && (
            <button type="button" onClick={handleNew} className="mt-6 px-4 py-2 border rounded-md">
              Avbryt
            </button>
          )}
        </div>
      </form>

      <div className="border rounded-lg overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-2 text-left text-sm font-medium text-gray-700">Label</th>
              <th className="px-4 py-2 text-left text-sm font-medium text-gray-700">URL</th>
              <th className="px-4 py-2 text-left text-sm font-medium text-gray-700">Rekkefølge</th>
              <th className="px-4 py-2 text-left text-sm font-medium text-gray-700">Status</th>
              <th className="px-4 py-2 text-right text-sm font-medium text-gray-700">Handlinger</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {items.map((item) => (
              <tr key={item.id}>
                <td className="px-4 py-3 font-medium">{item.label}</td>
                <td className="px-4 py-3 text-sm text-gray-600 truncate max-w-[200px]">{item.url}</td>
                <td className="px-4 py-3">{item.display_order}</td>
                <td className="px-4 py-3">
                  <span className={`text-xs px-2 py-1 rounded ${item.status === 'published' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-600'}`}>
                    {item.status}
                  </span>
                </td>
                <td className="px-4 py-3 text-right">
                  <button
                    onClick={() => handleEdit(item)}
                    className="p-1 text-gray-600 hover:text-[#FF4D00]"
                    title="Rediger"
                  >
                    <Pencil size={18} />
                  </button>
                  <button
                    onClick={() => handleDelete(item.id)}
                    className="p-1 text-gray-600 hover:text-red-600 ml-2"
                    title="Slett"
                  >
                    <Trash2 size={18} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {items.length === 0 && (
          <p className="text-center py-8 text-gray-500">Ingen lenker ennå. Legg til en lenke ovenfor.</p>
        )}
      </div>
    </div>
  );
}
