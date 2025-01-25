//
//  AboutView.swift
//  MacUSB Creator by kingkwahli at macOS Utilities
//
import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            VisualEffectBlur(material: .sidebar, blendingMode: .behindWindow)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .frame(width: 80, height: 80)
                Text("MacUSB Creator")
                    .font(.title)
                    .bold()
                Text("Version 1.0")
                    .font(.subheadline)
                Text("Create a bootable macOS Installer (no Terminal needed!)")
                    .font(.body)
                Text("Developed by kingkwahli at macOS Utilities")
                    .font(.footnote)
            }
            .padding()
        }
    }
}
