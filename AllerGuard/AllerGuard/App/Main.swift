// This is a special file in Swift
// It contains the app's main entry point via the main() function
// instead of using the @main attribute

import SwiftUI

// Using UIApplicationMain/NSApplicationMain for Swift 5.3+ compatibility
// This avoids the 'main attribute cannot be used in a module that contains top-level code' error
@_cdecl("main")
func mainFunction() -> Int32 {
    #if os(iOS)
    UIApplicationMain(
        CommandLine.argc,
        CommandLine.unsafeArgv,
        nil,
        NSStringFromClass(AppDelegate.self)
    )
    #elseif os(macOS)
    NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    #endif
    return 0
} 