//
//  UpdateChecker.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/13/23.
//

import SwiftUI

struct CheckForUpdatesView: View {
    var body: some View {
        HStack {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 11))
                .offset(y: -3)

            VStack(alignment: .leading) {
                Text("Checking for updates…")
                    .bold()
                ProgressView()
                    .progressViewStyle(.linear)
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
            .frame(width: 274)
        }
        .padding(EdgeInsets(top: 15, leading: 20, bottom: 20, trailing: 20))
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
