# Add these to Netlify → Environment variables

You’re in the right place. Add **two** variables (click “Add a variable” / “Create variable” for each).

---

## Variable 1 – Project URL

**Key** (copy exactly):

```
VITE_SUPABASE_URL
```

**Value** (copy exactly):

```
https://btvvfwmwbyyypazcmkft.supabase.co
```

- Optional: check **“Contains secret values”** if you want it hidden in the UI.
- Click **Create variable**.

---

## Variable 2 – Anon key

**Key** (copy exactly):

```
VITE_SUPABASE_ANON_KEY
```

**Value** (copy exactly):

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0dnZmd213Ynl5eXBhemNta2Z0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAzMTYwODEsImV4cCI6MjA4NTg5MjA4MX0.fpzzB2Mk7zDw-fJO_FbHllkfFbHW2wv2n8w-xRt435w
```

- Optional: check **“Contains secret values”**.
- Click **Create variable**.

---

## After adding both

- Leave **Scopes** as “All scopes” (or default).
- Leave **Values** as “Same value for all deploy contexts”.
- Go to **Deploys** → **Trigger deploy** → **Deploy site** so the new variables are used.

Done. Your site will then talk to your Supabase project.
