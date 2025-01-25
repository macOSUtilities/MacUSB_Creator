//
//  CreateInstallerView.swift
//  MacUSB Creator by kingkwahli at macOS Utilities
//
import SwiftUI
import AppKit
import DiskArbitration

struct CreateInstallerView: View {
    @State private var commandOutput = ""
    @State private var installerPath: String = ""
    @State private var selectedDrive: String = ""
    @State private var drives: [String] = []
    @State private var isProcessing: Bool = false
    @State private var progress: Double = 0.0
    @State private var statusMessage: String = "Waiting to start..."
    @State private var isHovering: Bool = false
    
    var body: some View {
        ZStack {
            VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow)
            
            VStack(spacing: 20) {
                Text("Create Bootable macOS Installer")
                    .font(.largeTitle)
                    .bold()
                
                HStack {
                    Button("Browse") {
                        browseForInstaller()
                    }
                    
                    TextField("Path to macOS Installer", text: $installerPath)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 510)
                }
                
                HStack {
                    Picker("Select Target USB Drive (16GB minimum)", selection: $selectedDrive) {
                        let allDrives = fetchDrivesUsingIOKit()
                        if drives.isEmpty {
                            if allDrives.isEmpty {
                                Text("No external drives found").tag("")
                            } else {
                                Text("No drives meet the size requirement (8GB minimum)").tag("")
                            }
                        } else {
                            ForEach(drives, id: \.self) { drive in
                                Text(drive).tag(drive)
                            }
                        }
                    }
                    .frame(width: 540)
                    Button(action: {
                        DispatchQueue.global(qos: .userInitiated).async {
                            let detectedDrives = fetchDrivesUsingIOKit()
                            DispatchQueue.main.async {
                                self.drives = detectedDrives
                                if !drives.contains(selectedDrive) {
                                    selectedDrive = drives.first ?? ""
                                }
                            }
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                Button(action: runCreateInstallMedia) {
                    Text("Create Installer")
                        .font(.title2)
                        .frame(width: 240, height: 50)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .onHover { hovering in
                            isHovering = hovering
                        }
                }
                .disabled(isProcessing || installerPath.isEmpty || selectedDrive.isEmpty)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(statusMessage)
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 600)
                        .padding(.top, 5)
                }
                
                .frame(width: 620, height: 60)
                .background(VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow))
                .cornerRadius(8)
                .shadow(radius: 4)
                .onAppear {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let detectedDrives = fetchDrivesUsingIOKit()
                        DispatchQueue.main.async {
                            self.drives = detectedDrives
                            if !drives.contains(selectedDrive) {
                                selectedDrive = drives.first ?? ""
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Helper Functions
    func parseCommandOutput(_ output: String) {
        if output.contains("Erasing disk") {
            progress = 0.1
            statusMessage = "Erasing drive..."
        } else if output.contains("Copying to disk") {
            progress = 0.5
            statusMessage = "Copying installer files..."
        } else if output.contains("Making disk bootable") {
            progress = 0.8
            statusMessage = "Making disk bootable..."
        } else if output.contains("Complete") {
            progress = 1.0
            statusMessage = "Complete! Bootable installer created."
        }
    }
    
    func browseForInstaller() {
        let dialog = NSOpenPanel()
        dialog.title = "Select macOS Installer"
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        
        if #available(macOS 12.0, *) {
            dialog.allowedContentTypes = [.application]
        } else {
            dialog.allowedFileTypes = ["app"]
        }
        
        if dialog.runModal() == .OK {
            if let result = dialog.url {
                installerPath = result.path
            }
        }
    }
    
    func runCreateInstallMedia() {
        guard !installerPath.isEmpty, !selectedDrive.isEmpty else {
            statusMessage = "Please provide a valid installer and external drive."
            return
        }

        let session = DASessionCreate(kCFAllocatorDefault)
        if let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session!, URL(fileURLWithPath: "/Volumes/\(selectedDrive)") as CFURL),
           let description = DADiskCopyDescription(disk) as? [String: Any],
           let mediaSize = description[kDADiskDescriptionMediaSizeKey as String] as? Int64 {
            let minimumSizeInBytes: Int64 = 16 * 1024 * 1024 * 1024
            if mediaSize < minimumSizeInBytes {
                statusMessage = "The selected drive is too small. Please use a drive larger than 16GB."
                return
            }
        }


        isProcessing = true
        statusMessage = "Starting process..."
        progress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            let pipe = Pipe()
            
            guard let wrapperPath = Bundle.main.path(forResource: "sudo_wrapper", ofType: "sh") else {
                DispatchQueue.main.async {
                    self.statusMessage = "Error: Wrapper script not found."
                    self.isProcessing = false
                }
                return
            }
            
            let createInstallMediaPath = "\(self.installerPath)/Contents/Resources/createinstallmedia"
            task.executableURL = URL(fileURLWithPath: wrapperPath)
            task.arguments = [createInstallMediaPath, "--volume", "/Volumes/\(self.selectedDrive)"]
            task.standardOutput = pipe
            task.standardError = pipe
            
            let outputHandle = pipe.fileHandleForReading
            outputHandle.readabilityHandler = { fileHandle in
                let data = fileHandle.availableData
                if let line = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.parseCommandOutput(line)
                    }
                }
            }
            
            task.terminationHandler = { _ in
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.progress = 1.0
                    self.statusMessage = "Complete! Bootable installer created."
                }
            }
            
            do {
                try task.run()
            } catch {
                DispatchQueue.main.async {
                    self.statusMessage = "Error: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }
    
    func fetchDrivesUsingIOKit() -> [String] {
        var drives = [String]()
        let session = DASessionCreate(kCFAllocatorDefault)
        let minimumSizeInBytes: Int64 = 16 * 1024 * 1024 * 1024
        if let mountPoints = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: []) {
            for url in mountPoints {
                if let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session!, url as CFURL),
                   let description = DADiskCopyDescription(disk) as? [String: Any],
                   let isRemovable = description[kDADiskDescriptionMediaRemovableKey as String] as? Bool,
                   let isInternal = description[kDADiskDescriptionDeviceInternalKey as String] as? Bool,
                   let mediaSize = description[kDADiskDescriptionMediaSizeKey as String] as? Int64 {
                    if isRemovable && !isInternal {
                        if mediaSize >= minimumSizeInBytes {
                            let volumeName = description[kDADiskDescriptionVolumeNameKey as String] as? String ?? "Unnamed Volume"
                            drives.append(volumeName)
                        }
                    }
                }
            }
        }

        return drives
    }

    struct CreateInstallerView_Previews: PreviewProvider {
        static var previews: some View {
            CreateInstallerView()
        }
    }
}
