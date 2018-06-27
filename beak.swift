// beak: Flinesoft/HandySwift @ .upToNextMajor(from: "2.6.0")
// beak: onevcat/Rainbow @ .upToNextMajor(from: "3.0.3")

import Foundation
import HandySwift
import Rainbow

// MARK: - Print Helpers
private enum PrintLevel {
    case info
    case warning
    case error
}

private func print(_ message: String, level: PrintLevel) {
    switch level {
    case .info:
        print("ℹ️ ", message.lightBlue)

    case .warning:
        print("⚠️ ", message.yellow)

    case .error:
        print("❌ ", message.red)
    }
}


// MARK: - Command Helpers
typealias CommandResult = (output: String?, error: String?, exitCode: Int32)

@discardableResult
func run(_ command: String) -> CommandResult {
    let commandComponents = command.components(separatedBy: .whitespaces)

    let commandLineTask = Process()
    commandLineTask.launchPath = "/usr/bin/env"
    commandLineTask.arguments = commandComponents

    let outputPipe = Pipe()
    commandLineTask.standardOutput = outputPipe
    let errorPipe = Pipe()
    commandLineTask.standardError = errorPipe

    commandLineTask.launch()

    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    let error = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .newlines)

    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .newlines)

    commandLineTask.waitUntilExit()
    let exitCode = commandLineTask.terminationStatus

    return (output, error, exitCode)
}

// MARK: - GitHub Helpers
let semanticVersionRegex = try Regex("(\\d+)\\.(\\d+)\\.(\\d+)\\s")

struct SemanticVersion: Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let patch: Int

    init(_ string: String) {
        guard let captures = semanticVersionRegex.firstMatch(in: string)?.captures else {
            fatalError("SemanticVersion initializer was used without checking the structure.")
        }

        major = Int(captures[0]!)!
        minor = Int(captures[1]!)!
        patch = Int(captures[2]!)!
    }

    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        guard lhs.major == rhs.major else { return lhs.major < rhs.major }
        guard lhs.minor == rhs.minor else { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }

    static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }

    var description: String {
        return "\(major).\(minor).\(patch)"
    }
}

func fetchGitHubLatestVersion(subpath: String) -> SemanticVersion {
    let tagListCommand = "git ls-remote --tags https://github.com/\(subpath).git"
    let commandOutput = run(tagListCommand).output!
    let availableSemanticVersions = semanticVersionRegex.matches(in: commandOutput).map { SemanticVersion($0.string) }
    guard !availableSemanticVersions.isEmpty else {
        print("Dependency '\(subpath)' has no tagged versions.", level: .error)
        fatalError()
    }
    return availableSemanticVersions.sorted().last!
}

func fetchGitHubTagline(subpath: String) throws -> String? {
    let taglineRegex = try Regex("<title>[^\\:]+\\: (.*)<\\/title>")
    let url = URL(string: "https://github.com/\(subpath)")!
    let html = try String(contentsOf: url, encoding: .utf8)
    guard let firstMatch = taglineRegex.firstMatch(in: html) else { return nil }
    guard let firstCapture = firstMatch.captures.first else { return nil }
    return firstCapture!
}

// MARK: - SPM Helpers
extension SemanticVersion {
    var recommendedVersionSpecifier: String {
        guard major >= 1 else { return ".upToNextMinor(\(description)" }
        return ".upToNextMajor(\(description))"
    }
}

func renameTool(to newName: String) {
    // TODO: not yet implemented
}

func sortDependencies() {
    // TODO: not yet implemented
}

func appendDependencyToPackageFile(tagline: String?, githubSubpath: String, version: SemanticVersion) {
    // TODO: not yet implemented
}

func initializeLicenseFile() {
    // TODO: not yet implemented
}

func initializeReadMe() {
    // TODO: not yet implemented
}

// MARK: - Beak Commands
/// Initializes the command line tool.
public func initialize(toolName: String) {
    run("swift package init --type executable")
    makeEditable()
    renameTool(to: toolName)
    initializeLicenseFile()
    initializeReadMe()
}


/// Prepares project for editing using Xcode with all dependencies configured.
public func makeEditable() {
    run("swift package generate-xcodeproj")
//    run("swift package fetch")
}

/// Adds a new dependency hosted on GitHub with most current version and recommended update path preconfigured.
public func addDependency(github githubSubpath: String, version: String = "latest") throws {
    let tagline = try fetchGitHubTagline(subpath: githubSubpath)
    let latestVersion = fetchGitHubLatestVersion(subpath: githubSubpath)
    appendDependencyToPackageFile(tagline: tagline, githubSubpath: githubSubpath, version: latestVersion)
    sortDependencies()
//    run("swift package fetch")
}
