import Foundation
import AppKit
import CoreGraphics

class PasteService {
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    func performPaste() {
        // Check if we have accessibility permission
        guard PermissionsManager.shared.hasAccessibilityPermission() else {
            NotificationCenter.default.post(
                name: .errorOccurred,
                object: nil,
                userInfo: ["message": "Accessibility permission required for auto-paste"]
            )
            return
        }
        
        // Create and send ⌘V key event
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Key down event
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true) // 0x09 is 'V'
        keyDown?.flags = .maskCommand
        
        // Key up event
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand
        
        // Post events
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}