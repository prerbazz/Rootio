# 🌱 Rootio — Intelligent Farming Companion App

Rootio is a cross-platform Flutter application designed to guide urban and home farmers from seed to harvest. It features smart onboarding, climate-aware crop recommendations, milestone tracking with visual progress, task checklists, photo journals, and an AI-driven agricultural assistant powered by Google Gemini.

---

## 📱 Features

- **Personalized Onboarding**: Assesses user space (balcony, terrace, indoor), sunlight, water availability, experience level, and climate zone.
- **Dynamic Crop Catalog & Recommendations**: Rule-based recommendation engine matching user profile parameters to compatible crops.
- **Week-by-Week Action Plans**: Interactive milestone progression, scheduled care tasks (watering, fertilizing, pruning), and progress tracking.
- **Crop Journal & Photo Notes**: Log growth updates, attach plant images via camera or gallery, and store records directly in Firebase Storage.
- **AI Crop Assistant (Google Gemini)**: Real-time conversational advisory on plant health, pest management, and custom farming queries with built-in offline fallbacks.
- **Cloud Synchronization**: Real-time multi-device sync via Cloud Firestore and Firebase Authentication with local offline caching.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management**: Provider (`ChangeNotifierProvider`, `AppState`)
- **Backend & Cloud**:
  - **Firebase Authentication**: User identification & anonymous session handling
  - **Cloud Firestore**: Real-time document storage for user profiles, crop plans, and activity
  - **Firebase Storage**: Cloud hosting for plant journal photos
- **AI Integration**: Google Gemini API via OpenAI-compatible endpoints with client-side fallback handling
- **Local Storage**: `shared_preferences` for offline persistence and session states

---

## 🚀 Setup & Running Locally

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- Android Studio / Xcode / Chrome (depending on target platform)
- A physical device or emulator

### 2. Clone the Repository
```bash
git clone https://github.com/prerbazz/Rootio.git
cd Rootio
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Running the App

#### Running without Gemini API Key (Default Fallback Mode):
The application is fully functional without an AI key. When custom AI questions are asked without a key, clear user feedback and static farming guidance are displayed:
```bash
flutter run
```

#### Running with Google Gemini Enabled:
To activate live AI responses for the Crop Assistant, provide your Gemini API key securely at runtime via `--dart-define`:
```bash
flutter run --dart-define=GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
```

### 5. Building for Release

**Android APK:**
```bash
flutter build apk --dart-define=GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
```

**Web:**
```bash
flutter build web --dart-define=GEMINI_API_KEY="YOUR_GEMINI_API_KEY"
```

---

## 🧪 Testing & Quality Assurance

Rootio is structured for automated testing across Flutter, Android native (Appium), and Web (Selenium / WebDriver).

### Running Static Analysis
```bash
flutter analyze
```

### Running Automated Flutter Tests
```bash
flutter test
```

### Automated UI & Integration Testing Notes
- **Android / Appium**: Android package identifier is configured as `com.example.rootio1` under `android/app/build.gradle.kts`. All interactive widgets and form inputs provide standard semantic identifiers and labels.
- **Web / Selenium**: Flutter Web rendering supports CanvasKit and HTML renderers with interactive DOM element inspection.

---

## 🗄️ Firestore Database Structure

### Collection: `users/{uid}`
Stores the core farmer profile generated during onboarding.

| Field | Type | Description |
|---|---|---|
| `name` | String | Farmer's preferred name |
| `experienceLevel` | String | e.g. "Complete Beginner", "Some Experience" |
| `growingSpaces` | Array\<String\> | e.g. `["Balcony", "Indoor"]` |
| `waterAvailability` | String | e.g. "Tap Water", "Rainwater" |
| `climateZone` | String | e.g. "Tropical", "Subtropical", "Temperate" |
| `goals` | Array\<String\> | Farming motivations and targets |
| `timeCommitment` | String | Daily dedicated time |
| `streakDays` | Number | Active consecutive tracking days |
| `lastActiveDate` | String | ISO formatted date (`yyyy-MM-dd`) |

### Sub-collection: `users/{uid}/plans/{planId}`
Active and completed crop cultivation plans.

| Field | Type | Description |
|---|---|---|
| `name` | String | Name of the crop (e.g. "Cherry Tomatoes") |
| `emoji` | String | Visual icon representation |
| `difficulty` | String | "Easy" \| "Medium" \| "Hard" |
| `location` | String | Specific cultivation location |
| `totalWeeks` | Number | Total cultivation duration in weeks |
| `isCompleted` | Boolean | Completion status |
| `startedAt` | String | ISO datetime string |
| `quickTips` | Array\<String\> | Curated advice for the crop |
| `weeks` | Array\<Map\> | Week numbers, titles, and task maps |
| `notes` | Array\<Map\> | User journal entries and timestamps |
| `photos` | Array\<Map\> | Firebase Storage URLs and capture dates |

### Sub-collection: `users/{uid}/activity/{date}`
Tracks daily completed tasks for activity heatmaps and streak counters.

---

## 🔒 Recommended Firebase Security Rules

To enforce least-privilege access so users can only access their own documents and files:

### Cloud Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

### Firebase Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```
