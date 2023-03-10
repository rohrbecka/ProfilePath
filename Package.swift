// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProfilePath",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ProfilePath",
            targets: ["ProfilePath"])
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", revision: "a876e860ee0e166a05428f430888de5d798c0f8d")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ProfilePath",
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]),
        .testTarget(
            name: "ProfilePathTests",
            dependencies: ["ProfilePath"])
    ]
)
