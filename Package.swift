// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "BlondXPC",
  platforms: [
    .macOS(.v10_10),
  ],
  products: [
    .library(name: "BlondXPC", targets: ["BlondXPC"]),
    .library(name: "BlondXPCEncoder", targets: ["BlondXPCEncoder"]),
  ],
  dependencies: [
    .package(url: "https://github.com/kojirou1994/CUtility.git", from: "0.0.1"),
  ],
  targets: [
    .target(
      name: "BlondXPC",
      dependencies: [
        .product(name: "CUtility", package: "CUtility"),
      ]),
    .target(
      name: "BlondXPCEncoder",
      dependencies: ["BlondXPC"]),
    .testTarget(
      name: "BlondXPCTests",
      dependencies: ["BlondXPC"]),
  ]
)
