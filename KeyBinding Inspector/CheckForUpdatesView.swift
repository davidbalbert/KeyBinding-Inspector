//
//  UpdateChecker.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/13/23.
//

import SwiftUI
import CoreServices

struct CheckForUpdatesView: View {
    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var defaultWebBrowser: String {
        let name = LSCopyDefaultApplicationURLForURL(URL(string: "https://github.com")! as CFURL, .viewer, nil)
            .map { $0.takeRetainedValue() as URL }
            .map { $0.lastPathComponent.replacingOccurrences(of: ".app", with: "") } ?? "Web Browser"

        return name
    }

    @State var latestVersion: String?

    var body: some View {
        HStack(alignment: .top) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 19))
                .offset(y: -3)

            VStack(alignment: .leading) {
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
                        Spacer()
                        Button {
                            print("Remind Me Later")
                        } label: {
                            Text("Remind Me Later")
                                .padding([.leading, .trailing], 13)
                        }
                        Button {
                            print("Open \(defaultWebBrowser)")
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
                        Spacer()
                        Button {
                            print("Cancel")
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
        .onAppear {
            Task {
                // await checkForUpdates()
            }
        }
    }
}

#Preview {
    CheckForUpdatesView()
}

#Preview {
    CheckForUpdatesView(latestVersion: "1.0")
}