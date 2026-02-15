//
//  AnyAlertRouter.swift
//  
//
//  Created on 14.09.2025.
//

import SwiftUI

// MARK: - Alert Configuration

public struct AlertConfiguration {
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

public struct AlertButton {
    public enum Style {
        case `default`
        case cancel
        case destructive
    }
    
    public let title: String
    public let style: Style
    public let action: (() -> Void)?
    
    public init(title: String, style: Style = .default, action: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.action = action
    }
}

// MARK: - Router

@Observable
open class AnyAlertRouter: AnyRouter {

    // MARK: State
    
    /// Alert configuration
    public var alertConfig: AlertConfiguration?
    
    /// Router which presents this alert.
    @ObservationIgnored
    public internal(set) weak var presenting: AnyAlertRouter?

    /// Alert presented from this router.
    public var presented: AnyAlertRouter? {
        willSet {
            presented?.presenting = nil
            newValue?.presenting = self
        }
    }

    // MARK: Initialization

    init(presented: AnyAlertRouter? = nil) {
        self._presented = presented
        super.init()
    }

    // MARK: Makers

    public final func makeView() -> some View {
        AnyAlertView(router: self)
    }
    
    // MARK: Public Methods
    
    /// Shows an alert with the given configuration
    public func showAlert(_ config: AlertConfiguration) {
        alertConfig = config
    }
    
    /// Shows a simple alert with title and optional message
    public func showAlert(title: String, message: String? = nil) {
        alertConfig = AlertConfiguration(title: title, message: message)
    }
    
    /// Dismisses the current alert
    public func dismissAlert() {
        alertConfig = nil
    }
}

// MARK: - View

struct AnyAlertView: View {

    @State var router: AnyAlertRouter

    var body: some View {
        router.makeContentView()
            .alert(item: $router.alertConfig) { config in
                if let primaryButton = config.primaryButton,
                   let secondaryButton = config.secondaryButton {
                    return Alert(
                        title: Text(config.title),
                        message: config.message.map { Text($0) },
                        primaryButton: makeAlertButton(primaryButton),
                        secondaryButton: makeAlertButton(secondaryButton)
                    )
                } else if let primaryButton = config.primaryButton {
                    return Alert(
                        title: Text(config.title),
                        message: config.message.map { Text($0) },
                        dismissButton: makeAlertButton(primaryButton)
                    )
                } else {
                    return Alert(
                        title: Text(config.title),
                        message: config.message.map { Text($0) },
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
    }
    
    private func makeAlertButton(_ button: AlertButton) -> Alert.Button {
        switch button.style {
        case .default:
            return .default(Text(button.title), action: button.action)
        case .cancel:
            return .cancel(Text(button.title), action: button.action)
        case .destructive:
            return .destructive(Text(button.title), action: button.action)
        }
    }
}

// MARK: - AlertConfiguration + Identifiable

extension AlertConfiguration: Identifiable {
    public var id: String {
        "\(title)-\(message ?? "")"
    }
}