import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import sitemap from 'vite-plugin-sitemap';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    sitemap({
      hostname: process.env.VITE_SITE_URL || 'https://example.com',
      dynamicRoutes: [
        '/portfolio',
        '/blog',
        '/courses',
        '/resources',
        '/community',
        '/services',
        '/contact',
        '/onboarding',
        // Add more routes as needed
      ],
      readable: true, // Makes sitemap more readable
    }),
  ],
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
});
