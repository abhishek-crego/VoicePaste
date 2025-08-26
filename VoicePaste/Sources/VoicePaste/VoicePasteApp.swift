import SwiftUI
import AppKit
import KeyboardShortcuts

@main
struct VoicePasteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settingsStore = SettingsStore.shared
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var hotkeyManager: HotkeyManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from dock
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize components
        menuBarController = MenuBarController()
        hotkeyManager = HotkeyManager()
        
        // Request permissions if needed
        PermissionsManager.shared.requestMicrophonePermission()
        
        // Check accessibility permission
        if !PermissionsManager.shared.hasAccessibilityPermission() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.menuBarController?.showPermissionAlert()
            }
        }
    }
}

// Keyboard shortcut names
extension KeyboardShortcuts.Name {
    static let toggleRecording = Self("toggleRecording", default: .init(.r, modifiers: [.command, .shift]))
}