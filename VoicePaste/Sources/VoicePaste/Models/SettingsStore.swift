import Foundation
import SwiftUI
import Security
import LaunchAtLogin

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    @AppStorage("autoPasteEnabled") var autoPasteEnabled: Bool = true
    @AppStorage("selectedModel") var selectedModel: String = "whisper-1"
    @AppStorage("launchAtLogin") private var launchAtLoginStored: Bool = true
    
    @Published var apiKey: String? {
        didSet {
            if let apiKey = apiKey {
                saveAPIKeyToKeychain(apiKey)
            }
        }
    }
    
    var launchAtLogin: Bool {
        get { LaunchAtLogin.isEnabled }
        set { LaunchAtLogin.isEnabled = newValue }
    }
    
    let availableModels = [
        "whisper-1"
    ]
    
    private let keychainService = "com.voicepaste.api"
    private let keychainAccount = "openai"
    
    private init() {
        // Load API key from keychain
        self.apiKey = loadAPIKeyFromKeychain()
        
        // Set initial launch at login state
        LaunchAtLogin.isEnabled = launchAtLoginStored
    }
    
    private func saveAPIKeyToKeychain(_ apiKey: String) {
        let data = apiKey.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Failed to save API key to keychain: \(status)")
        }
    }
    
    private func loadAPIKeyFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }
        
        return nil
    }
}