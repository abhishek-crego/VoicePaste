import SwiftUI
import AppKit

class MenuBarController: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    @Published var isRecording = false
    
    override init() {
        super.init()
        setupMenuBar()
        
        // Subscribe to recording state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(recordingStateChanged(_:)),
            name: .recordingStateChanged,
            object: nil
        )
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            updateIcon(isRecording: false)
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 360, height: 480)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: SettingsView())
    }
    
    private func updateIcon(isRecording: Bool) {
        guard let button = statusItem?.button else { return }
        
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        
        if isRecording {
            button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "Recording")?
                .withSymbolConfiguration(config)
            button.image?.isTemplate = false
            // Tint red when recording
            button.contentTintColor = .systemRed
        } else {
            button.image = NSImage(systemSymbolName: "mic", accessibilityDescription: "Not Recording")?
                .withSymbolConfiguration(config)
            button.image?.isTemplate = true
            button.contentTintColor = nil
        }
    }
    
    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    @objc private func recordingStateChanged(_ notification: Notification) {
        if let isRecording = notification.userInfo?["isRecording"] as? Bool {
            DispatchQueue.main.async {
                self.isRecording = isRecording
                self.updateIcon(isRecording: isRecording)
            }
        }
    }
    
    func showPermissionAlert() {
        DispatchQueue.main.async {
            guard let button = self.statusItem?.button else { return }
            self.popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}

extension Notification.Name {
    static let recordingStateChanged = Notification.Name("recordingStateChanged")
}