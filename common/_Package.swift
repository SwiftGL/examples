import PackageDescription

let package = Package(
    name: "main",
    dependencies: [
        .Package(url: "https://github.com/SwiftGL/OpenGL.git", majorVersion: 1),
        .Package(url: "https://github.com/SwiftGL/Math.git", majorVersion: 1),
        .Package(url: "https://github.com/SwiftGL/Image.git", majorVersion: 1)
    ]
)

#if os(Linux)
    package.dependencies.append(
        Package.Dependency.Package(url: "https://github.com/SwiftGL/CGLFW3Linux.git", majorVersion: 1)
    )
#else
    package.dependencies.append(
        Package.Dependency.Package(url: "https://github.com/SwiftGL/CGLFW3.git", majorVersion: 1)
    )
#endif
