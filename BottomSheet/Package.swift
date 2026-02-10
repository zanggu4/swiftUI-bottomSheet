// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "BottomSheet",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "BottomSheet", targets: ["BottomSheet"]),
    ],
    targets: [
        .target(
            name: "BottomSheet",
            resources: [
                .process("Resources"),
            ],
        ),
    ],
)
