//
//  CommandView.swift
//  MacUSB Creator by kingkwahli at macOS Utilities
//
import SwiftUI

struct CommandOutputView: View {
    @Binding var commandOutput: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Command Output")
                .font(.title)
                .bold()
                .padding()

            ScrollView {
                Text(commandOutput)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding()
                    .font(.body)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 600, height: 400)
    }
}
