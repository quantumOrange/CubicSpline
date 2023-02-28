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

var products:[Product]  = [
    .library(
        name: "CubicSpline",
        targets: ["CubicSpline"]),
]

#if os(Linux)
    packageDependencies.append(.package(url: "https://github.com/indisoluble/CLapacke-Linux", .upToNextMajor(from: "1.0.0")))
#else
    targets.append(.target(
        name: "CubicSplineUI",
        dependencies: ["CubicSpline"]))

    products.append(.library(name: "CubicSplineUI", targets: ["CubicSplineUI"]))
#endif

let package = Package(
    name: "CubicSpline",
    products: products,
    dependencies: packageDependencies,
    targets: targets
)
