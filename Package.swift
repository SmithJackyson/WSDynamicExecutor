// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "WSDynamicExecutor",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(
      name: "WSDynamicExecutor",
      targets: ["WSDynamicExecutor"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/SmithJackyson/WSExecutorCommon.git", from: "0.0.1"),
  ],
  targets: [
    .target(
      name: "WSDynamicExecutor",
      dependencies: [
        "WSDynamicExecutorInternal",
        .product(name: "WSExecutorCommon", package: "WSExecutorCommon")
      ],
      path: "Sources",
      publicHeadersPath: "public",
      swiftSettings: [
        .enableUpcomingFeature("ApproachableConcurrency"),
      ],
    ),
    .target(
      name: "WSDynamicExecutorInternal",
      dependencies: [
        .product(name: "WSExecutorCommon", package: "WSExecutorCommon")
      ],
      path: "SwiftSources",
      publicHeadersPath: "internal",
      swiftSettings: [
        .enableUpcomingFeature("ApproachableConcurrency"),
      ],
    ),
  ]
)
