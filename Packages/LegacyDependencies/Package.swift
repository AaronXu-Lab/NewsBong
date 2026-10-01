// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "LegacyDependencies", platforms: [.iOS("26.0")], products: [.library(name: "Ji", targets: ["Ji"]),
.library(name: "JJStockView", targets: ["JJStockView"])], targets: [.target(name: "Ji", linkerSettings: [.linkedLibrary("xml2")]),
.target(name: "JJStockView", publicHeadersPath: "include", cSettings: [.headerSearchPath("include"), .unsafeFlags(["-fobjc-arc"])], linkerSettings: [])], swiftLanguageVersions: [.v5])
