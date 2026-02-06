# Supabase: create tables (one-time)

Your project **dalelvrecords** is connected from Netlify. Create tables and allow the admin dashboard to write using **one script** in the SQL Editor.

## For launch (artists + events + contact only)

1. **Open Supabase**  
   [supabase.com/dashboard](https://supabase.com/dashboard) → your project **dalelvrecords**.

2. **SQL Editor** → **New query**.

3. **Run the launch script**  
   - Open **`supabase/LAUNCH_ARTISTS_EVENTS_ONLY.sql`** in your repo.  
   - Copy **all** of it, paste into the SQL Editor, click **Run**.

   This creates **profiles**, **artists**, **events**, **event_artists**, **contact_messages** and adds policies so the admin dashboard (using the anon key) can create/update/delete. No second script needed.

4. **Check**  
   In the left sidebar go to **Table Editor**. You should see:
   - `profiles`
   - `artists`
   - `events`
   - `event_artists`
   - `contact_messages`

If the script runs without errors, the backend is ready: admin can add artists and events, contact form submissions go to Supabase, and the live site will show the data.

---

## Tables exist but data still doesn’t save

If you already ran **RUN_FIRST** (or an older script) and the Table Editor still stays empty when you add artists or send a contact message, RLS is probably blocking the **anon** key.

**Fix:** In SQL Editor, run **`supabase/FIX_ANON_POLICIES_ONLY.sql`** once. It only adds policies so the app (anon) can insert/update/delete. Then try saving an artist or sending a contact message again.

If it still fails, check the **toast error** in the app (e.g. “new row violates row-level security policy”) and that Netlify has **VITE_SUPABASE_URL** and **VITE_SUPABASE_ANON_KEY** set and you’ve redeployed after adding them.

---

## Optional: full set of tables

If you later want **membership**, **merch**, **orders**, **about_page**, **social_media_posts**, run **`supabase/RUN_FIRST_IN_SQL_EDITOR.sql`** and then **`supabase/ALLOW_ANON_MANAGEMENT_FOR_ADMIN.sql`**. Your site on Netlify will use these tables for events, artists, contact form, and (when you use them) merch and orders.

## Admin login

The app uses **local admin** (email/password from env vars), not Supabase Auth, for the admin dashboard. So you don’t need to create a user in Supabase for that. If you later switch to Supabase Auth for admin, you’d add a row in `profiles` with `is_admin = true` for that user’s `id`.

## Optional: add an event from the UI

After the tables exist, open your live site → **Tour/Events** (or the events page). You can add events in the **Admin** dashboard (e.g. `/admin` after logging in with your admin credentials).
