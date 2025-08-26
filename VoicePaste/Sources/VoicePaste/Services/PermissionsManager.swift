import Foundation
import AVFoundation
import AppKit

class PermissionsManager {
    static let shared = PermissionsManager()
    
    private init() {}
    
    func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if !granted {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .errorOccurred,
                        object: nil,
                        userInfo: ["message": "Microphone permission is required for recording"]
                    )
                }
            }
        }
    }
    
    func hasMicrophonePermission() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }
    
    func hasAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options)
    }
    
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options)
    }
    
    func openSystemPreferences(to pane: SystemPreferencePane) {
        var urlString = ""
        
        switch pane {
        case .microphone:
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"
        case .accessibility:
            urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        }
        
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    enum SystemPreferencePane {
        case microphone
        case accessibility
    }
}