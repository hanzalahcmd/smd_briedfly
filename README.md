# Briefly.

A Flutter tech news app that delivers curated stories from two sources — a hosted backend feed and a live Gemini AI-generated brief.

---

## Screenshots

| Feed | AI Brief |
|------|----------|
| ![Feed Screen](https://github.com/hanzalahcmd/smd_briedfly/blob/main/Screenshot_20260504_062107.jpg) | ![AI Brief Screen](https://github.com/hanzalahcmd/smd_briedfly/blob/main/Screenshot_20260504_062114.jpg) |

> Add your screenshots to a `screenshots/` folder in the project root and update the paths above.

---

## What Changed from the Original Briefly

The original app had a single data source — a hosted Cloud Run backend that returned pre-formatted tech news. The following changes were made on top of that foundation.

---

### 1. New Data Source — Gemini API
**File:** `lib/data/datasources/gemini_news_data_source.dart` ← new file, did not exist before

Calls the Gemini API directly from the app using the `google_generative_ai` package. Uses a system instruction to set Gemini's behaviour and sends a user prompt asking for the latest tech news. The response is parsed into `NewsItem` objects so the rest of the app doesn't need to know where the data came from.

---

### 2. Config File for API Key
**File:** `lib/core/config/app_config.dart` ← new file, did not exist before

Single place for the Gemini API key. The key is never hard-coded — it is injected at compile time via `--dart-define-from-file=.env`.

Create a `.env` file in the project root (never commit this):
```
GEMINI_API_KEY=your_key_here
```

Run the app with:
```powershell
flutter run -d <device_id> --dart-define-from-file=.env
```

---

### 3. Repository Now Has Two Sources
**File:** `lib/data/repositories/news_repository.dart` ← modified

Originally only accepted `NewsRemoteDataSource`. Now also accepts `GeminiNewsDataSource` in its constructor and exposes a second method `getGeminiTechNews()` alongside the original `getTechNews()`.

---

### 4. BLoC — Source Routing + In-Memory Cache
**Files:**
- `lib/bloc/news_event.dart` ← modified — added `NewsSource` enum (`remote` / `gemini`) and a `source` parameter on `LoadNews`
- `lib/bloc/news_bloc.dart` ← modified — routes to the correct data source based on `event.source`, holds an in-memory cache so switching tabs never fires a second Gemini call in the same session
- `lib/bloc/news_state.dart` ← modified — `NewsLoaded` now carries the `source` field so the UI knows which tab is active

---

### 5. Source Toggle in the UI
**File:** `lib/presentation/screens/news_screen.dart` ← modified

Added a pill-shaped **Feed / AI Brief** segmented toggle below the AppBar. Tapping a tab fires `LoadNews(source: ...)` to the bloc. The Gemini loading state shows *"Asking Gemini for the latest…"* so the user knows it is an AI call. Error state was also improved with a retry button.

---

### 6. AI Badge on Cards
**File:** `lib/presentation/widgets/news_card.dart` ← modified

Added an `isGemini` flag. When viewing AI Brief, each card shows a small lime-coloured **✦ AI** badge in the top-right corner so the source of the story is always visible.

---

### 7. Android Internet Permission
**File:** `android/app/src/main/AndroidManifest.xml` ← modified

The original repo was missing this — without it the app throws `SocketException: Failed host lookup` on device. Added directly inside `<manifest>` before `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

### 8. Dependency Added
**File:** `pubspec.yaml` ← modified

```yaml
google_generative_ai: ^0.4.7
```

---

## Project Structure

```
lib/
├── bloc/
│   ├── news_bloc.dart         # routing + in-memory Gemini cache
│   ├── news_event.dart        # NewsSource enum + LoadNews event
│   └── news_state.dart        # NewsLoaded carries source
├── core/
│   └── config/
│       └── app_config.dart    # API key via --dart-define  ← NEW
├── data/
│   ├── datasources/
│   │   ├── news_remote_data_source.dart   # original, unchanged
│   │   └── gemini_news_data_source.dart   # ← NEW
│   ├── models/
│   │   └── news_item.dart     # unchanged
│   └── repositories/
│       └── news_repository.dart   # now wraps both sources
├── presentation/
│   ├── screens/
│   │   └── news_screen.dart   # Feed/AI Brief toggle
│   └── widgets/
│       ├── news_card.dart     # AI badge added
│       └── share_daily_brief_sheet.dart   # unchanged
└── main.dart                  # injects both data sources
```

---

## Getting Started

1. Clone the repo
2. Create a `.env` file in the project root:
   ```
   GEMINI_API_KEY=your_key_here
   ```
   Get a free key at [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

3. Install dependencies:
   ```powershell
   flutter pub get
   ```

4. Run on your device:
   ```powershell
   flutter run -d <your_device_id> --dart-define-from-file=.env
   ```

---

## Notes on Gemini Free Tier

Rate limits are per **project**, not per API key — creating a new key from the same Google account does not reset your quota. The app caches the Gemini response in memory so only one API call is made per app launch regardless of how many times you switch to the AI Brief tab.
