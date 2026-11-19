# Team AP – Business Tracker (free, standalone)

Files: index.html, config.js, logo.png, icons/, manifest.webmanifest, sw.js, supabase-setup.sql

## 1. Database (Supabase, free)
1. Sign up at supabase.com, create a project (note the database password).
2. SQL Editor > New query > paste all of `supabase-setup.sql` > Run.
3. Authentication > Users > Add user (email + password) for each person. Untick "auto confirm" off if asked; make sure they are confirmed.
4. Make yourself admin: run the `update profiles set role='admin', is_owner=true ...` line at the bottom of the SQL with your email.
5. Project Settings > API: copy the Project URL and the `anon public` key into `config.js`.
   (The anon key is meant to be public. Never put the `service_role` key in these files.)

## 2. Host on GitHub Pages (free)
1. New GitHub repo, upload every file/folder here (keep `icons/`).
2. Settings > Pages > Deploy from branch > `main` / root.
3. Open `https://YOUR-USER.github.io/YOUR-REPO/`.

## 3. Install on phones
Android Chrome: menu > Install app. iPhone Safari: Share > Add to Home Screen.

## 4. Set up roles (as admin)
Summary > Team: set each person's name and role.
- admin: everything
- partner: sees all entries, reports and EMI, adds entries
- operator: adds entries and sees only their own; no reports or EMI
Tick "Owner" for the 8 cousins who share the EMI. Then enter the EMI amount and date.

## Excel export
Summary > Download Excel: pick a From and To date and download a workbook with Entries, Daily and Monthly sheets.

## Security tip
In Supabase: Authentication > Sign In / Providers > turn OFF "Allow new users to sign up", so only people you add can log in.
