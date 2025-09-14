//
//  AnyAlertRouter.swift
//  SUISimpleRouting
//
//  Created by Yevhenii Lytvynenko on 15.11.2024.
//

import SwiftUI

// MARK: - Router

@Observable
open class AnyAlertRouter: AnyRouter {

    // MARK: State
    
    /// Current alert configuration
    public let alertConfig: AlertConfig
    
    /// Router which presents this router.
    @ObservationIgnored
    public internal(set) weak var presenting: AnyAlertRouter?

    /// Alert presented from this router.
    public var presentedAlert: AnyAlertRouter? {
        willSet {
            presentedAlert?.presenting = nil
            newValue?.presenting = self
        }
    }

    // MARK: Initialization

    init(alertConfig: AlertConfig, presentedAlert: AnyAlertRouter? = nil) {
        self.alertConfig = alertConfig
        self._presentedAlert = presentedAlert
        super.init()
    }

    // MARK: Makers

    public final func makeView() -> some View {
        AnyAlertView(router: self)
    }
}

public extension AnyAlertRouter {

    struct AlertConfig: Hashable, Sendable {
        public let title: String
        public let message: String?
        public let primaryButton: AlertButton?
        public let secondaryButton: AlertButton?
        
        public init(
            title: String,
            message: String? = nil,
            primaryButton: AlertButton? = nil,
            secondaryButton: AlertButton? = nil
        ) {
            self.title = title
            self.message = message
            self.primaryButton = primaryButton
            self.secondaryButton = secondaryButton
        }
    }
    
    struct AlertButton: Hashable, Sendable {
        public let title: String
        public let style: Style
        public let action: (() -> Void)?
        
        public enum Style: Hashable, Sendable {
            case `default`
            case cancel
            case destructive
        }
        
        public init(title: String, style: Style = .default, action: (() -> Void)? = nil) {
            self.title = title
            self.style = style
            self.action = action
        }
        
        public static func == (lhs: AlertButton, rhs: AlertButton) -> Bool {
            lhs.title == rhs.title && lhs.style == rhs.style
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(style)
        }
    }
}

// MARK: - View

struct AnyAlertView: View {

    @State var router: AnyAlertRouter
    @State private var isReadyToPresent = false

    var body: some View {
        Group {
            if isReadyToPresent {
                router.makeContentView()
                    .alert(
                        router.alertConfig.title,
                        isPresented: alertBinding,
                        presenting: router.presentedAlert
                    ) { presentedAlert in
                        alertButtons(for: presentedAlert.alertConfig)
                    } message: { presentedAlert in
                        if let message = presentedAlert.alertConfig.message {
                            Text(message)
                        }
                    }
            } else {
                router.makeContentView()
            }
        }
        .onAppear { isReadyToPresent = true }
    }
    
    private var alertBinding: Binding<Bool> {
        Binding(
            get: { router.presentedAlert != nil },
            set: { if !$0 { router.presentedAlert = nil } }
        )
    }
    
    @ViewBuilder
    private func alertButtons(for config: AnyAlertRouter.AlertConfig) -> some View {
        if let primaryButton = config.primaryButton {
            Button(primaryButton.title, role: buttonRole(for: primaryButton.style)) {
                primaryButton.action?()
                router.presentedAlert = nil
            }
        }
        
        if let secondaryButton = config.secondaryButton {
            Button(secondaryButton.title, role: buttonRole(for: secondaryButton.style)) {
                secondaryButton.action?()
                router.presentedAlert = nil
            }
        }
        
        if config.primaryButton == nil && config.secondaryButton == nil {
            Button("OK") {
                router.presentedAlert = nil
            }
        }
    }
    
    private func buttonRole(for style: AnyAlertRouter.AlertButton.Style) -> ButtonRole? {
        switch style {
        case .default:
            return nil
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}