//
//  AnyAlertRouter.swift
//  SUISimpleRouting
//
//  Created by Background Agent on 14.09.2025.
//

import SwiftUI

// MARK: - Router

@Observable
open class AnyAlertRouter: AnyModalRouter {

    public struct AlertState: Identifiable {
        public enum Buttons {
            case dismiss(Alert.Button)
            case two(Alert.Button, Alert.Button)
        }

        public let id: String = UUID().uuidString
        public var title: LocalizedStringKey
        public var message: LocalizedStringKey?
        public var buttons: Buttons

        public init(
            title: LocalizedStringKey,
            message: LocalizedStringKey? = nil,
            buttons: Buttons
        ) {
            self.title = title
            self.message = message
            self.buttons = buttons
        }
    }

    /// Wrapped modal router which content will be displayed under the alert.
    public var current: AnyModalRouter {
        willSet {
            current.presenting = nil
            newValue.presenting = self
        }
    }

    /// Forward presented router to the current one
    public override var presented: AnyModalRouter? {
        get { current.presented }
        set { current.presented = newValue }
    }

    /// Alert presentation state
    public var alert: AlertState?

    public init(current: AnyModalRouter, transition: Transition) {
        self.current = current
        super.init(transition: transition)
    }

    override func makeContentView() -> AnyView {
        .init(AnyAlertView(router: self))
    }

    // MARK: Convenience

    public func showDismissAlert(
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        dismissTitle: LocalizedStringKey = "OK"
    ) {
        alert = .init(
            title: title,
            message: message,
            buttons: .dismiss(.default(Text(dismissTitle)))
        )
    }
}

// MARK: - View

private struct AnyAlertView: View {

    @State var router: AnyAlertRouter

    var body: some View {
        router.current.makeView()
            .alert(item: $router.alert) { state in
                let title = Text(state.title)
                let message = state.message.map(Text.init)
                switch state.buttons {
                case .dismiss(let button):
                    return Alert(title: title, message: message, dismissButton: button)
                case .two(let primary, let secondary):
                    return Alert(title: title, message: message, primaryButton: primary, secondaryButton: secondary)
                }
            }
    }
}

