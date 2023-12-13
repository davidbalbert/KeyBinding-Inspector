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
                .padding()

            VStack(alignment: .leading) {
                Text("Checking for updates…")
                    .bold()
//                    .padding(.bottom)
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
//            .padding()
        }
        .padding([.leading, .trailing])
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
