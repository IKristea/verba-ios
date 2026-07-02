// swift-tools-version:5.9
import PackageDescription

// Distribuție BINARĂ: sursa clientului rămâne privată; aici doar manifestul + binaryTarget.
// xcframework-ul e atașat ca asset pe GitHub Release-ul acestui repo.
let package = Package(
    name: "VerbaTranslations",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "VerbaTranslations", targets: ["VerbaTranslations"]),
    ],
    targets: [
        .binaryTarget(
            name: "VerbaTranslations",
            url: "https://github.com/IKristea/verba-ios/releases/download/1.0.1/VerbaTranslations.xcframework.zip",
            checksum: "1a81efbb743680bf112eeb4dc662ef0d4ee64712dbf5da393fc2fd034e4c5688"
        ),
    ]
)
