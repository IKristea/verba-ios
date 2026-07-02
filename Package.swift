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
            url: "https://github.com/IKristea/verba-ios/releases/download/1.0.0/VerbaTranslations.xcframework.zip",
            checksum: "e403591a7c3cfac3d10ba1d0470a0805c901e133005d029198ab30f8d4c24373"
        ),
    ]
)
