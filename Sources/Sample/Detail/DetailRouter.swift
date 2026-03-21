//
//  DetailRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Router

/// Push router for the detail screen. Demonstrates `ClosableRouter` for popping
/// and presenting various modal transitions.
final class DetailRouter: PushRouter<DetailView>, ClosableRouter {

    override func makeModel() -> DetailModel {
        DetailModel(router: self)
    }

    // MARK: Modal Presentations

    func presentSheet() {
        stack?.presented = SheetRouter()
    }

    func presentFullScreen() {
        stack?.presented = FullScreenRouter()
    }

    func presentPopover() {
        stack?.presented = PopoverRouter()
    }

    // MARK: Alert

    func showAlert() {
        presentAlert(
            title: "Sample Alert",
            message: "This alert is presented via router-driven AlertState.",
            actions: [
                .init(title: "Cancel", role: .cancel),
                .init(title: "OK") { print("OK tapped") }
            ]
        )
    }

    /// Shows an alert first, then presents a sheet when the user taps "Open Sheet".
    func showAlertThenSheet() {
        presentAlert(
            title: "Alert First",
            message: "Tap \"Open Sheet\" to present a sheet after this alert.",
            actions: [
                .init(title: "Cancel", role: .cancel),
                .init(title: "Open Sheet") { [weak self] in
                    self?.stack?.presented = SheetRouter()
                }
            ]
        )
    }

    /// Presents a sheet first, then queues an alert on the current screen behind it.
    /// The alert becomes visible once the sheet is dismissed.
    func showSheetThenAlert() {
        stack?.presented = SheetRouter()
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            presentAlert(
                title: "Alert Behind Sheet",
                message: "This alert was queued after the sheet. You'll see it after dismissing the sheet."
            )
        }
    }
}
