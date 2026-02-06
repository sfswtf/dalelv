# Deploy: Supabase + Netlify + Custom Domain

## 1. Supabase backend (Netlify env vars)

The app expects these at **build time** (Vite inlines them):

| Variable | Where to get it | Example |
|----------|-----------------|--------|
| `VITE_SUPABASE_URL` | Supabase → Project Settings → API → Project URL | `https://btvvfwmwbyyypazcmkft.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | Supabase → Project Settings → API → anon (public) key | `eyJhbG...` (long JWT) |

**In Netlify:**

1. Open your site → **Site configuration** (or **Site settings**) → **Environment variables**.
2. Click **Add a variable** → **Add a single variable** (or **Add from .env**).
3. Add:
   - **Key:** `VITE_SUPABASE_URL`  
     **Value:** your Project URL (e.g. `https://btvvfwmwbyyypazcmkft.supabase.co`).
4. Add:
   - **Key:** `VITE_SUPABASE_ANON_KEY`  
     **Value:** your **Anon** (public) key from the API Keys tab (not the secret key).
5. **Scopes:** leave as “All” or select “Production” (and “Deploy Previews” if you use them).
6. Save. Then trigger a new deploy: **Deploys** → **Trigger deploy** → **Deploy site** so the new env vars are used.

**Supabase:** Use the same project (e.g. **dalelvrecords**) and run your migrations in the SQL Editor if you haven’t already (tables for events, artists, contact_messages, etc.).

---

## 2. Custom domain on Netlify

1. In Netlify: your project → **Domain management** (in the left sidebar).
2. Click **Add domain** or **Add custom domain**.
3. Enter your domain (e.g. `dalelvrecords.com` or `www.dalelvrecords.com`).
4. Follow the instructions:
   - **Netlify DNS:** Add the domain to Netlify and use the nameservers they give you at your registrar.
   - **External DNS:** Add the A/CNAME records Netlify shows (e.g. `A` to Netlify’s load balancer, or `CNAME` for subdomains).
5. Wait for DNS to propagate (minutes to 48 hours). Netlify will issue HTTPS automatically.
6. (Optional) In **Domain management**, set the **Primary domain** to your custom domain so that’s the default URL.

**After the domain is active:** In Netlify **Environment variables**, add (optional but recommended):

- **Key:** `VITE_SITE_URL`  
  **Value:** `https://yourdomain.com` (your actual custom domain)

Then trigger a new deploy so the site uses the correct URL in links and metadata.

---

## 3. Quick checklist

- [ ] Supabase: Project URL and Anon key in Netlify env vars.
- [ ] New deploy triggered after adding env vars.
- [ ] Custom domain added under **Domain management**.
- [ ] DNS (Netlify or external) updated and propagated.
- [ ] (Optional) `VITE_SITE_URL` set to your custom domain and redeploy.
