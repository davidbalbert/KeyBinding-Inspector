//
//  AccessoryBar.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/12/23.
//

import SwiftUI

struct AccessoryBarSearchTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            HStack(spacing: 3.0) {
                Image(systemName: "magnifyingglass")
                configuration
                    .textFieldStyle(.plain)
            }
            .padding([.leading, .trailing], 5.0)
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(.quaternary)
                .frame(height: 22)
        }
    }
}

extension TextFieldStyle where Self == AccessoryBarSearchTextFieldStyle {
    static var accessoryBarSearchField: AccessoryBarSearchTextFieldStyle { AccessoryBarSearchTextFieldStyle() }
}

struct AccessoryBar<Content>: View where Content: View {
    @Binding var visible: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack {
                content()
                Button {
                    visible = false
                } label: {
                    Text("Done")
                        .font(.callout)
                        .padding([.leading, .trailing], 4)
                }
            }
            // Visual height is 28, but height == 27 + 1 point of top padding
            // balances the extra point added by the Divider
            .frame(height: 27)
            .padding(EdgeInsets(top: 1, leading: 5, bottom: 0, trailing: 5))
            Divider()
        }
        .buttonStyle(.accessoryBarAction)
        .background(.white)
        .transition(.move(edge: .top))
    }
}

extension View {
    func accessoryBar(_ visible: Binding<Bool>, @ViewBuilder content: @escaping () -> some View) -> some View {
        VStack(spacing: 0) {
            if visible.wrappedValue {
                AccessoryBar(visible: visible, content: content)
            }
            self
        }
    }
}

