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
            url: "https://github.com/IKristea/verba-ios/releases/download/1.3.2/VerbaTranslations.xcframework.zip",
            checksum: "31227ff09dddec15d8c0ecbe0ab4027e479023fcbcd3f75d7bf7ea1782fe7e7b"
        ),
        // CLI-uri (macOS host tools) — rulate de plugin-uri
        .binaryTarget(
            name: "verba-push",
            url: "https://github.com/IKristea/verba-ios/releases/download/1.3.2/verba-push.artifactbundle.zip",
            checksum: "cb6ed377a21419553cfe50d23cbf65bdff89f00007d9ef8a5547c0927f9cef1c"
        ),
        .binaryTarget(
            name: "verba-fetch",
            url: "https://github.com/IKristea/verba-ios/releases/download/1.3.2/verba-fetch.artifactbundle.zip",
            checksum: "a8e68ad3c0862556e30859615646788e5474e09fcadec4999b70e879a6404eb3"
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
