// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "surreal-interactive-openxr-framework", // You can name it after your framework
    products: [
        .library(
            name: "openxr-framework",
            targets: ["framework"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "framework",
            path: "surreal_interactive_openxr_framework.xcframework"
        ),
    ]
)

