// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "evm",
    dependencies: [.package(url: "https://github.com/attaswift/BigInt.git", exact: "6.0.1")],
    targets: [
        .executableTarget(
            name: "evm",
            dependencies: [.product(name: "BigInt", package: "BigInt")],
            path: ".",
            sources: ["evm.swift"]
        )
    ]
)
