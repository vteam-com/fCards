# Vendored google_sign_in_ios 6.3.8 (patched)

Copy of google_sign_in_ios 6.3.8 from pub.dev with one change: the native
GoogleSignIn-iOS dependency is raised from the 9.x line to 10.x in
`darwin/google_sign_in_ios/Package.swift` and `darwin/google_sign_in_ios.podspec`.

Why: firebase-ios-sdk 13 (firebase_core 5 / firebase_auth 7 / firebase_database 13)
requires GTMSessionFetcher 4+ and app-check 12.x. GoogleSignIn-iOS 9.x pins
GTMSessionFetcher below 4, and 10.0.0 (the newest release) pins app-check 11.x, so
Swift Package Manager cannot resolve the app with the plugin as published.

The Swift package therefore points at GoogleSignIn-iOS main by exact revision
`56d4ddc4aea182bd89a78b18f38c7512bf137cc0` (October 21, 2026), the first line to accept app-check 12
(commit 4ce331c, "Add SPM AppCheckCore 12.x support", October 15, 2026). The podspec
is raised to `~> 10.0` for completeness, but CocoaPods cannot resolve Firebase 13 with
any released GoogleSignIn pod, so the Swift Package Manager path is the one that works.

Wired in through `dependency_overrides` in the app's pubspec.yaml. Once GoogleSignIn-iOS tags a release with app-check 12 support, switch the
`revision:` back to `from:` that version; once google_sign_in_ios on pub.dev depends
on that release, delete this folder and the override.
