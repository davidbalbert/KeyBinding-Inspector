//
//  UpdateChecker.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/13/23.
//

import SwiftUI
import AppKit

struct UpdateChecker: View {
    @Environment(\.dismiss) var dismiss
    @State var latestVersion: String?

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }

    @State var isLatest: Bool = false
    @State var errorChecking: Bool = false
    @State var errorOpening: Bool = false

    @State var done: Bool = false

    var updateURL: URL {
        URL(string: "https://github.com/davidbalbert/KeyBinding-Inspector/releases/latest")!
    }

    var defaultWebBrowser: String {
        let name = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://github.com")!)
            .map { $0.lastPathComponent.replacingOccurrences(of: ".app", with: "") } ?? "Web Browser"

        return name
    }

    func fetchVersionInfo() async {
        let url = URL(string: "https://api.github.com/repos/davidbalbert/KeyBinding-Inspector/releases/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let tagName = json["tag_name"] as? String else {
            errorChecking = true
            return
        }

        let version: String
        if tagName.hasPrefix("v") {
            version = String(tagName.dropFirst())
        } else {
            version = tagName
        }

        if version == currentVersion {
            isLatest = true
        } else {
            latestVersion = version
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 19))
                .offset(y: -3)

            VStack(alignment: .trailing) {
                if let latestVersion {
                    VStack(alignment: .leading) {
                        Text("A new version of KeyBinding Inspector is available!")
                            .bold()
                            .padding([.top, .bottom], 4)
                        Text("KeyBinding Inspector \(latestVersion) is now available—you have \(currentVersion). Would you like to download it now?")
                            .font(.system(size: 11))
                    }
                    .offset(y: -9)
                    
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Remind Me Later")
                                .padding([.leading, .trailing], 13)
                        }
                        Button {
                            if !NSWorkspace.shared.open(updateURL) {
                                errorOpening = true
                            } else {
                                dismiss()
                            }
                        } label: {
                            Text("Open \(defaultWebBrowser)")
                                .padding([.leading, .trailing], 16)
                        }
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("Checking for updates…")
                            .bold()
                        ProgressView()
                            .progressViewStyle(.linear)
                    }
                    .offset(y: -4)

                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .padding([.leading, .trailing])
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(width: latestVersion == nil ? 400 : 500)
        .alert("You’re up-to-date!", isPresented: $isLatest) {
            Button("OK") {
                // Wrap in a task so dismiss() gets called after the
                // alert goes away.
                Task {
                    done = true
                }
            }
        } message: {
            Text("KeyBinding Inspector \(currentVersion) is currently the newest version available.")
        }
        .alert("Update Error!", isPresented: $errorChecking) {
            Button("Cancel Update") {
                Task {
                    done = true
                }
            }
        } message: {
            Text("An error occurred while retrieving update information. Please try again later.")
        }
        .alert("Update Error!", isPresented: $errorOpening) {
            Button("Cancel Update") {
                Task {
                    done = true
                }
            }
        } message: {
            Text("Something went wrong while opening \(defaultWebBrowser)")
        }
        .onChange(of: done) {
            dismiss()
        }
        .task {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return
            }

            await fetchVersionInfo()
        }
    }
}

#Preview {
    UpdateChecker()
}

#Preview {
    UpdateChecker(latestVersion: "1.0")
}

