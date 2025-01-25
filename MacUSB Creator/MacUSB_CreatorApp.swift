//
//  MacUSB_CreatorApp.swift
//  MacUSB Creator by kingkwahli at macOS Utilities
//
import SwiftUI

@main
struct MacUSB_CreatorApp: App {
    @State private var commandOutput = ""
    @State private var commandOutputWindow: NSWindow?
    @State private var aboutWindow: NSWindow?

    var body: some Scene {
        WindowGroup {
            CreateInstallerView()
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button("About MacUSB Creator") {
                    showAboutWindow()
                }
            }
            CommandGroup(replacing: CommandGroupPlacement.help) {
                Button("MacUSB Creator Help") {
                    NSHelpManager.shared.openHelpAnchor("index", inBook: "MacUSBCreatorHelp")
                }
            }
            CommandMenu("Debugging") {
                Button("Show Command Output") {
                    showCommandOutputWindow()
                }
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }

    func showCommandOutputWindow() {
        if commandOutputWindow == nil {
            let visualEffectView = NSVisualEffectView()
            visualEffectView.material = .sidebar
            visualEffectView.blendingMode = .behindWindow
            visualEffectView.state = .active

            let hostingView = NSHostingView(rootView: CommandOutputView(commandOutput: $commandOutput))
            hostingView.frame = NSRect(x: 0, y: 0, width: 600, height: 400)

            commandOutputWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered, defer: false
            )
            commandOutputWindow?.title = "Command Output"
            commandOutputWindow?.isReleasedWhenClosed = false

            // Add the translucent background and the content view
            visualEffectView.frame = commandOutputWindow!.contentView!.bounds
            visualEffectView.autoresizingMask = [.width, .height]
            commandOutputWindow?.contentView?.addSubview(visualEffectView)
            commandOutputWindow?.contentView?.addSubview(hostingView)
        }
        commandOutputWindow?.makeKeyAndOrderFront(nil)
    }

    func showAboutWindow() {
        if aboutWindow == nil {
            aboutWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered, defer: false
            )
            aboutWindow?.title = "About MacUSB Creator"
            aboutWindow?.contentView = NSHostingView(rootView: AboutView())
            aboutWindow?.isReleasedWhenClosed = false
        }
        aboutWindow?.makeKeyAndOrderFront(nil)
    }
}

