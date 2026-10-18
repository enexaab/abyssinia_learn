# Abyssinia Learn

A mini e-learning mobile application built with Flutter for the Abyssinia Software Technology PLC practical assignment. Users can sign up, browse courses, open chapters and lessons, stream videos, and download them for offline playback.

## Features

- Sign-up, login and logout with local storage and mock user data
- Course list with thumbnails, descriptions, level, instructor and chapter counts
- Chapters and lessons loaded from a local JSON file
- In-app video playback with playback controls
- Video download with live progress and status
- Offline playback of downloaded videos
- Downloaded-lessons records kept in local storage
- Loading, empty and error states across screens
- Streaming-only lesson that cannot be downloaded, to demonstrate unsupported downloads

## Test Credentials

| Name | Email | Password |
|------|-------|----------|
| Demo Student | demo@abyssinia.com | Demo@1234 |

You can also create a new account from the Sign-Up screen.

## Requirements

- Flutter SDK 3.x (stable channel)
- Dart SDK bundled with Flutter
- Android SDK with an emulator or a physical Android device
- Internet connection for first-time dependency download, video streaming and downloads

## Setup

```bash
git clone <repository-url>
cd abyssinia_learn
flutter pub get
flutter run
```

## Build the APK

```bash
flutter build apk --release --split-per-abi
```

Output files are in `build/app/outputs/flutter-apk/`. Install `app-arm64-v8a-release.apk` on most modern Android phones.

For a single APK that runs on every device:

```bash
flutter build apk --release
```

## Project Structure
