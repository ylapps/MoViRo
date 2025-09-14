import SwiftUI

/// Router that presents SwiftUI `Alert`s using `.alert` transition.
open class AlertRouter: AnyModalRouter {

    // MARK: Stored properties

    /// Alert title text
    public let title: LocalizedStringKey
    /// Optional alert message text
    public let message: LocalizedStringKey?
    /// Primary `Alert.Button`
    public let primaryButton: Alert.Button
    /// Optional secondary `Alert.Button`. If `nil`, the alert will be created using the single-button initializer.
    public let secondaryButton: Alert.Button?

    // MARK: Initialization

    public init(title: LocalizedStringKey,
                message: LocalizedStringKey? = nil,
                primaryButton: Alert.Button = .default(Text("OK")),
                secondaryButton: Alert.Button? = nil,
                presented: AnyModalRouter? = nil) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        super.init(transition: .alert, presented: presented)
    }

    // MARK: Overrides

    /// Always returns an empty view because the actual UI is provided by `Alert`.
    override func makeContentView() -> AnyView {
        .init(EmptyView())
    }

    /// Creates the concrete `Alert` to present.
    override func makeAlert() -> Alert {
        if let secondaryButton {
            return Alert(title: Text(title),
                         message: message.map { Text($0) },
                         primaryButton: primaryButton,
                         secondaryButton: secondaryButton)
        } else {
            return Alert(title: Text(title),
                         message: message.map { Text($0) },
                         dismissButton: primaryButton)
        }
    }
}