//
//  AnyAlertRouter.swift
//  SUISimpleRouting
//
//  Created by GPT Assistant on 14.09.2025.
//

import SwiftUI

// MARK: - Router

@Observable
open class AnyAlertRouter: AnyModalRouter {

    public struct AlertItem: Identifiable {
        public let id = UUID()
        public let title: LocalizedStringKey
        public let message: LocalizedStringKey?
        public let primary: (title: LocalizedStringKey, role: ButtonRole?, action: (() -> Void)?)?
        public let secondary: (title: LocalizedStringKey, role: ButtonRole?, action: (() -> Void)?)?

        public init(
            title: LocalizedStringKey,
            message: LocalizedStringKey? = nil,
            primary: (title: LocalizedStringKey, role: ButtonRole?, action: (() -> Void)?)? = nil,
            secondary: (title: LocalizedStringKey, role: ButtonRole?, action: (() -> Void)?)? = nil
        ) {
            self.title = title
            self.message = message
            self.primary = primary
            self.secondary = secondary
        }
    }

    public var current: AnyModalRouter {
        willSet {
            current.presenting = nil
            newValue.presenting = self
        }
    }

    public var alert: AlertItem?

    public init(current: AnyModalRouter, transition: Transition = .fullScreen, presented: AnyModalRouter? = nil) {
        self.current = current
        super.init(transition: transition, presented: presented)
    }

    override func makeContentView() -> AnyView {
        .init(AnyAlertView(router: self))
    }
}

// MARK: - View

private struct AnyAlertView: View {

    @State var router: AnyAlertRouter

    var body: some View {
        router.current.makeView()
            .alert(
                item: $router.alert,
                content: { item in
                    if let primary = item.primary, let secondary = item.secondary {
                        Alert(
                            title: Text(item.title),
                            message: item.message.map(Text.init),
                            primaryButton: makeButton(from: primary),
                            secondaryButton: makeButton(from: secondary)
                        )
                    } else if let primary = item.primary {
                        Alert(
                            title: Text(item.title),
                            message: item.message.map(Text.init),
                            dismissButton: makeButton(from: primary)
                        )
                    } else {
                        Alert(title: Text(item.title), message: item.message.map(Text.init))
                    }
                }
            )
    }

    private func makeButton(from tuple: (title: LocalizedStringKey, role: ButtonRole?, action: (() -> Void)?)) -> Alert.Button {
        switch tuple.role {
        case .cancel:
            return .cancel(Text(tuple.title), action: tuple.action)
        case .destructive:
            return .destructive(Text(tuple.title), action: tuple.action)
        default:
            return .default(Text(tuple.title), action: tuple.action)
        }
    }
}