//
//  AlertRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 15.07.2026.
//

public final class AlertRouter: AnyModalRouter {

    public let config: Config

    public init(config: Config) {
        self.config = config
        super.init(transition: .fullScreen)
    }
}

extension AlertRouter {

    public struct Config: Sendable {

        public let title: String?
        public let message: String?
        public let actions: [Action]

        public init(title: String? = nil, message: String? = nil, actions: [Action] = []) {
            self.title = title
            self.message = message
            self.actions = actions
        }
    }
}

extension AlertRouter.Config {

    public struct Action: Sendable, Identifiable {
        public let id = UUID()
        public let title: String
        public let role: ButtonRole?
        public let handler: @Sendable () -> Void

        public init(title: String, role: ButtonRole? = nil, handler: @Sendable @escaping () -> Void = {}) {
            self.title = title
            self.role = role
            self.handler = handler
        }
    }
}
