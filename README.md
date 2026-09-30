# CommuteFlex

CommuteFlex is a local public transit journal for recording commutes and reviewing travel habits. Trips can be added manually or logged through a Tap In / Tap Out flow.

## Features

- Log trips manually, including transport, departure and arrival stations, date, fare, distance, route details, vehicle, and notes.
- Tap in at a nearby station and tap out at the destination. Location and nearby station lookup use Core Location and MapKit.
- Filter nearby station results by TransJakarta (TJ), MRT, LRT, or KRL, or search by station name. Operator filters are inferred from MapKit place names, so ambiguous results may be categorized imperfectly.
- Keep an active trip across app launches and see its elapsed time from Home.
- Review trip history, edit or delete trips, and browse monthly or all-time statistics.
- Share the selected monthly or all-time statistics as a vertical image through the iOS share sheet. Available destinations depend on the apps installed on the device.

## Requirements

- Xcode with the iOS SDK
- iOS 26.4 or later, based on the current project deployment target

## Getting Started

1. Open `CommuteFlex.xcodeproj` in Xcode.
2. Select the `CommuteFlex` scheme and an iOS Simulator or device.
3. Build and run the app.

To build from Terminal for a connected iOS toolchain:

```sh
xcodebuild -project CommuteFlex.xcodeproj \
  -scheme CommuteFlex \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Location Access

The app requests When In Use location access to suggest nearby transit stops for Tap In and Tap Out. If access is denied or no stations are found, retry after changing location access in iOS Settings. Manual trip entry does not require location access.

## Data and Privacy

Trip history is stored on device with SwiftData. An in-progress trip is saved locally in `UserDefaults` so it can be restored after the app is closed. The app has no account, backend, or cloud sync. Nearby station search uses Apple MapKit and requires location access.

## Project Structure

```text
CommuteFlex/
├── App/                 # App entry point and root tab/navigation view
├── Core/                # Location search, navigation, active-trip storage
├── Data/                # SwiftData trip and transit data models
└── Features/
    ├── Home/            # Trip history and manual trip management
├── Profile/           # App profile screen
    ├── Stats/            # Statistics and shareable recap card
    └── TapInOut/        # Tap In, Tap Out, and active trip UI
```

## Technology

- Swift / SwiftUI
- SwiftData for completed trips
- Core Location and MapKit for nearby station suggestions
- MVVM-style feature organization
