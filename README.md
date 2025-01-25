![musbheader](https://github.com/user-attachments/assets/198c0618-c404-41da-a921-e71792a103ef)


**MacUSB Creator** is a simple, intuitive macOS application for creating bootable macOS installer USB drives. It supports macOS **11.5 (Big Sur)** and higher, with future support for macOS **10.15 (Catalina)** coming soon.

## Features
- **Create Bootable Installers:** Quickly create bootable macOS installers for supported macOS versions.
- **Progress Feedback:** Provides real-time feedback with a progress bar and status updates during the creation process.
- **Customizable UI:** Built with SwiftUI for a modern macOS look and feel.
- **Command Output:** Includes an optional Command Output window for debugging and viewing raw command output.

## Requirements
- macOS **11.5 (Big Sur)** or later.
- A USB drive with at least **16GB** of available space.
- An 'Install macOS'.app

### (maybe) Coming Soon
- Support for macOS **10.15 (Catalina)**.
- Integrated macOS installer downloader.

## How to Use
1. Download the latest **MacUSB Creator** DMG from Releases
2. Drag the .app to Downloads
3. If your Mac prevents the app from opening due to it being unsigned:
   - **macOS Sequoia or higher**:
     - Go to **System Settings > Privacy & Security > Open Anyway**.
     - Click **Open Anyway** and enter your password
   - **macOS Sonoma or lower**:
     -  Hold down Option/Alt on your keyboard
     -  Right-click the .app
     -  Click on Open
4. Launch the app and follow these steps:
   - Use the **Browse** button to select your macOS installer.
   - Select a compatible USB drive (16GB or larger).
   - Click **Create Installer** to begin the process.

### Unsigned App Note
This app is **unsigned** and may trigger macOS Gatekeeper. Follow the instructions above to bypass Gatekeeper and run the app.

## Build Details
- **Language:** Swift
- **Framework:** SwiftUI
- **Compatibility:** macOS 11.5+ (Big Sur)
- **Status:** Release

## Feedback
Found a bug or have a feature request? Feel free to open an issue on this repository or email `kwahli@naazimapps.com` for support.

---

**Disclaimer:** This app is provided "as-is" without warranty of any kind. Use at your own risk.
