// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "incordAPI",
    products: [
        .library(name: "incordAPI", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
       .package(url: "https://github.com/vapor/vapor.git", .upToNextMinor(from: "3.3.0")),
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        //We will use PostgreSQL
        .package(url: "https://github.com/vapor/fluent-postgresql.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/vapor/auth.git", .upToNextMinor(from: "2.0.4"))
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

