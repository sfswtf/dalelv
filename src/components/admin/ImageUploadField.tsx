import { useState, useRef } from 'react';
import { Upload, X } from 'lucide-react';
import { uploadMedia } from '../../lib/uploadMedia';
import { toast } from 'react-hot-toast';

interface ImageUploadFieldProps {
  value: string;
  onChange: (url: string) => void;
  folder?: string;
  label?: string;
  placeholder?: string;
}

export function ImageUploadField({
  value,
  onChange,
  folder = 'uploads',
  label = 'Bilde',
  placeholder = 'https://... eller last opp',
}: ImageUploadFieldProps) {
  const [uploading, setUploading] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  async function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      toast.error('Velg et bilde (JPEG, PNG, GIF, WebP)');
      return;
    }
    setUploading(true);
    try {
      const url = await uploadMedia(file, folder);
      onChange(url);
      toast.success('Bilde lastet opp');
    } catch (err: any) {
      toast.error(err?.message || 'Kunne ikke laste opp');
    } finally {
      setUploading(false);
      e.target.value = '';
    }
  }

  return (
    <div>
      <label className="block text-sm font-medium mb-1">{label}</label>
      <div className="flex gap-2">
        <input
          type="url"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="flex-1 p-2 border rounded-md focus:ring-2 focus:ring-primary-600"
          placeholder={placeholder}
        />
        <input
          ref={inputRef}
          type="file"
          accept="image/jpeg,image/png,image/gif,image/webp"
          onChange={handleFileChange}
          className="hidden"
        />
        <button
          type="button"
          onClick={() => inputRef.current?.click()}
          disabled={uploading}
          className="px-4 py-2 bg-neutral-100 hover:bg-neutral-200 rounded-md border flex items-center gap-2 disabled:opacity-50"
          title="Last opp fra PC"
        >
          <Upload size={18} />
          {uploading ? 'Laster...' : 'Last opp'}
        </button>
      </div>
      {value && (
        <div className="mt-2 relative inline-block">
          <img
            src={value}
            alt="Preview"
            className="w-40 h-40 object-cover rounded-lg border"
            onError={(e) => (e.currentTarget.style.display = 'none')}
          />
          <button
            type="button"
            onClick={() => onChange('')}
            className="absolute -top-1 -right-1 p-1 bg-red-500 text-white rounded-full hover:bg-red-600"
            title="Fjern bilde"
          >
            <X size={14} />
          </button>
        </div>
      )}
    </div>
  );
}
