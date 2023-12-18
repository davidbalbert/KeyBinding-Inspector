//
//  Updater.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/13/23.
//

import SwiftUI
import AppKit

@Observable
class UpdaterState {
    var latestVersion: String? = nil
    var isLatest: Bool = false
    var errorChecking: Bool = false
    var errorOpening: Bool = false
    var done: Bool = false
    var checkCount: Int = 0

    func reset() {
        latestVersion = nil
        isLatest = false
        errorChecking = false
        errorOpening = false
        done = false
    }

    func recheck() {
        checkCount &+= 1
    }
}

struct Updater: View {
    @Bindable var state: UpdaterState
    @Environment(\.dismiss) var dismiss

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }

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
            state.errorChecking = true
            return
        }

        let version: String
        if tagName.hasPrefix("v") {
            version = String(tagName.dropFirst())
        } else {
            version = tagName
        }

        if version == currentVersion {
            state.isLatest = true
        } else {
            state.latestVersion = version
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 19))
            
            if let latestVersion = state.latestVersion {
                VStack(alignment: .leading, spacing: 4) {
                    Text("A new version of KeyBinding Inspector is available!")
                        .bold()
                    Text("KeyBinding Inspector \(latestVersion) is now available—you have \(currentVersion). Would you like to download it now?")
                        .font(.system(size: 11))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Text("Remind Me Later")
                                .padding([.leading, .trailing], 5)
                        }

                        Button {
                            if !NSWorkspace.shared.open(updateURL) {
                                state.errorOpening = true
                            } else {
                                dismiss()
                            }
                        } label: {
                            Text("Open \(defaultWebBrowser)")
                                .padding([.leading, .trailing], 10)
                        }
                    }
                    .padding(.top, 10)
                }
            } else {
                VStack(alignment: .leading) {
                    Text("Checking for updates…")
                        .bold()
                    ProgressView()
                        .progressViewStyle(.linear)

                    HStack {
                        Spacer()

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
        .frame(width: 500)
        .alert("You’re up-to-date!", isPresented: $state.isLatest) {
            Button("OK") {
                // Wrap in a task so dismiss() gets called after the
                // alert goes away.
                Task {
                    state.done = true
                }
            }
        } message: {
            Text("KeyBinding Inspector \(currentVersion) is currently the newest version available.")
        }
        .alert("Update Error!", isPresented: $state.errorChecking) {
            Button("Cancel Update") {
                Task {
                    state.done = true
                }
            }
        } message: {
            Text("An error occurred while retrieving update information. Please try again later.")
        }
        .alert("Update Error!", isPresented: $state.errorOpening) {
            Button("Cancel Update") {
                Task {
                    state.done = true
                }
            }
        } message: {
            Text("Something went wrong while opening \(defaultWebBrowser)")
        }
        .onChange(of: state.done) {
            dismiss()
        }
        .task(id: state.checkCount) {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                return
            }

            await fetchVersionInfo()
        }
    }
}

#Preview {
    Updater(state: UpdaterState())
}

#Preview {
    let state = UpdaterState()
    state.latestVersion = "1.0"
    return Updater(state: state)
}

