// swift-tools-version: 5.9

// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import PackageDescription

let package = Package(
  name: "google_sign_in_ios",
  platforms: [
    .iOS("13.0"),
    .macOS("10.15"),
  ],
  products: [
    .library(name: "google-sign-in-ios", targets: ["google_sign_in_ios"])
  ],
  dependencies: [
    // Unreleased commit: first with app-check 12 support, which firebase-ios-sdk
    // 13 requires. Move back to a version once GoogleSignIn-iOS 10.1+ ships.
    .package(
      url: "https://github.com/google/GoogleSignIn-iOS.git",
      revision: "56d4ddc4aea182bd89a78b18f38c7512bf137cc0")
  ],
  targets: [
    .target(
      name: "google_sign_in_ios",
      dependencies: [
        .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
      ],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
