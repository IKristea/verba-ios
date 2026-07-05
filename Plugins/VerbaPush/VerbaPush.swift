import PackagePlugin
import Foundation

// Command plugin: push (app→web). Rulează binarul `verba-push` din pachet, cu directorul
// proiectului ca working dir → tool-ul găsește singur .lproj + tokenul WRITE (env VERBA_WRITE_TOKEN
// sau Verba.xcconfig). Merge din CLI (`swift package verba-push`) și din meniul Xcode.
@main
struct VerbaPush: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        try runVerba(tool: try context.tool(named: "verba-push").path,
                     workDir: context.package.directory, arguments: arguments)
    }
}

func runVerba(tool: Path, workDir: Path, arguments: [String]) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: tool.string)
    process.arguments = arguments
    process.currentDirectoryURL = URL(fileURLWithPath: workDir.string)
    process.environment = ProcessInfo.processInfo.environment
    try process.run()
    process.waitUntilExit()
    if process.terminationStatus != 0 {
        Diagnostics.error("verba-push a ieșit cu cod \(process.terminationStatus)")
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension VerbaPush: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        try runVerba(tool: try context.tool(named: "verba-push").path,
                     workDir: context.xcodeProject.directory, arguments: arguments)
    }
}
#endif
