# VerbaTranslations (iOS)

Runtime OTA de traduceri pentru iOS — client [Verba](https://verba.kred).
Descarcă bundle-ul de traduceri la pornire/foreground și servește textele fără rebuild;
live update în SwiftUI prin `VerbaOtaObserver`. Distribuit **binar** (xcframework).

## Instalare (SwiftPM)
```swift
.package(url: "https://github.com/IKristea/verba-ios.git", from: "1.0.0")
```

## Utilizare
```swift
import VerbaTranslations

VerbaOta.start()                                   // config din verba_config.json (Bundle.main)
// sau: VerbaOta.start(server: "https://verba.kred", project: "evo-md", token: "<read-token>")
VerbaOta.refresh()                                 // la foreground
let s = VerbaOta.get("ro", "some_key")             // citire text

@StateObject private var verba = VerbaOtaObserver.shared   // live update SwiftUI
// ... RootView().id(verba.version)
```

## Licență
MIT
