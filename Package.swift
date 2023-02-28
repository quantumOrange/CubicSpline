// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var packageDependencies: [Package.Dependency] = []

var targetDependencies:[Target.Dependency] =  []

var targets:[Target] =  [
    .target(
        name: "CubicSpline",
        dependencies:targetDependencies),
    .testTarget(
        name: "CubicSplineTests",
        dependencies: ["CubicSpline"]),
]

#if os(Linux)
    packageDependencies.append(.package(url: "https://github.com/indisoluble/CLapacke-Linux", .upToNextMajor(from: "1.0.0")))
#else
    targets.append(.target(
        name: "CubicSplineUI",
        dependencies: ["CubicSpline"]))
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
    targets: targets
)
