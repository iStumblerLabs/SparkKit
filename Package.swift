// swift-tools-version:5.0

import PackageDescription

let package = Package(
	name: "SparkKit",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v10),
        .tvOS(.v10)
    ],
	products: [
		.library(
			name: "SparkKit",
			targets: ["SparkKit"]
		)
	],
    dependencies: [
        .package(
            url: "https://github.com/iStumblerLabs/KitBridge.git",
            from: "1.2.1"
        )
    ],
    targets: [
        .target(
            name: "SparkKit",
            dependencies: ["KitBridge"],
            path: "SparkKit"
        )
    ]
)
