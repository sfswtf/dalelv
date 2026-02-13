import { useState, useRef } from 'react';
import { Upload, X } from 'lucide-react';
import { uploadMedia } from '../../lib/uploadMedia';
import { toast } from 'react-hot-toast';

interface ImageUploadMultiFieldProps {
  values: string[];
  onChange: (urls: string[]) => void;
  folder?: string;
  label?: string;
}

export function ImageUploadMultiField({
  values,
  onChange,
  folder = 'uploads',
  label = 'Bilder',
}: ImageUploadMultiFieldProps) {
  const [uploading, setUploading] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);
  const [urlInput, setUrlInput] = useState('');

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
      onChange([...values, url]);
      toast.success('Bilde lastet opp');
    } catch (err: any) {
      toast.error(err?.message || 'Kunne ikke laste opp');
    } finally {
      setUploading(false);
      e.target.value = '';
    }
  }

  function handleAddUrl() {
    const trimmed = urlInput.trim();
    if (trimmed && !values.includes(trimmed)) {
      onChange([...values, trimmed]);
      setUrlInput('');
    }
  }

  function handleRemove(index: number) {
    onChange(values.filter((_, i) => i !== index));
  }

  return (
    <div>
      <label className="block text-sm font-medium mb-1">{label}</label>
      <div className="flex gap-2 mb-2">
        <input
          type="url"
          value={urlInput}
          onChange={(e) => setUrlInput(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), handleAddUrl())}
          placeholder="https://... eller last opp"
          className="flex-1 p-2 border rounded-md focus:ring-2 focus:ring-primary-600"
        />
        <button
          type="button"
          onClick={handleAddUrl}
          className="px-4 py-2 bg-neutral-100 hover:bg-neutral-200 rounded-md border"
        >
          Legg til URL
        </button>
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
      {values.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {values.map((url, i) => (
            <div key={i} className="relative">
              <img
                src={url}
                alt=""
                className="w-20 h-20 object-cover rounded border"
                onError={(e) => (e.currentTarget.style.display = 'none')}
              />
              <button
                type="button"
                onClick={() => handleRemove(i)}
                className="absolute -top-1 -right-1 p-0.5 bg-red-500 text-white rounded-full hover:bg-red-600"
              >
                <X size={12} />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
