# Plan: LOVABLACK User Area, Subscription System, and Admin Dashboard

We will implement a complete authentication and authorization system using Lovable Cloud (Supabase), including a public homepage with a signup form, a dashboard for users (with extension download and trial timer), and a protected admin area.

## User Experience
- **Public Homepage**: Updated buttons to trigger a signup/login modal.
- **Signup Flow**: Collects name, email, password, and WhatsApp.
- **Dashboard (/dashboard)**:
  - If user has no plan/trial: Shows pricing options to purchase.
  - If user has an active plan: Shows the "Download Extension" button and a tutorial video.
  - If user is on trial: Shows a countdown timer for the 20-minute limit.
  - If trial/plan is expired: Locks the download button and shows purchase options.
- **Admin Area (/admin)**: Protected route for `mro@Gmail.com`. Allows viewing all registrations, trial statuses, and purchases.

## Technical Details
- **Authentication**: Using Supabase Auth with custom metadata (full_name, whatsapp).
- **Database Schema**:
  - `profiles`: Extends user data.
  - `subscriptions`: Tracks trial and paid plan status (expires_at, type).
  - `user_roles`: Manages access control (admin vs user).
- **State Management**: TanStack Query for fetching subscription and profile data.
- **Routing**: TanStack Router with `_authenticated` layout for the dashboard and admin gate.
- **Trial Logic**: A server function to initiate a 20-minute trial subscription upon first signup if requested.

## Implementation Steps
1. **Enable Lovable Cloud**: (Requires user credits, will fallback to local mock if needed, but primary path is Cloud).
2. **Database Migration**: Create tables for profiles, roles, and subscriptions.
3. **Auth Components**: Create `AuthModal` with login/signup tabs.
4. **User Dashboard**:
   - Implement `/dashboard` route.
   - Logic to check subscription status.
   - "Download" and "Tutorial" components.
   - Countdown timer hook for trials.
5. **Admin Dashboard**:
   - Implement `/admin` route.
   - Secure it via role check (or hardcoded admin email per request).
   - Data table to list all users and their status.
6. **Integration**: Connect homepage buttons to the new Auth flow.
