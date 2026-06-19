# Osmos Ads SDK Integration - Flutter Demo App

A production-ready demo application built in Flutter showcasing integration with the **Osmos Ads system**. The project is designed using **Clean Architecture** patterns, **BLoC** state management, and **GetIt** dependency injection. It dynamically fetches display banner ads, renders them respecting aspect ratio, tracks 50% visibility impressions, attributes click events, and provides a real-time event log stream across three interactive tabs.

---

## 🛠️ Setup & Run

### Prerequisites
- Flutter SDK (3.22.0 or higher)
- Android Studio / Android SDK (Min SDK 21, Target SDK 34)
- An active Android Emulator or Physical Device connected via ADB

### Run Instructions
1. Clone the repository and navigate to the project directory:
   ```bash
   cd ads_sdk_integration
   ```
2. Retrieve dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## 📂 Architecture Explanation

The project is structured under strict **Clean Architecture** guidelines:

```
lib/
├── app/              # Application bootstrapping (bootstrap.dart, app.dart)
├── core/             # Application constants, DI configurations, and logging utilities
├── sdk/              # Modular SDK wrapper services (Ad fetch, Event tracker, Initializer)
├── analytics/        # Consolidated analytics logging layer
└── features/
    └── ads/          # Ads feature module
        ├── data/     # Remote DataSource, JSON models, Repository implementation
        ├── domain/   # Pure Entities, Repository interface, and Use Cases
        └── presentation/  # BLoC, pages, views, and interactive UI components
```

- **Domain Layer**: Contains pure business logic and entities (`AdEntity`). Completely independent of third-party plugins.
- **Data Layer**: Translates JSON payloads (which can vary dynamically in schema structure) into clean domain entities.
- **SDK Layer**: Isolates the third-party `osmos_flutter_plugin` dependencies. If the SDK changes, only this layer requires updating.
- **Presentation Layer**: Uses **BLoC** (`AdBloc`) for state management and **GetIt** (`sl`) for dependency injection.

---

## 🔍 Core Requirement Implementations

### 1. SDK Integration & Configuration
- **Modular Initialization**: Isolated in [osmos_initializer.dart](lib/sdk/osmos_initializer.dart).
- **Parameters configured as required**:
  - `clientId = "10088010"`
  - `productAdsHost = "demo.o-s.io"`
  - `displayAdsHost = "demo-ba.o-s.io"`

### 2. How Ad Fetching Works (AU-Based)
Ad fetching requests are handled using the Osmos SDK `fetchDisplayAdsWithAu` method:
- **Request Parameters**:
  - `cliUbid = "Any"`
  - `pageType = "demo_page"`
  - `adUnits = ["banner_ads"]`
- **Field Extraction & Parsing**: 
  We parse the response payload and extract `ads.banner_ads[0]`. The mapping extracts:
  - `elements.value` → Ad Image URL
  - `elements.destination_url` → Landing URL (with fallback, see Challenges section)
  - `impression_tracking_url` → Direct impression server ping URL
  - `click_tracking_url` → Direct click server ping URL

### 3. Aspect Ratio Banner Rendering
- **ImageView Rendering**: Implemented using the [BannerAdWidget](lib/features/ads/presentation/widgets/banner_ad_widget.dart) featuring `CachedNetworkImage` for high-performance visual rendering.
- **Aspect Ratio Locking**: Rather than stretching or compressing the image, the widget uses the `AspectRatio` widget. The ratio is dynamically calculated as `width / height` based on the ad's metadata dimensions to fit the ad image perfectly without any cropping.

### 4. How Impression Logic is Handled (50% Visibility)
- **Helper**: Implemented as a reusable stateful wrapper in [ad_visibility_wrapper.dart](lib/features/ads/presentation/widgets/ad_visibility_wrapper.dart).
- **50% Detector**: Utilizes a `VisibilityDetector` checking if `visibleFraction >= 0.5`.
- **Once-Per-Session Lock**: Tracks whether the impression has fired in its local state (`_impressionFired`). Once visibility crosses 50%, it locks, fires the callback, and prevents further triggers.
- **Impression Trigger**: Triggers the SDK native impression event (`registerAdImpressionEvent`) and performs a concurrent, direct HTTP GET ping to the ad server's `impression_tracking_url` for redundant analytics tracking.

### 5. How Click Tracking is Handled
When the ad is tapped:
- **Event Dispatch**: Triggers the SDK native click event (`registerAdClickEvent`) and performs a concurrent background HTTP GET ping to the `click_tracking_url`.
- **Landing Redirection**: Opens `elements.destination_url` in the device's external web browser.

### 6. Event Logging & Diagnostics
Event actions (`Ad Loaded`, `Ad Failed`, `Impression Fired`, `Click Fired`) are recorded and logged:
- **Logcat**: Logged directly to the console using the standard Flutter logging system.
- **Interactive UI Event Console**: A dedicated full-screen logs terminal tab is integrated. It provides query filtering, level selection, auto-scroll locking, clipboard copying, and log clear triggers.
- **Tab-Based Verifier**: A separate diagnostics tab displays live status tick boxes and the exact URLs being pinged.

### 7. Error Handling & Resilience ("Ad not available")
The BLoC model handles failure states gracefully to prevent application crashes:
- **Failures Handled**: SDK initialization exceptions, empty responses (no ads returned), network timeouts, and invalid/missing payload data.
- **Fallback UI**: If an error occurs, a fallback screen is displayed showing the user-friendly message **"Ad not available"** along with a clear description and a **Retry** button.

### 8. UX, Lifecycles, and Rotations
- **Loading States**: A custom indicator is shown while the SDK fetches the ad.
- **Duplicate Prevention**: The BLoC state is locked to `AdLoading` during a request, ignoring concurrent trigger requests.
- **Lifecycle & Rotations**: BLoC states are kept alive across screen rotations. Using an `IndexedStack` wrapper inside [home_page.dart](lib/features/ads/presentation/pages/home_page.dart) maintains the scroll positions and active diagnostics of all tabs on configuration changes.

---

## 📋 Assumptions Made

To build a robust integration, the following logical assumptions were established:
1. **Network Requirement**: Ads fetching and event dispatch require internet access. Lack of network will route through a standard `NetworkFailure` and yield a friendly "Ad not available" fallback in the UI.
2. **Double Attribution Verification**: Direct HTTP GET requests to `impression_tracking_url` and `click_tracking_url` are run concurrently with SDK native registering methods. This handles edge cases where native channels could drop packets or experience delays.
3. **Responsive Size Overrides**: If specific ad height/width attributes are omitted in JSON, standard fallback `16:9` bounds are enforced to secure layouts.
4. **UCLID Presence**: We assume each fetched display ad is tagged with a UCLID (either at the root or within query string parameters of the tracking URLs) to establish click and impression events logging successfully.
5. **Android 11+ App Intents**: Target Android 11 (API level 30) devices or above are assumed, requiring manifest query declarations to support launching external browsers.

---

## ⚡ Challenges Faced & Resolutions

During integration, several critical issues were resolved to deliver a production-ready product:

### 1. Hot Restart SDK Singleton Collision
- **The Challenge**: During a hot restart, the Dart VM restarts, clearing the Dart-side singleton state (`OsmosSDK._sdkInstance`). However, the native Android process remains active in memory. Re-invoking the native initializer throws an uncaught native exception (`ERROR_ALREADY_INITIALIZED: OSMOS global instance can only be built once.`). This crashes the initialization flow in Dart and blocks any future ad requests.
- **The Resolution**: Updated `OsmosInitializer.init()` to catch this exception. If it detects `ERROR_ALREADY_INITIALIZED`, it falls back to creating a local `OsmosSDK` instance via the `builder.build()` method. We then refactored all services (`OsmosAdService` and `OsmosEventService`) to fetch the active `OsmosSDK` instance from the injected initializer singleton wrapper rather than referencing `OsmosSDK.globalInstance()`. This completely bypasses the static singleton limitation on Hot Restart.

### 2. Missing `destination_url` in Response Payload
- **The Challenge**: The mock server returned a payload elements map where the `destination_url` key was missing or empty, causing `canLaunchUrl` to fail and show a "Could not launch" warning.
- **The Resolution**: Configured `AdsRepositoryImpl` to automatically use `adModel.clickTrackingUrl` as the landing page if `elements.destinationUrl` is missing or empty, ensuring the browser can successfully load a destination.

### 3. Nested Image Dimensions
- **The Challenge**: The ad's dimensions (200x200) were nested inside the `elements` dictionary rather than the root level. Because the parser searched at the root level, it parsed width/height as null, defaulting the aspect ratio in the UI to `16 / 9` and cropping the square ad image.
- **The Resolution**: Updated `AdModel.fromJson` to parse `width` and `height` dimensions from the `elements` dictionary as a fallback if they are missing at the root level, maintaining a correct 1:1 ratio.

### 4. Package Queries visibility limits (Android 11+)
- **The Challenge**: On Android 11+ (API 30+), `canLaunchUrl` returns `false` for web links unless package query visibilities are explicitly declared in the manifest.
- **The Resolution**: Configured `<queries>` browser view intents for `http` and `https` in `AndroidManifest.xml` and added a try-catch direct launch fallback in `BannerAdWidget` that attempts a direct `launchUrl` call even if `canLaunchUrl` reports `false` (in case device queries settings fail to resolve).

### 5. RenderFlex Overflow in Error States
- **The Challenge**: Large native stack traces or long error descriptions propagated during exceptions caused the error screen columns to overflow vertically by several hundred pixels.
- **The Resolution**: Wrapped the UI states (`AdError` and `AdEmpty`) inside a `SingleChildScrollView` to cleanly scroll vertical stack details.

---

## 🧪 Verification Plan

### Automated Tests
The repository includes unit and widget tests:
- **BLoC State Verification**: Asserts that `AdBloc` moves through proper states (`AdInitial` -> `AdLoading` -> `AdLoaded`).
- **Flexible JSON parsing**: Verifies `AdsResponseModel` parses both wrapped and unwrapped JSON structures successfully.
- Run tests using:
  ```bash
  flutter test
  ```

### Manual Verification Steps
1. Navigate to the **Ad Simulator** tab. Click **Load Display Ad**.
2. Scroll down slowly. Once the ad is at least 50% visible, the **Impression** checkbox in the **Ad Verifier** tab automatically turns green, and an impression is logged in the **Event Console** tab.
3. Click the ad. The browser will open the click tracking URL, and the **Click** checkbox in the **Ad Verifier** tab will turn green, logging the click in the **Event Console**.
