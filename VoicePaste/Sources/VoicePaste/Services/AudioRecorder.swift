import Foundation
import AVFoundation

class AudioRecorder: NSObject {
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var recordingTimer: Timer?
    private let maxRecordingDuration: TimeInterval = 120.0
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        // Note: AVAudioSession is iOS only, on macOS we use AVAudioEngine directly
    }
    
    func startRecording(completion: @escaping (Bool) -> Void) {
        // Request microphone permission if needed
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            guard granted else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            self?.startRecordingInternal(completion: completion)
        }
    }
    
    private func startRecordingInternal(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }
            
            do {
                // Create audio engine
                self.audioEngine = AVAudioEngine()
                guard let audioEngine = self.audioEngine else {
                    completion(false)
                    return
                }
                
                let inputNode = audioEngine.inputNode
                let recordingFormat = AVAudioFormat(
                    commonFormat: .pcmFormatFloat32,
                    sampleRate: 16000,
                    channels: 1,
                    interleaved: false
                )!
                
                // Create temp file for recording
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "recording_\(Date().timeIntervalSince1970).wav"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                self.audioFile = try AVAudioFile(
                    forWriting: fileURL,
                    settings: recordingFormat.settings
                )
                
                // Install tap
                inputNode.installTap(
                    onBus: 0,
                    bufferSize: 1024,
                    format: recordingFormat
                ) { [weak self] buffer, _ in
                    guard let audioFile = self?.audioFile else { return }
                    try? audioFile.write(from: buffer)
                }
                
                // Start engine
                try audioEngine.start()
                
                // Set up max duration timer
                self.recordingTimer = Timer.scheduledTimer(
                    withTimeInterval: self.maxRecordingDuration,
                    repeats: false
                ) { [weak self] _ in
                    self?.stopRecording { _ in
                        // Notify that recording was auto-stopped
                        NotificationCenter.default.post(
                            name: .errorOccurred,
                            object: nil,
                            userInfo: ["message": "Recording stopped: 120 second limit reached"]
                        )
                    }
                }
                
                completion(true)
            } catch {
                print("Failed to start recording: \(error)")
                completion(false)
            }
        }
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            // Cancel timer
            self.recordingTimer?.invalidate()
            self.recordingTimer = nil
            
            // Stop audio engine
            if let audioEngine = self.audioEngine {
                audioEngine.inputNode.removeTap(onBus: 0)
                audioEngine.stop()
            }
            
            // Return file URL
            let fileURL = self.audioFile?.url
            self.audioFile = nil
            self.audioEngine = nil
            
            completion(fileURL)
        }
    }
}