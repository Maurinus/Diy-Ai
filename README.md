# DIY AI

DIY AI is a premium SwiftUI app that diagnoses broken items from photos, generates a structured repair plan, and helps users find tools and parts locally or online.

## Requirements
- Xcode 15+ (iOS 17 deployment target)
- Supabase project (Auth, DB, Storage, Edge Functions)
- Optional AI key for production analysis (mock mode works without it)

## Run the iOS app
1. Open `DIYAI.xcodeproj` in Xcode.
2. Copy config:
   - `cp Config.example.plist DIYAI/Resources/Config.plist`
3. Edit `DIYAI/Resources/Config.plist` and set:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
4. Build/run on a simulator or device.

If `Config.plist` is missing, the app runs in Demo Mode with local mock data.

## Supabase setup
### Apply migrations
From your Supabase project root:
```
supabase db push
```
This will apply the SQL in `supabase/migrations/` and create tables, RLS policies, and the `repairs` storage bucket.

### Deploy Edge Function
```
supabase functions deploy analyze-photo
```

### Set Edge Function secrets
```
supabase secrets set AI_API_KEY=your_key
supabase secrets set AI_MODEL=gpt-4o-mini
# Optional: override endpoint
supabase secrets set AI_API_URL=https://api.openai.com/v1/chat/completions
```
If `AI_API_KEY` is not set, the Edge Function automatically returns built-in mock fixtures.

## Auth redirect configuration
In Supabase Auth settings, add this redirect URL:

```
diyai://login-callback
```
Enable Anonymous sign-in in Supabase Auth if you want the "Skip for now" button to create an anonymous session.

## How Mock Mode works
- If `AI_API_KEY` is missing in the Edge Function environment, analysis responses are generated from built-in fixtures.
- If the app has no `Config.plist`, it runs in Demo Mode and uses local mock fixtures without calling Supabase.
- Set `MOCK_AI_MODE` to `true` in `Config.plist` to force local mock analysis even when Supabase is configured.

## Adding StoreKit 2 (future)
The app is structured so you can add StoreKit 2 and sync `profiles.is_pro` from your purchase server. Update `EntitlementManager` to read Pro status from your receipt and write it to the `profiles` table.

## Regenerating the Xcode project
If you edit `project.yml`, regenerate the project with:
```
xcodegen generate
```

## Project structure
```
DIYAI/
  App/
  Models/
  Services/
  Storage/
  ViewModels/
  Views/
  Components/
  Resources/Fixtures/

supabase/
  migrations/
  functions/analyze-photo/
```

## Run the App Locally (Final Steps)
1. Open the project file: `DIYAI.xcodeproj`.
2. In Xcode, pick a simulator device from the top toolbar (e.g., iPhone 15).
3. Press ▶ Run.
4. If Xcode asks about signing:
   - Go to the project target → Signing & Capabilities.
   - Check “Automatically manage signing”.
   - Select your Apple ID Team.
5. Demo Mode:
   - If `DIYAI/Resources/Config.plist` is missing, the app runs in Demo Mode using local mock data.
6. Supabase Mode:
   - Copy `Config.example.plist` to `DIYAI/Resources/Config.plist`.
   - Set `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
   - Rebuild and run. The app will use Supabase + Edge Functions.
