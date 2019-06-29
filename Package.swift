// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "incordAPI",
    products: [
        .library(name: "incordAPI", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.8"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        //We will use PostgreSQL
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.4"),
        .package(url: "https://github.com/vapor/websocket.git", from: "1.1.2"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Authentication", "WebSocket"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

