//
//  AlertState.swift
//  Moviro
//

import SwiftUI

/// Data-driven description of an alert. Set on `AnyRouter.alert` to present.
public struct AlertState {

    /// A single alert action button.
    public struct Action {
        public let title: LocalizedStringKey
        public let role: ButtonRole?
        public let handler: (() -> Void)?

        public init(title: LocalizedStringKey, role: ButtonRole? = nil, handler: (() -> Void)? = nil) {
            self.title = title
            self.role = role
            self.handler = handler
        }
    }

    public let title: LocalizedStringKey
    public let message: LocalizedStringKey?
    public let actions: [Action]

    public init(title: LocalizedStringKey, message: LocalizedStringKey? = nil, actions: [Action] = []) {
        self.title = title
        self.message = message
        self.actions = actions
    }
}

// MARK: - View Modifier

extension View {

    @ViewBuilder
    func routerAlert(_ alert: Binding<AlertState?>) -> some View {
        self.alert(
            alert.wrappedValue?.title ?? "",
            isPresented: Binding(
                get: { alert.wrappedValue != nil },
                set: { if !$0 { alert.wrappedValue = nil } }
            ),
            presenting: alert.wrappedValue
        ) { state in
            if state.actions.isEmpty {
                Button("OK", role: .cancel) {}
            } else {
                ForEach(Array(state.actions.enumerated()), id: \.offset) { _, action in
                    Button(action.title, role: action.role) {
                        action.handler?()
                    }
                }
            }
        } message: { state in
            if let message = state.message {
                Text(message)
            }
        }
    }
}
