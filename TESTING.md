# Manual QA Checklist (Non‑Developer)

This checklist validates the DIY AI app end‑to‑end. Follow each step and mark Pass/Fail.

## 1) Onboarding
- Fresh install: Launch app and confirm the 3‑screen onboarding carousel shows.
- Swipe through slides and confirm the “Next/Continue” button advances and finishes.
- Confirm you land on Auth or Home after onboarding.
- Settings: tap “Reset onboarding”, close app, relaunch, and confirm onboarding shows again.

## 2) Auth Flow
- Open app after onboarding.
- Enter an email and tap “Send magic link”. Confirm success message appears.
- Tap “Skip for now” and confirm you can reach the Home screen.
- If Supabase is configured, confirm magic link completes login when you open the link on the device.

## 3) New Fix – Camera + Library
- Tap “Start Fix”.
- Camera: tap “Take Photo” (on device). Capture a photo and confirm it appears in the preview.
- Library: tap “Choose from Library”, select a photo, and confirm it appears.
- Confirm “Analyze” is disabled before a photo is selected.

## 4) Analysis in Demo Mode (NO Config.plist)
- Ensure `DIYAI/Resources/Config.plist` does NOT exist.
- Run the app, confirm it states Demo mode in Home.
- Start a new fix, run Analyze, and confirm the analysis completes using mock data.

## 5) Analysis in Supabase Mode (Config.plist present)
- Copy `Config.example.plist` to `DIYAI/Resources/Config.plist`.
- Fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
- Run the app, sign in (or anonymous).
- Start a new fix and confirm analysis completes via the Edge Function.

## 6) Results Tabs + Locks (Free vs Pro)
- Results tabs should include Overview, Tools, Parts, Steps, Safety.
- Free: Steps tab shows preview only with lock overlay.
- Free: Confidence sections show lock overlay.
- Settings: enable “Pro Mode (Debug)”.
- Pro: Steps show full list and checkboxes; Confidence sections unlock.

## 7) Compare Prices (Find Items)
- From Tools or Parts, tap “Compare prices”.
- Confirm item header shows name, category, and variant (if any).
- Location mode: choose “Use my location”, allow permission, and confirm distances show.
- Postcode mode: choose “Enter postcode/suburb”, enter a value, and confirm results show with “Near {postcode}”.
- Sorting: test Cheapest / Nearest / In stock.
- Best value and Closest highlight labels should appear.

## 8) Online Ordering Links
- In “Order online”, tap “Order online” and confirm it opens in the browser.
- Confirm the link opens without errors (affiliate tracking will be added later).

## 9) My Fixes
- After an analysis completes, go to “My Fixes” and confirm it appears.
- Tap the fix to open results.
- Swipe to delete and confirm it disappears.
- Offline: disable network and reopen “My Fixes”; cached items should still appear.

## 10) Rate Limit Behavior (Free)
- Trigger multiple analyses until limit is reached (Free = 5/day).
- Confirm a paywall screen appears explaining Pro benefits.
- Confirm “Manage in Settings” opens Settings and “Not now” dismisses.

## 11) Settings
- Verify “Clear local cache” empties cached results in My Fixes.
- “Sign out” returns to Auth.

---

# TROUBLESHOOTING

## Xcode Signing
- If build fails with signing errors, set a valid development team in Xcode:
  - Select the project → Target → Signing & Capabilities → Team.

## Simulator Camera
- The iOS Simulator does not support a real camera.
- Use “Choose from Library” in the simulator.
- For camera testing, use a physical device.

## Missing Config.plist
- If `Config.plist` is missing, the app runs in Demo Mode with mock analysis.
- This is expected behavior.

## Supabase Function Deployment
- Ensure migrations are applied: `supabase db push`.
- Deploy the function: `supabase functions deploy analyze-photo`.
- Set secrets: `supabase secrets set AI_API_KEY=...`.
