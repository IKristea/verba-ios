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
            url: "https://github.com/IKristea/verba-ios/releases/download/1.2.0/VerbaTranslations.xcframework.zip",
            checksum: "7aaf775c91a9a641fb630c413d77fd88eea2c98c6321c0185fec7a3815fd11f5"
        ),
        // CLI-uri (macOS host tools) — rulate de plugin-uri
        .binaryTarget(
            name: "verba-push",
            url: "https://github.com/IKristea/verba-ios/releases/download/1.2.0/verba-push.artifactbundle.zip",
            checksum: "e907b2b7fd0e5cf22646c8e23cdb4f228f52c5e1c212ca570147964115835f4e"
        ),
        .binaryTarget(
            name: "verba-fetch",
            url: "https://github.com/IKristea/verba-ios/releases/download/1.2.0/verba-fetch.artifactbundle.zip",
            checksum: "7598bac413fe763b4d08b6298fece196966362bcafac54bfc2051e17c3002f46"
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
