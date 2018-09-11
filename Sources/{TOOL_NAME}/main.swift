import Foundation
import {TOOL_NAME}Kit
import SwiftCLI

// MARK: - CLI
let cli = CLI(name: "{TOOL_COMMAND}", version: "0.1.0", description: "TODO: Short description of your tool.")
cli.commands = [ExampleCommand()]
cli.globalOptions.append(contentsOf: GlobalOptions.all)
cli.goAndExit()
