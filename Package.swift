// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "BlondXPC",
  products: [
    .library(name: "BlondXPC", targets: ["BlondXPC"]),
  ],
  dependencies: [
    .package(url: "https://github.com/kojirou1994/CUtility.git", from: "0.0.1"),
  ],
  targets: [
    .target(
      name: "BlondXPC",
      dependencies: [
        .product(name: "CUtility", package: "CUtility")
      ]),
    .testTarget(
      name: "BlondXPCTests",
      dependencies: ["BlondXPC"]),
  ]
)
