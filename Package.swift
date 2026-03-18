// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PhonePeKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "PhonePeKit", targets: ["PhonePeKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.20.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "5.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(name: "PhonePeKit", dependencies: [
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
            .product(name: "Crypto", package: "swift-crypto"),
        ]),
        .testTarget(name: "PhonePeKitTests", dependencies: [
            .target(name: "PhonePeKit")
        ])
    ]
)
