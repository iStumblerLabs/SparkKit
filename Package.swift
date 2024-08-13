// swift-tools-version:5.10

import PackageDescription

let package = Package(
	name: "SparkKit",
    platforms: [.macOS(.v10_14), .iOS(.v14), .tvOS(.v14)],
	products: [
		.library( name: "SparkKit", targets: ["SparkKit"])
	],
    dependencies: [
        .package( url: "https://github.com/iStumblerLabs/KitBridge.git", from: "1.3.2")
    ],
    targets: [
        .target( name: "SparkKit", dependencies: ["KitBridge"])
    ]
)
