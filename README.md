# 🌱 Rootio — Intelligent Farming Companion App (Upgraded)

## ──────────────────────────────────────────────────
## WHERE TO INSERT CREDENTIALS
## ──────────────────────────────────────────────────

### Firebase Credentials
File: `lib/firebase_options.dart`
- Insert your `apiKey`, `appId`, `messagingSenderId`, `projectId`, `storageBucket`, `authDomain` for each platform (Android, iOS, Web, macOS).
- Best approach: run `flutterfire configure` to auto-generate this file.

### OpenRouter API Key (AI Features)
File: `lib/services/ai_service.dart`
- Line: `static const String _apiKey = 'YOUR_OPENROUTER_API_KEY_HERE';`
- Get a free key at https://openrouter.ai
- The app works without it — fallback static insights are shown.

### Android google-services.json
File: `android/app/google-services.json`
- Download from Firebase Console → Project Settings → Android App.

### iOS GoogleService-Info.plist
File: `ios/Runner/GoogleService-Info.plist`
- Download from Firebase Console → Project Settings → iOS App.

## ──────────────────────────────────────────────────
## FIRESTORE DATABASE STRUCTURE
## ──────────────────────────────────────────────────

### Collection: `users`
Document ID: `{uid}` (Firebase Auth UID)

Fields:
```
name             : String
timeCommitment   : String   // e.g. "30 min/day"
growingSpaces    : Array<String>  // e.g. ["Balcony","Indoor"]
waterAvailability: String   // e.g. "Tap Water"
goals            : Array<String>  // e.g. ["Fresh Food","Hobby & Learning"]
experienceLevel  : String   // "Complete Beginner" | "Some Experience" | "Experienced"
climateZone      : String   // "Tropical" | "Subtropical" | "Temperate" | "Arid" | "Mediterranean" | "Not Sure"
streakDays       : Number
lastActiveDate   : String   // ISO date "yyyy-MM-dd"
```

### Sub-collection: `users/{uid}/plans`
Document ID: `{planId}` (auto-generated string)

Fields:
```
name        : String        // "Cherry Tomatoes"
emoji       : String        // "🍅"
difficulty  : String        // "Easy" | "Medium" | "Hard"
location    : String        // "Balcony" | "Indoor" | "Terrace" | "Backyard"
totalWeeks  : Number
isCompleted : Boolean
startedAt   : String        // ISO datetime
quickTips   : Array<String>
weeks       : Array<Map>    // see CropWeek structure below
notes       : Array<Map>    // see CropNote structure below
photos      : Array<Map>    // see CropPhoto structure below
```

**CropWeek map (inside weeks array):**
```
weekNumber     : Number
title          : String
isCurrentStage : Boolean
tasks          : Array<Map>  // see CropTask below
```

**CropTask map:**
```
id          : String
title       : String
isCompleted : Boolean
completedAt : String | null   // ISO datetime
```

**CropNote map:**
```
id        : String
content   : String
createdAt : String   // ISO datetime
```

**CropPhoto map:**
```
id         : String
imagePath  : String         // Firebase Storage URL after upload
storageUrl : String | null  // Firebase Storage download URL
takenAt    : String         // ISO datetime
```

### Sub-collection: `users/{uid}/activity`
Document ID: `{date}` (ISO date string e.g. "2024-07-15")

Fields:
```
date           : String  // "2024-07-15"
tasksCompleted : Number
```

### Sub-collection: `users/{uid}/insights`
Document ID: `insight_0`, `insight_1`, `insight_2`

Fields:
```
icon        : String  // emoji
text        : String
type        : String  // "tip" | "warning" | "motivation"
generatedAt : String  // ISO datetime
```

### Firebase Storage Structure
```
users/{uid}/plans/{planId}/{timestamp}.jpg
```

## ──────────────────────────────────────────────────
## SETUP & RUN INSTRUCTIONS
## ──────────────────────────────────────────────────

### 1. Create Firebase Project
- Go to https://console.firebase.google.com
- Create a new project named "rootio"
- Enable: Authentication (Anonymous), Cloud Firestore, Firebase Storage

### 2. Configure FlutterFire
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```
This replaces `lib/firebase_options.dart` with your real config.

### 3. Add platform config files
- **Android**: Download `google-services.json` → place in `android/app/`
- **iOS**: Download `GoogleService-Info.plist` → add to `ios/Runner/` in Xcode

### 4. Install dependencies
```bash
flutter pub get
```

### 5. Run
```bash
flutter run
```

### 6. (Optional) Add OpenRouter API key
- Edit `lib/services/ai_service.dart`
- Replace `YOUR_OPENROUTER_API_KEY_HERE` with your key
- AI insights in "Today's Insights" section will become live

## ──────────────────────────────────────────────────
## NEW FILES ADDED
## ──────────────────────────────────────────────────

| File | Purpose |
|---|---|
| `lib/firebase_options.dart` | Firebase config placeholder |
| `lib/services/firebase_service.dart` | All Firestore / Auth / Storage operations |
| `lib/services/ai_service.dart` | OpenRouter / Llama AI integration placeholder |
| `lib/services/recommendation_service.dart` | Rule-based crop recommendation engine |
| `lib/data/catalog_data.dart` | Extended crop catalog with compatibility metadata |
| `lib/screens/settings/settings_screen.dart` | Fully functional settings & profile editor |

## MODIFIED FILES

| File | Changes |
|---|---|
| `pubspec.yaml` | Added firebase_core, firebase_auth, cloud_firestore, firebase_storage, http, uuid |
| `lib/main.dart` | Firebase.initializeApp(), AppState.init() on startup |
| `lib/models/models.dart` | Added UserProfile, Firestore serialization (fromMap/toMap), WeeklyActivityEntry, AiInsight |
| `lib/data/app_state.dart` | Full Firebase integration, real streak/activity, AI insights, recommendations |
| `lib/screens/splash_screen.dart` | Auth check on launch, navigates to dashboard if already signed in |
| `lib/screens/loading_screen.dart` | Calls completeOnboarding() which saves to Firestore |
| `lib/screens/dashboard_screen.dart` | Real data, settings button wired, empty state, refresh insights |
| `lib/screens/add_crop_screen.dart` | Smart recommendations toggle (For You / All Crops) |
| `lib/screens/crop_detail_screen.dart` | Firestore task toggles, network photo display, note timestamps |
| `lib/screens/all_plans_screen.dart` | Swipe-to-delete with Firestore sync |

## ──────────────────────────────────────────────────
## FIRESTORE SECURITY RULES (Recommended)
## ──────────────────────────────────────────────────

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## Firebase Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```
