import PackagePlugin
import Foundation

// Command plugin: fetch (web→app). Rulează binarul `verba-fetch` din pachet, cu directorul
// proiectului ca working dir → scrie <locale>.lproj/Localizable.strings. Tokenul READ din
// env VERBA_TOKEN sau Verba.xcconfig. Merge din CLI și din meniul Xcode.
@main
struct VerbaFetch: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        try runVerbaFetch(tool: try context.tool(named: "verba-fetch").path,
                          workDir: context.package.directory, arguments: arguments)
    }
}

func runVerbaFetch(tool: Path, workDir: Path, arguments: [String]) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: tool.string)
    process.arguments = arguments
    process.currentDirectoryURL = URL(fileURLWithPath: workDir.string)
    process.environment = ProcessInfo.processInfo.environment
    try process.run()
    process.waitUntilExit()
    if process.terminationStatus != 0 {
        Diagnostics.error("verba-fetch a ieșit cu cod \(process.terminationStatus)")
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension VerbaFetch: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        try runVerbaFetch(tool: try context.tool(named: "verba-fetch").path,
                          workDir: context.xcodeProject.directory, arguments: arguments)
    }
}
#endif
