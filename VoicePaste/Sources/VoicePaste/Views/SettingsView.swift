import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @StateObject private var settingsStore = SettingsStore.shared
    @State private var apiKeyInput: String = ""
    @State private var showAPIKey = false
    @State private var errorMessage: String?
    @State private var micPermissionGranted = false
    @State private var accessibilityPermissionGranted = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "mic.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Text("VoicePaste")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            
            // Error banner
            if let errorMessage = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.caption)
                        .lineLimit(2)
                    Spacer()
                    Button(action: { self.errorMessage = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Shortcut Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Recording Shortcut", systemImage: "keyboard")
                                .font(.headline)
                            
                            KeyboardShortcuts.Recorder("", name: .toggleRecording)
                            
                            Text("Press to start recording, press Enter to stop")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // OpenAI Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("OpenAI Configuration", systemImage: "brain")
                                .font(.headline)
                            
                            // API Key
                            VStack(alignment: .leading, spacing: 4) {
                                Text("API Key")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    if showAPIKey {
                                        TextField("sk-...", text: $apiKeyInput)
                                            .textFieldStyle(.roundedBorder)
                                            .onAppear {
                                                apiKeyInput = settingsStore.apiKey ?? ""
                                            }
                                    } else {
                                        SecureField("sk-...", text: $apiKeyInput)
                                            .textFieldStyle(.roundedBorder)
                                            .onAppear {
                                                apiKeyInput = settingsStore.apiKey ?? ""
                                            }
                                    }
                                    
                                    Button(action: { showAPIKey.toggle() }) {
                                        Image(systemName: showAPIKey ? "eye.slash" : "eye")
                                    }
                                    
                                    Button("Save") {
                                        settingsStore.apiKey = apiKeyInput
                                    }
                                    .disabled(apiKeyInput.isEmpty)
                                }
                            }
                            
                            // Model Selection
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Transcription Model")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("", selection: $settingsStore.selectedModel) {
                                    ForEach(settingsStore.availableModels, id: \.self) { model in
                                        Text(model).tag(model)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Behavior Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Behavior", systemImage: "gearshape")
                                .font(.headline)
                            
                            Toggle("Auto-paste after transcription", isOn: $settingsStore.autoPasteEnabled)
                            
                            Toggle("Launch at login", isOn: Binding(
                                get: { settingsStore.launchAtLogin },
                                set: { settingsStore.launchAtLogin = $0 }
                            ))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Permissions Section
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Permissions", systemImage: "lock.shield")
                                .font(.headline)
                            
                            // Microphone Permission
                            HStack {
                                Image(systemName: micPermissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(micPermissionGranted ? .green : .red)
                                Text("Microphone Access")
                                Spacer()
                                if !micPermissionGranted {
                                    Button("Grant") {
                                        PermissionsManager.shared.openSystemPreferences(to: .microphone)
                                    }
                                    .buttonStyle(.link)
                                }
                            }
                            
                            // Accessibility Permission
                            HStack {
                                Image(systemName: accessibilityPermissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(accessibilityPermissionGranted ? .green : .red)
                                Text("Accessibility Access")
                                Spacer()
                                if !accessibilityPermissionGranted {
                                    Button("Grant") {
                                        PermissionsManager.shared.requestAccessibilityPermission()
                                    }
                                    .buttonStyle(.link)
                                }
                            }
                            
                            Text("Required for auto-paste functionality")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Test Button
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Test Recording", systemImage: "waveform")
                                .font(.headline)
                            
                            Button(action: testRecording) {
                                Label("Start Test Recording", systemImage: "mic.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .frame(maxWidth: .infinity)
                            
                            Text("Click to test recording without using the shortcut")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            
            // Footer
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                
                Spacer()
                
                Text("v1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 360, height: 480)
        .onAppear {
            checkPermissions()
            setupNotificationObservers()
        }
    }
    
    private func checkPermissions() {
        micPermissionGranted = PermissionsManager.shared.hasMicrophonePermission()
        accessibilityPermissionGranted = PermissionsManager.shared.hasAccessibilityPermission()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .errorOccurred,
            object: nil,
            queue: .main
        ) { notification in
            if let message = notification.userInfo?["message"] as? String {
                self.errorMessage = message
            }
        }
    }
    
    private func testRecording() {
        // Trigger recording manually
        NotificationCenter.default.post(name: .testRecording, object: nil)
    }
}

extension Notification.Name {
    static let testRecording = Notification.Name("testRecording")
}