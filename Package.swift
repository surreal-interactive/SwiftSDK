// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SurrealTouchSDK",
    
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SurrealTouchSDK",
            targets: ["SurrealInteractiveSDK"]),
    ],
    dependencies: [
        .package(path: "xcframework"),
    ],
    targets: [
        .target(name: "SurrealInteractiveSDK",
                dependencies:[
                    .product(name:"openxr-framework", package:"xcframework")
                ],
                cSettings: [],
                linkerSettings:[
                    .unsafeFlags(["-lc++"])
                ]
               )
    ]
)
