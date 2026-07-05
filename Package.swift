// swift-tools-version:5.9
import PackageDescription

// Distribuție BINARĂ: sursa clientului rămâne privată; aici doar manifestul + binaryTarget-uri
// (xcframework runtime + artifactbundle-uri CLI) atașate ca assets pe GitHub Release.
//
// Un singur pachet livrează TOT:
//   • library `VerbaTranslations`  -> OTA/read la runtime (VerbaOta.start/get/refresh)
//   • plugin  `VerbaPush`          -> push (app→web): trimite Localizable.strings în Verba
//   • plugin  `VerbaFetch`         -> fetch (web→app): scrie <locale>.lproj din Verba
let package = Package(
    name: "VerbaTranslations",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(name: "VerbaTranslations", targets: ["VerbaTranslations"]),
        .plugin(name: "VerbaPush", targets: ["VerbaPush"]),
        .plugin(name: "VerbaFetch", targets: ["VerbaFetch"]),
    ],
    targets: [
        // runtime OTA (iOS)
        .binaryTarget(
            name: "VerbaTranslations",
            url: "https://github.com/IKristea/verba-ios/releases/download/1.1.0/VerbaTranslations.xcframework.zip",
            checksum: "1a81efbb743680bf112eeb4dc662ef0d4ee64712dbf5da393fc2fd034e4c5688"
        ),
        // CLI-uri (macOS host tools) — rulate de plugin-uri
        .binaryTarget(
            name: "verba-push",
            url: "https://github.com/IKristea/verba-ios/releases/download/1.1.0/verba-push.artifactbundle.zip",
            checksum: "9439df7b8d82d473876acc0953ccd1b2c16f7f4b3cffc926ae7d5109047bc41f"
        ),
        .binaryTarget(
            name: "verba-fetch",
            url: "https://github.com/IKristea/verba-ios/releases/download/1.1.0/verba-fetch.artifactbundle.zip",
            checksum: "db757efac09d64977c8954dbd1bb62b1731f1f948b04cee9a8ef857ee6a34088"
        ),
        // push (app→web): cheia WRITE din env VERBA_WRITE_TOKEN sau Verba.xcconfig
        .plugin(
            name: "VerbaPush",
            capability: .command(
                intent: .custom(verb: "verba-push", description: "Trimite traducerile (Localizable.strings) în Verba (app→web)."),
                permissions: [
                    .allowNetworkConnections(scope: .all(ports: []), reason: "Trimite valorile la serverul Verba și cere auto-translate.")
                ]
            ),
            dependencies: ["verba-push"]
        ),
        // fetch (web→app): cheia READ din env VERBA_TOKEN sau Verba.xcconfig
        .plugin(
            name: "VerbaFetch",
            capability: .command(
                intent: .custom(verb: "verba-fetch", description: "Aduce traducerile din Verba și scrie <locale>.lproj (web→app)."),
                permissions: [
                    .allowNetworkConnections(scope: .all(ports: []), reason: "Descarcă traducerile din serverul Verba."),
                    .writeToPackageDirectory(reason: "Scrie <locale>.lproj/Localizable.strings.")
                ]
            ),
            dependencies: ["verba-fetch"]
        ),
    ]
)
