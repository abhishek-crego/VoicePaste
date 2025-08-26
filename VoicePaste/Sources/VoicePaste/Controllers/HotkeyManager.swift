import Foundation
import KeyboardShortcuts
import AppKit

class HotkeyManager: NSObject {
    private let audioRecorder = AudioRecorder()
    private let transcriptionClient = TranscriptionClient()
    private let pasteService = PasteService()
    private var isRecording = false
    
    override init() {
        super.init()
        setupHotkeys()
        setupKeyMonitor()
        
        // Listen for test recording
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTestRecording),
            name: .testRecording,
            object: nil
        )
    }
    
    @objc private func handleTestRecording() {
        toggleRecording()
    }
    
    private func setupHotkeys() {
        KeyboardShortcuts.onKeyUp(for: .toggleRecording) { [weak self] in
            self?.toggleRecording()
        }
    }
    
    private func setupKeyMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard self?.isRecording == true else { return event }
            
            // Check for Enter key (return key)
            if event.keyCode == 36 { // 36 is the keycode for Enter/Return
                self?.stopRecordingAndTranscribe()
                return nil // Consume the event
            }
            
            return event
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecordingAndTranscribe()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        guard !isRecording else { return }
        
        isRecording = true
        
        // Notify UI
        NotificationCenter.default.post(
            name: .recordingStateChanged,
            object: nil,
            userInfo: ["isRecording": true]
        )
        
        // Play start beep
        NSSound.beep()
        
        // Start recording
        audioRecorder.startRecording { [weak self] success in
            if !success {
                self?.handleError("Failed to start recording")
                self?.isRecording = false
                NotificationCenter.default.post(
                    name: .recordingStateChanged,
                    object: nil,
                    userInfo: ["isRecording": false]
                )
            }
        }
    }
    
    private func stopRecordingAndTranscribe() {
        guard isRecording else { return }
        
        isRecording = false
        
        // Notify UI
        NotificationCenter.default.post(
            name: .recordingStateChanged,
            object: nil,
            userInfo: ["isRecording": false]
        )
        
        // Play stop beep
        NSSound.beep()
        
        // Stop recording and get audio file
        audioRecorder.stopRecording { [weak self] audioURL in
            guard let self = self, let audioURL = audioURL else {
                self?.handleError("Failed to save recording")
                return
            }
            
            // Transcribe
            Task {
                do {
                    let text = try await self.transcriptionClient.transcribe(audioURL: audioURL)
                    
                    // Delete temp audio file
                    try? FileManager.default.removeItem(at: audioURL)
                    
                    // Handle transcribed text
                    await MainActor.run {
                        self.handleTranscribedText(text)
                    }
                } catch {
                    await MainActor.run {
                        self.handleError("Transcription failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func handleTranscribedText(_ text: String) {
        guard !text.isEmpty else {
            handleError("No text was transcribed")
            return
        }
        
        // Copy to clipboard
        pasteService.copyToClipboard(text)
        
        // Auto-paste if enabled
        if SettingsStore.shared.autoPasteEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.pasteService.performPaste()
            }
        }
    }
    
    private func handleError(_ message: String) {
        NotificationCenter.default.post(
            name: .errorOccurred,
            object: nil,
            userInfo: ["message": message]
        )
    }
}

extension Notification.Name {
    static let errorOccurred = Notification.Name("errorOccurred")
}