# Verba — iOS

Un singur pachet SwiftPM care livrează **tot**: OTA/read la runtime, push (app→web) și fetch (web→app).
Adaugi pachetul, pui tokenii — atât. Nimic hardcodat per proiect: `project` + `locales` vin din `/manifest`
(tokenul identifică proiectul), serverul e în pachet (`https://verba.kred`).

## Instalare

```swift
.package(url: "https://github.com/IKristea/verba-ios.git", from: "1.1.0")
```

Adaugă produsul **`VerbaTranslations`** la target-ul app. Plugin-urile `VerbaPush` / `VerbaFetch` vin cu pachetul.

## 1. OTA / read (runtime)

Pornește la lansarea app-ului (serverul e în pachet; dă doar proiectul + tokenul READ):

```swift
import VerbaTranslations

// AppDelegate.didFinishLaunching
VerbaOta.start(project: "PROJECT_SLUG", token: readToken)   // read token (poți ține în Verba.xcconfig, gitignored)
// la revenirea în față:
VerbaOta.refresh()
```

Cârlig în managerul de localizare (o linie) — OTA întâi, altfel bundle-ul compilat:

```swift
if let ota = VerbaOta.get(language, key) { return ota }
return bundle.localizedString(forKey: key, value: value, table: table)
```

Live update SwiftUI (opțional): `@StateObject var verba = VerbaOtaObserver.shared` și referă `verba.version`.

## 2. Push (app→web) — plugin

Trimite `Localizable.strings` în Verba (creează chei noi, umple gol; **Verba câștigă** pe ce există;
cheile șterse în Verba **nu reînvie**). Apoi cere auto-translate pentru limbile lipsă.

- **Proiect Xcode** (rețeaua e blocată în plugin-urile Xcode): Run Script Build Phase, guarded, care cheamă binarul din artifacts SPM:
  ```sh
  [ "${VERBA_PUSH:-0}" = 1 ] || exit 0
  TOOL="$(find "${BUILD_DIR%/Build/*}/SourcePackages/artifacts" -name verba-push -type f 2>/dev/null | head -1)"
  cd "$SRCROOT"; "$TOOL"
  ```
  Declanșezi: build cu `VERBA_PUSH=1`.
- **Package SPM / CLI**: `VERBA_WRITE_TOKEN=... swift package --allow-network-connections all verba-push`

Tokenul WRITE: env `VERBA_WRITE_TOKEN` sau `VERBA_WRITE_TOKEN = ...` din `Verba.xcconfig`.
Directorul `.lproj`, `project`, `locales` — din `/manifest` (setate în Verba), altfel auto-descoperire.

## 3. Fetch (web→app)

Coboară traducerile și scrie `<locale>.lproj/Localizable.strings` (fallback offline la prima pornire).
La fel ca push: **Xcode** = Build Phase cu `verba-fetch` (guarded `VERBA_FETCH=1`); **SPM/CLI** =
`VERBA_TOKEN=... swift package --allow-writing-to-package-directory --allow-network-connections all verba-fetch`.

Tokenul READ: env `VERBA_TOKEN` sau `VERBA_READ_TOKEN`/`VERBA_TOKEN` din `Verba.xcconfig`.

## Config (opțional) — `verba.json`

Toate se pot lăsa pe seama `/manifest`. Pentru override (ex. self-host), `verba.json`:

```json
{ "server": "https://verba.kred", "project": "PROJECT_SLUG", "locales": ["en","ro","ru"], "outDir": "Localization" }
```

## Licență
MIT
