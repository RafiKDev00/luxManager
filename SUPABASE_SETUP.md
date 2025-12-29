# LuxHome Supabase Backend Setup Guide

This guide will help you set up the Supabase backend for LuxHome.

## Step 1: Create Supabase Account & Project

1. Go to [https://supabase.com](https://supabase.com)
2. Click "Start your project" and sign up (GitHub login recommended)
3. Click "New Project"
4. Fill in:
   - **Organization**: Create new or select existing
   - **Name**: `luxhome` (or any name you prefer)
   - **Database Password**: Choose a strong password (SAVE THIS!)
   - **Region**: Select closest to your location
   - **Pricing Plan**: Free (perfect for personal use)
5. Click "Create new project" (takes ~2 minutes to set up)

## Step 2: Create Database Schema

1. In your Supabase project dashboard, click **SQL Editor** in the left sidebar
2. Click **New Query**
3. Open the file `/Users/rjkigner/projects/LuxHome/supabase-schema.sql`
4. Copy the ENTIRE contents and paste into the SQL Editor
5. Click **Run** (green play button)
6. You should see "Success. No rows returned" - this is good!

## Step 3: Set Up Photo Storage

1. In Supabase dashboard, click **Storage** in left sidebar
2. Click **New bucket**
3. Name: `photos`
4. **Public bucket**: Toggle ON (so photos are publicly accessible)
5. Click **Create bucket**

## Step 4: Get Your API Credentials

1. In Supabase dashboard, click **Settings** (gear icon) in left sidebar
2. Click **API** under Project Settings
3. You'll see two important values:

   **Project URL**:
   ```
   https://xxxxxxxxxxxxx.supabase.co
   ```

   **Anon/Public Key** (under "Project API keys"):
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS...
   ```

4. **COPY BOTH OF THESE!**

## Step 5: Add Credentials to Your App

1. Open `/Users/rjkigner/projects/LuxHome/LuxHome/Services/SupabaseService.swift`
2. Find lines 15-16:
   ```swift
   private let baseURL = "YOUR_SUPABASE_PROJECT_URL"
   private let apiKey = "YOUR_SUPABASE_ANON_KEY"
   ```
3. Replace with YOUR credentials:
   ```swift
   private let baseURL = "https://xxxxxxxxxxxxx.supabase.co"
   private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   ```
4. Save the file

## Step 6: Add Files to Xcode

The new files need to be added to your Xcode project:

1. Open LuxHome.xcodeproj in Xcode
2. In Project Navigator (left sidebar), right-click on "LuxHome" folder
3. Select "Add Files to LuxHome"
4. Navigate to and select:
   - `LuxHome/Services/SupabaseService.swift`
   - `LuxHome/Models/SupabaseModels.swift`
5. Make sure "Copy items if needed" is checked
6. Click "Add"

## Step 7: Test the Connection

You can test if everything is working by adding this to your LuxHomeModel init:

```swift
// In LuxHomeModel init, add:
Task {
    do {
        // Test fetch - should return empty array on first run
        let tasks: [DBTask] = try await SupabaseService.shared.get(endpoint: "/tasks")
        print("✅ Supabase connection successful! Found \(tasks.count) tasks")
    } catch {
        print("❌ Supabase connection failed: \(error)")
    }
}
```

Build and run your app. Check the Xcode console for the success/failure message.

## Next Steps

Once setup is complete, you can:

1. **Migrate to using Supabase**: Replace the local `loadSampleData()` with real API calls
2. **Upload photos**: Photos will be stored in Supabase Storage instead of local URLs
3. **Sync across devices**: All data will be in the cloud

## Cost Breakdown (Free Tier)

- **Database**: 500MB (way more than you need)
- **Storage**: 1GB for photos (~1000-2000 photos)
- **Bandwidth**: 2GB/month
- **API requests**: Unlimited

For a personal home management app, you'll never hit these limits!

## Troubleshooting

### "Invalid API key" error
- Make sure you copied the **anon/public** key, not the service_role key
- Make sure there are no extra spaces before/after the key

### "Bucket not found" error
- Make sure you named the storage bucket exactly `photos`
- Make sure you toggled "Public bucket" ON

### "Relation does not exist" error
- Make sure you ran the ENTIRE schema SQL file
- Check the SQL Editor for any error messages when running the schema

### Can't see data in Supabase
- Go to **Table Editor** in Supabase dashboard
- You should see all your tables listed on the left
- Click any table to view/edit data directly

## Security Note

The current setup uses the anon/public key with RLS policies that allow full access. This is fine for a personal app, but if you ever want to add authentication or share with others, you'll need to update the RLS policies in Supabase.

## Need Help?

If you run into issues:
1. Check the Xcode console for error messages
2. Check the Supabase dashboard → Logs for API errors
3. Try running a simple test query in Supabase SQL Editor:
   ```sql
   SELECT * FROM tasks;
   ```
