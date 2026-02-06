# Supabase: create tables (one-time)

Your project **dalelvrecords** is connected from Netlify, but the database has **no tables yet**. Create them once using the SQL Editor.

## Steps

1. **Open Supabase**  
   Go to [supabase.com/dashboard](https://supabase.com/dashboard) → your project **dalelvrecords**.

2. **Open SQL Editor**  
   In the left sidebar click **SQL Editor**.

3. **New query**  
   Click **New query**.

4. **Paste and run the script**  
   - Open the file **`supabase/RUN_FIRST_IN_SQL_EDITOR.sql`** in your repo.  
   - Copy **all** of its contents.  
   - Paste into the Supabase SQL Editor.  
   - Click **Run** (or press Ctrl+Enter / Cmd+Enter).

5. **Check**  
   In the left sidebar go to **Table Editor**. You should see tables such as:
   - `profiles`
   - `events`
   - `artists`
   - `contact_messages`
   - `membership_applications`
   - `merch`
   - `orders`
   - `event_artists`
   - `about_page`
   - `social_media_posts`

If the script runs without errors, the backend is ready. Your site on Netlify will use these tables for events, artists, contact form, and (when you use them) merch and orders.

## Admin login

The app uses **local admin** (email/password from env vars), not Supabase Auth, for the admin dashboard. So you don’t need to create a user in Supabase for that. If you later switch to Supabase Auth for admin, you’d add a row in `profiles` with `is_admin = true` for that user’s `id`.

## Optional: add an event from the UI

After the tables exist, open your live site → **Tour/Events** (or the events page). You can add events in the **Admin** dashboard (e.g. `/admin` after logging in with your admin credentials).
