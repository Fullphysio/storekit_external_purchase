// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "storekit_external_purchase",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "storekit-external-purchase", targets: ["storekit_external_purchase"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "storekit_external_purchase",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
