// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "AloeScrollView",
  platforms: [
    .iOS(.v9)
  ],
  products: [
    .library(name: "AloeScrollView", targets: ["AloeScrollView"])
  ],
  targets: [
    .target(name: "AloeScrollView")
  ]
)
