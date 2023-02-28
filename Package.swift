// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.0.0")),
]

var targetDependencies:[Target.Dependency] =  [.product(name: "Algorithms", package: "swift-algorithms")]

#if os(Linux)
   packageDependencies.append(.package(url: "https://github.com/indisoluble/CLapacke-Linux", .upToNextMajor(from: "1.0.0")))
#endif

let package = Package(
    name: "CubicSpline",
    products: [
        .library(
            name: "CubicSpline",
            targets: ["CubicSpline"]),
       .library(name: "CubicSplineUI", targets: ["CubicSplineUI"]),
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "CubicSpline",
            dependencies:targetDependencies),
        .target(
            name: "CubicSplineUI",
            dependencies: ["CubicSpline"]),
        .testTarget(
            name: "CubicSplineTests",
            dependencies: ["CubicSpline"]),
    ]
)
