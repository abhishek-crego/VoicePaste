# VoicePaste

A macOS menu bar app for voice-to-text transcription using OpenAI's Whisper API.

## Features

- 🎙️ **Quick Recording**: Press a global hotkey to start/stop recording
- 📝 **Instant Transcription**: Converts speech to text using OpenAI's Whisper API
- 📋 **Auto-Paste**: Automatically pastes transcribed text at cursor position
- ⚙️ **Customizable**: Configure shortcuts, models, and behavior
- 🔒 **Secure**: API keys stored in macOS Keychain
- 🚀 **Launch at Login**: Optionally start with your Mac

## Requirements

- macOS 13.0 or later
- OpenAI API key
- Microphone permission
- Accessibility permission (for auto-paste)

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/voicepaste.git
cd voicepaste
```

2. Build the app:
```bash
chmod +x build.sh
./build.sh
```

3. Move the app to Applications:
```bash
cp -r VoicePaste.app /Applications/
```

4. Open the app:
```bash
open /Applications/VoicePaste.app
```

## Setup

1. **API Key**: Click the menu bar icon and enter your OpenAI API key
2. **Permissions**: Grant microphone and accessibility permissions when prompted
3. **Shortcut**: Set your preferred recording shortcut (default: ⌘⇧R)

## Usage

1. Press your configured shortcut to start recording
2. Speak your text
3. Press Enter to stop recording and transcribe
4. Text is automatically pasted at your cursor position

### Recording Limits
- Maximum recording duration: 120 seconds
- Audio format: 16kHz mono PCM

## Configuration

Access settings by clicking the menu bar icon:

- **Recording Shortcut**: Customize the global hotkey
- **Auto-paste**: Toggle automatic pasting after transcription
- **Transcription Model**: Select OpenAI model (default: whisper-1)
- **Launch at Login**: Start VoicePaste with your Mac

## Permissions

VoicePaste requires:

- **Microphone Access**: For recording audio
- **Accessibility Access**: For simulating ⌘V keystroke

Grant permissions in System Preferences > Security & Privacy

## Development

### Project Structure

```
VoicePaste/
├── Sources/VoicePaste/
│   ├── VoicePasteApp.swift       # Main app entry
│   ├── Controllers/
│   │   ├── MenuBarController.swift
│   │   └── HotkeyManager.swift
│   ├── Services/
│   │   ├── AudioRecorder.swift
│   │   ├── TranscriptionClient.swift
│   │   ├── PasteService.swift
│   │   └── PermissionsManager.swift
│   ├── Models/
│   │   └── SettingsStore.swift
│   ├── Views/
│   │   └── SettingsView.swift
│   └── Resources/
│       └── Info.plist
├── Package.swift
└── VoicePaste.entitlements
```

### Dependencies

- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Global hotkey handling
- [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin-Modern) - Launch at login support

### Building for Distribution

To notarize the app for distribution:

1. Sign with Developer ID:
```bash
codesign --force --deep --sign "Developer ID Application: Your Name" VoicePaste.app
```

2. Create DMG and notarize (requires Apple Developer account)

## Troubleshooting

### App doesn't appear in menu bar
- Check if the app is running in Activity Monitor
- Restart the app

### Recording doesn't start
- Check microphone permissions in System Preferences
- Ensure no other app is using the microphone exclusively

### Auto-paste doesn't work
- Grant Accessibility permission in System Preferences
- Some apps may block synthetic keystrokes

### API errors
- Verify your OpenAI API key is correct
- Check your API usage limits
- Ensure you have network connectivity

## Privacy

- Audio recordings are temporary and deleted after transcription
- API keys are stored securely in macOS Keychain
- No telemetry or usage data is collected

## License

MIT License - See LICENSE file for details

## Support

For issues or feature requests, please open an issue on GitHub.