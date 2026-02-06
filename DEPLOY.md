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

## 3. Data not reaching Supabase (tables stay empty)

If the site shows "success" but Supabase tables stay empty:

1. **You should see an error toast** when Supabase is not used: the app now shows "Lagret bare lokalt" / "Saved locally only" when it falls back to localStorage, so you know it didn’t reach Supabase.
2. **If you only ever see success** (no error), the **live site may be an old build** that doesn’t call Supabase:
   - Push your latest code to GitHub.
   - In Netlify: **Site configuration** → **Environment variables** → confirm `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` are set.
   - **Deploys** → **Trigger deploy** → **Deploy site** (so the new build includes env vars and latest code).
3. **If you see an error toast** (e.g. RLS or "Could not send"): run **`supabase/FIX_ANON_POLICIES_ONLY.sql`** in the Supabase SQL Editor so the anon key can write, then try again.

## 4. Quick checklist

- [ ] Supabase: Project URL and Anon key in Netlify env vars.
- [ ] New deploy triggered after adding env vars (and after pushing code that uses Supabase).
- [ ] Run `FIX_ANON_POLICIES_ONLY.sql` in Supabase if tables exist but inserts fail.
- [ ] Custom domain added under **Domain management**.
- [ ] DNS (Netlify or external) updated and propagated.
- [ ] (Optional) `VITE_SITE_URL` set to your custom domain and redeploy.
