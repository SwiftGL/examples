// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "example",
    products: [
        .executable(name: "example", targets: ["example"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGL/OpenGL.git", from: "3.0.0"),
        .package(url: "https://github.com/SwiftGL/Math.git", from: "2.0.0"),
        .package(url: "https://github.com/SwiftGL/Image.git", from: "2.0.0"),
        .package(url: "https://github.com/SwiftGL/CGLFW3.git", from: "2.0.0"),
    ],
    targets: [
        .target(name: "example", dependencies: ["SGLMath", "SGLImage", "SGLOpenGL"], path: "."),
    ]
)
