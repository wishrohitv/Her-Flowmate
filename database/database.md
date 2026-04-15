# Her-Flowmate — Database Architecture

> **Last updated:** April 2026  
> **Stack:** Flutter · Hive CE (local NoSQL) · SharedPreferences (key-value) · REST API (remote sync)

---

## Table of Contents

1. [Overview](#overview)
2. [Storage Layers](#storage-layers)
3. [Data Models](#data-models)
   - [PeriodLog](#1-periodlog)
   - [DailyLog](#2-dailylog)
   - [Appointment](#3-appointment)
   - [User](#4-user)
4. [Hive Boxes](#hive-boxes)
5. [SharedPreferences Keys](#sharedpreferences-keys)
6. [Service Layer](#service-layer)
7. [Backend Sync (REST API)](#backend-sync-rest-api)
8. [Initialization Flow](#initialization-flow)
9. [Data Lifecycle](#data-lifecycle)
10. [Relationships & Derived Data](#relationships--derived-data)

---

## Data Privacy & Clinical Scope

> [!NOTE]
> **Wellness & Tracking Platform:** Her-Flowmate is a personal wellness companion designed for cycle tracking and pattern visualization.
> 1. **User-Controlled Data:** While users can log health-related data (moods, symptoms, wellness activities) for their own reference or to share with their providers, the app **does not provide clinical services**.
> 2. **Not a Clinical Service:** The app does not facilitate or manage **professional doctor appointments, clinical consultations, or medical diagnoses**.
> 3. **Non-Clinical Database:** Database structures are optimized for self-tracking and wellness reminders. The "Appointment" model is a personal reminder tool and not a clinical scheduling system.
> 4. **Retention Policy:** Data is kept locally until the user logs out (which clears local data) or requests account deletion (which purges backend data). There is no automatic expiration of data.

---

Her-Flowmate uses a **dual-storage** strategy:

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Structured local data | **Hive CE** (v2.3.4) | Period logs, daily health logs, appointments, user profile |
| Scalar settings | **SharedPreferences** | Flags, preferences, auth token |
| Remote persistence | **REST API** (Render.com) | Cloud sync for period logs, daily logs, user profile |

All storage is managed exclusively through the **`StorageService` singleton** (facade pattern), which delegates to five specialized sub-services.

---

## Storage Layers

```
StorageService (singleton facade)
├── BaseStorageService   → Hive init + adapter registration + SharedPreferences
├── OnboardingService    → User profile (Hive box: user_box)
├── PeriodLogService     → Period logs (Hive box: period_logs)
├── HealthTrackerService → Daily health logs (Hive box: daily_logs)
├── AppointmentService   → Wellness reminders (Hive box: appointments)
└── PregnancyService     → Pregnancy dates (SharedPreferences)
```

---

## Data Models

### 1. `PeriodLog`

**File:** `lib/models/period_log.dart`  
**Hive typeId:** `0`  
**Hive box:** `period_logs`

| Field | Type | HiveField | Description |
|-------|------|-----------|-------------|
| `startDate` | `DateTime` | 0 | First day of the period (required) |
| `duration` | `int` | 1 | Estimated number of bleeding days (required) |
| `flowIntensity` | `String?` | 2 | `"light"`, `"medium"`, or `"heavy"` |
| `symptoms` | `List<String>?` | 3 | e.g. `["cramps", "headache"]` |
| `mood` | `String?` | 4 | User-selected mood string |
| `endDate` | `DateTime?` | 5 | Actual end date (nullable) |
| `isAM` | `bool` | 6 | Whether period started in AM (default: `true`) |

**JSON mapping** (for API sync):

```json
{
  "startDate": "2026-04-01T00:00:00.000Z",
  "duration": 5,
  "flowIntensity": "medium",
  "symptoms": ["cramps"],
  "mood": "calm",
  "endDate": "2026-04-05T00:00:00.000Z",
  "isAM": true
}
```

**Validation rules:**
- `endDate` must not be before `startDate`
- `duration` must be > 0
- Overlap detection: a new log is rejected if its date range overlaps any existing log. *Note: Adjacent periods (`endDate` + 1 == new `startDate`) are allowed – no overlap.*

---

### 2. `DailyLog`

**File:** `lib/models/daily_log.dart`  
**Hive typeId:** `1`  
**Hive box:** `daily_logs`

| Field | Type | HiveField | Description |
|-------|------|-----------|-------------|
| `date` | `DateTime` | 0 | The calendar day this log belongs to (required) |
| `moods` | `List<String>?` | 1 | e.g. `["happy", "energetic"]` |
| `symptoms` | `List<String>?` | 2 | General health symptoms |
| `waterIntake` | `int?` | 3 | Number of glasses consumed |
| `notes` | `String?` | 4 | Free-text daily note |
| `flowIntensity` | `String?` | 5 | Flow intensity if on period |
| `physicalActivity` | `List<String>?` | 6 | e.g. `["yoga", "walk"]` |
| `sleepHours` | `double?` | 7 | Hours of sleep (e.g. `7.5`) |
| `energyLevel` | `int?` | 8 | 1 (exhausted) → 5 (very energetic) |
| `stressLevel` | `int?` | 9 | 1 (very calm) → 5 (very stressed) |
| `basalBodyTemperature` | `double?` | 10 | BBT in Celsius (fertility tracking) |
| `stepsCount` | `int?` | 11 | Steps walked today |

**Persistence Model:**  
Daily logs are stored using their **date string (`YYYY-MM-DD`)** as the primary key. This ensures O(1) lookups without iterating through lists and atomic overwrites for same-day entries.
> **Timezone Handling:** All dates are stored using the **local device timezone** (e.g., `DateTime.now().toLocal()`). If a user travels across timezones, the same UTC day may map to different local dates.

**JSON mapping** (for API sync):

```json
{
  "date": "2026-04-13T00:00:00.000Z",
  "moods": ["calm"],
  "symptoms": [],
  "waterIntake": 8,
  "notes": "Felt great today",
  "flowIntensity": null,
  "physicalActivity": ["yoga"],
  "sleepHours": 7.5,
  "energyLevel": 4,
  "stressLevel": 2,
  "basalBodyTemperature": 36.6,
  "stepsCount": 8000
}
```

---

### 3. `Appointment` (Personal Reminders)

**File:** `lib/models/appointment.dart`  
**Hive typeId:** `3`  
**Hive box:** `appointments`

> [!NOTE]
> **Personal & Wellness Tracking:** This model is designed for users to set **personal wellness and self-care reminders**. While users can log any activity for their own tracking, the application **does not provide services for managing professional doctor appointments, clinical procedures, or medical consultations**.

| Field | Type | HiveField | Description |
|-------|------|-----------|-------------|
| `title` | `String` | 0 | Reminder / self-care title (required) |
| `date` | `DateTime` | 1 | Scheduled date & time (required) |
| `location` | `String?` | 2 | Optional location |
| `notes` | `String?` | 3 | Optional personal notes |
| `typeIndex` | `int` | 4 | Index into `WellnessCategory` enum (required) |

**`WellnessCategory` Enum:**

| Index | Value | Label | Emoji |
|-------|-------|-------|-------|
| 0 | `selfCare` | Self-Care | 🛁 |
| 1 | `movement` | Movement | 🧘 |
| 2 | `mindfulness` | Mindfulness | 🧠 |
| 3 | `nutrition` | Nutrition | 🥗 |
| 4 | `social` | Social | 💬 |
| 5 | `goal` | Goal | 🎯 |
| 6 | `other` | Other | ✨ |

> **Note:** Appointments are **local-only**. The backend sync endpoints for appointments are not yet implemented (`/appointments` returns no-op).

---

### 4. `User`

**File:** `lib/models/user.dart`  
**Hive typeId:** `10`  
**Hive box:** `user_box`  
**Hive key:** `"current_user"` (single record)

| Field | Type | HiveField | Backend Key | Description |
|-------|------|-----------|-------------|-------------|
| `name` | `String` | 0 | `display_name` | User's display name (required) |
| `age` | `int` | 1 | `age` | User's age (required) |
| `goal` | `String` | 2 | `goal` | App mode: `track_cycle`, `conceive`, or `pregnant` |
| `imagePath` | `String?` | 3 | `photo_url` | Local file path for profile photo |
| `weight` | `double?` | 4 | `weight` | Weight (unit unspecified) |
| `height` | `double?` | 5 | `height` | Height (unit unspecified) |

**Validation rules:**
- `name` must not be empty or whitespace-only
- `age` must be in range `1–120`

**Goal values and their meaning:**

| Value | Mode |
|-------|------|
| `track_cycle` | Default — period tracking & insights |
| `conceive` | Conception mode — fertility windows highlighted |
| `pregnant` | Pregnancy mode — week-by-week tracker |

---

## Hive Boxes

| Box Name | Model | typeId | Adapter | Opened By |
|----------|-------|--------|---------|-----------|
| `period_logs` | `PeriodLog` | 0 | `PeriodLogAdapter` | `PeriodLogService.init()` |
| `daily_logs` | `DailyLog` | 1 | `DailyLogAdapter` | `HealthTrackerService.init()` |
| `appointments` | `Appointment` | 3 | `AppointmentAdapter` | `AppointmentService.init()` |
| `user_box` | `User` | 10 | `UserAdapter` | `OnboardingService.init()` |

> **typeId 2** is unused/reserved for a future model.  
> All adapters are **manually written** (no code generation) and registered in `BaseStorageService.init()`.

---

## SharedPreferences Keys

These are all scalar flags and settings persisted via `SharedPreferences`.

| Key | Type | Default | Example | Description |
|-----|------|---------|---------|-------------|
| `auth_token` | `String?` | `null` | `"eyJhbGci..."` | Bearer token for backend API calls |
| `hasCompletedLogin` | `bool` | `false` | `true` | Whether user has completed the login step |
| `hasCompletedOnboarding` | `bool` | `false` | `true` | Whether user has completed onboarding |
| `isLoggedIn` | `bool` | `false` | `true` | Current authenticated session flag |
| `userName` | `String?` | `null` | `"Jane Doe"` | Fallback name when Hive user box is empty |
| `userGoal` | `String?` | `null` | `"track_cycle"` | Fallback goal string |
| `userAge` | `int?` | `null` | `28` | Fallback age |
| `userImagePath` | `String?` | `null` | `"/data/user/0/img.png"` | Fallback profile image path |
| `isDarkMode` | `bool` | `false` | `true` | Theme preference |
| `isMinimalMode` | `bool` | `false` | `false` | Minimal UI mode toggle |
| `isHighPerformanceMode` | `bool` | `true` | `false` | Performance rendering mode |
| `isPinLocked` | `bool` | `false` | `true` | App-lock (PIN/biometric) enabled |
| `hasSeenInfoPopup` | `bool` | `false` | `true` | One-time info popup seen state |
| `hydrationGoal` | `int` | `8` (from `AppConstants`) | `8` | Daily water intake target (glasses) |
| `pregnancyWeeks` | `int?` | `null` | `12` | Manually set pregnancy week override |
| `conceptionDate` | `String?` | `null` | `"2025-10-01..."` | ISO 8601 date string |
| `dueDate` | `String?` | `null` | `"2026-07-08..."` | ISO 8601 date string |

---

## Service Layer

### `BaseStorageService` _(singleton)_
- Initializes `SharedPreferences`
- Calls `Hive.initFlutter()`
- Registers all four Hive type adapters (typeIds 0, 1, 3, 10)

### `OnboardingService` _(ChangeNotifier)_
- Manages `user_box` (single `User` record keyed `"current_user"`)
- Exposes: login state, onboarding state, dark mode, user profile getters
- On logout: clears all flags and deletes user from Hive

### `PeriodLogService` _(ChangeNotifier)_
- Manages `period_logs` box
- **Performance Note:** Caches the sorted list in `_cachedLogs` (invalidated on any write) to avoid O(N) iteration overhead on every read.
- Sorts logs descending by `startDate` (most recent first)
- **Overlap detection** prevents duplicate/overlapping periods from being saved
- Schedules push notifications for next predicted period after every save/delete
- Backend: `POST /logs/periods`, `GET /logs/periods`

### `HealthTrackerService` _(ChangeNotifier)_
- Manages `daily_logs` box
- Lookup is by exact calendar day string (`YYYY-MM-DD`)
- **O(1) Efficiency:** Direct Hive key access for instant daily retrieval
- Upsert behavior: Atomic overwrite using date-string keys
- Computes **check-in streak** by walking backwards from today's key string
- Backend: `POST /logs/daily`, `GET /logs/daily`

### `AppointmentService` _(ChangeNotifier)_
- Manages `appointments` box
- On save: schedules local notification via `NotificationService`
- On delete: cancels corresponding notification (`notificationId = 100 + hiveKey`)
- Backend: **no-op** (endpoints not yet available)

### `PregnancyService` _(ChangeNotifier)_
- No Hive box — uses SharedPreferences only
- Stores `conceptionDate`, `dueDate`, `pregnancyWeeks`
- Due date calculated as `LMP + 280 days` (Naegele's rule). *Note: Naegele’s rule assumes a 28‑day cycle. For irregular cycles, this due date is an estimate.*

### `StorageService` _(singleton ChangeNotifier — Facade)_
- Composes all five sub-services
- Provides unified `init()` that initializes services in the correct order
  1. `BaseStorageService.init()` (must be first — registers Hive adapters)
  2. `onboarding`, `periodLog`, `healthTracker`, `appointment` opened in parallel
- Exposes `syncUserWithBackend()` — orchestrates full remote sync. *Note: this operation is triggered manually (e.g., on login) to avoid excessive network calls.*
- Provides `exportLogsToJson()`, `importLogsFromJson()`, `exportLogsToPdf()`
- `clearAllData()` wipes both SharedPreferences and all Hive boxes from disk

---

## Backend Sync (REST API)

**Base URL:** `https://her-flowmate-backend.onrender.com` (configurable via `--dart-define=API_BASE_URL=...`)  
**Auth:** Bearer token in `Authorization` header (stored in SharedPreferences as `auth_token`)  
**Timeout:** 3 minutes per request

| Endpoint | Method | Service | Notes |
|----------|--------|---------|-------|
| `/logs/periods` | `GET` | `PeriodLogService.fetchLogs()` | Replaces local logs entirely with remote |
| `/logs/periods` | `POST` | `PeriodLogService.uploadLogs()` | Sends all local logs as JSON array |
| `/logs/daily` | `GET` | `HealthTrackerService.fetchLogs()` | Replaces local daily logs with remote |
| `/logs/daily` | `POST` | `HealthTrackerService.uploadLogs()` | Sends all local daily logs as JSON array |
| `/user` (assumed) | `GET` | `UserService.getUserProfile()` | Fetches remote user profile |
| `/user` (assumed) | `PUT` | `UserService.updateUserProfile()` | Pushes local user profile |
| `/appointments` | — | `AppointmentService` | **Not implemented** — local only |

**Sync strategy:** "remote wins" — on fetch, the local Hive box is cleared and replaced with remote data. No conflict resolution or delta sync is implemented.
> [!WARNING]
> This "remote wins" strategy may cause **data loss** if a user logs data offline and then syncs, as the older remote version will overwrite newer local logs. A more robust sync strategy (e.g., timestamp comparison, delta sync, and an offline queue) is planned for a future update.

---

## Initialization Flow

```
main() / main.dart
  └─ StorageService.instance.init()
       ├─ 1. BaseStorageService.init()
       │       ├─ SharedPreferences.getInstance()
       │       ├─ Hive.initFlutter()
       │       └─ Register adapters: PeriodLogAdapter(0), DailyLogAdapter(1),
       │                             AppointmentAdapter(3), UserAdapter(10)
       │
       ├─ 2. [parallel]
       │       ├─ OnboardingService.init()  → Hive.openBox<User>('user_box')
       │       ├─ PeriodLogService.init()   → Hive.openBox<PeriodLog>('period_logs')
       │       ├─ HealthTrackerService.init()→ Hive.openBox<DailyLog>('daily_logs')
       │       └─ AppointmentService.init() → Hive.openBox<Appointment>('appointments')
       │
       └─ 3. Attach ChangeNotifier listeners (cascades to StorageService.notifyListeners)
```

---

## Data Lifecycle

```
User Action
    │
    ▼
Screen / Widget
    │  calls
    ▼
StorageService (facade)
    │  delegates to
    ▼
Specialized Service (e.g. PeriodLogService)
    │  reads/writes
    ▼
Hive Box  ◄─────────────────────── API Sync (on login / manual trigger)
    │                                   (fetches remote → overwrites local)
    │  notifyListeners()
    ▼
Riverpod Providers / Provider.watch()
    │
    ▼
UI rebuilds
```

### Cleanup / Reset
- **Logout** (`OnboardingService.logout()`): clears login flags, deletes `User` from Hive
- **Full reset** (`StorageService.clearAllData()`): `SharedPreferences.clear()` + `Hive.deleteFromDisk()` — **destructive, irreversible**

---

## Relationships & Derived Data

The app derives meaningful health data from the raw stored logs using two stateless classes:

### `CycleEngine` (`lib/models/cycle_engine.dart`)
Pure computation on `List<PeriodLog>`. **Strictly enforces date-sorting** before any calculation to ensure accuracy. No storage access.

| Method | Output | Description |
|--------|--------|-------------|
| `calculateAverageCycleLength(logs)` | `int` | Mean days between period starts (range-filtered: 15–90d) |
| `detectIrregularity(logs)` | `bool` | `true` if max-min cycle length variance > 7 days |
| `getPhaseForDate(date, logs, avgLen)` | `CyclePhase` | Menstrual / Follicular / Ovulation / Luteal / Unknown |
| `calculateHormones(cycleDay, cycleLen)` | `Map<String, double>` | Normalized 0.0–1.0 levels for Estrogen, Progesterone, LH, FSH |
| `calculateConceptionChance(date, logs, avgLen)` | `int` | Percentage (1–33%) based on proximity to ovulation |

**Cycle phases:**

| Phase | Approx. timing |
|-------|---------------|
| `menstrual` | Start of period until bleeding stops |
| `follicular` | After bleeding to ovulation day − 5 |
| `ovulation` | Days around `cycleLen − 14` |
| `luteal` | Post-ovulation until end of cycle |

> **Complexity Warning:** The phase calculation (`cycleLen - 14`) assumes a 14‑day luteal phase for prediction purposes. In reality, luteal phases vary (10–16 days). Future versions may allow user-specific luteal length configuration.

### `PredictionService` (`lib/services/prediction_service.dart`)
Wraps `CycleEngine` with `StorageService` context. Used by Riverpod `predictionServiceProvider`.

| Property / Method | Description |
|-------------------|-------------|
| `averageCycleLength` | From `CycleEngine` |
| `currentPhase` | Phase for today |
| `currentCycleDay` | Day number within current cycle (1-based) |
| `nextPeriodDate` | `currentPeriodStart + averageCycleLength` |
| `daysUntilNextPeriod` | Countdown to next period |
| `daysUntilOvulation` | Countdown to next ovulation window |
| `isIrregularCycle` | Variance-based flag |
| `getHealthScore()` | 0–100 score: base 50, +30 if regular, +20 if ≥3 logs |
| `isFertileDay(date)` | `true` if ovulation phase or conception chance ≥ 10% |
| `getHormoneLevels(cycleDay)` | Returns `Map<String, double>` |
| `fertilityLevel` | `"High"` / `"Moderate"` / `"Low"` string |

---

## Error Handling Strategy

1. **Local Storage:** Local Hive writes and SharedPreferences updates are immediate and synchronous. 
2. **API Calls:** Network requests are subject to timeouts. Operations that fail due to network instability are logged and (in some service layers) retried.
3. **Data Integrity:** Invalid JSON payloads from the backend are caught during parsing. Missing optional fields gracefully fall back to `null` or default values. User-friendly error messages are surfaced during API failures to prevent silent failures.

---

## Tech Debt & Roadmap

The current architecture is stable but has known gaps flagged for future improvement:

- **Appointment Sync:** The `/appointments` backend endpoints are not implemented. Appointments remain local-only.
- **Offline Sync Queue:** Currently lacking an offline-first retry queue. Failed network requests are not automatically retried later.
- **Delta Sync:** The "remote wins" strategy lacks granularity. We need differential sync (timestamp comparison) to prevent overwriting newer offline data with older remote data.
- **Luteal Phase Configuration:** Defaulting to a 14-day luteal phase is a simplification; allowing users to define their historical luteal baseline would improve prediction accuracy.

---

*For architectural patterns (Fragment Pattern, Nuclear Stability, LMP rules), see [`docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md).*
