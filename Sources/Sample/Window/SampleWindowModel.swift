//
//  SampleWindowModel.swift
//  Moviro
//

import Foundation

// MARK: - Model

@Observable
final class SampleWindowModel: Model<SampleWindowRouter> {

    // MARK: Window Navigation

    /// Shows an alert in a separate UIWindow (independent of any modal presentation).
    func showWindowAlert() {
        guard let router else { return }
        let alertRouter = WindowAlertRouter(windowRouter: router)
        router.addChild(alertRouter)
    }

    /// Shows a toast banner in a separate UIWindow overlay.
    func showWindowToast() {
        guard let router else { return }
        let toastRouter = WindowToastRouter(windowRouter: router)
        let config = AnyWindowRouter.ChildConfig(level: .alert + 1) { maxFrame in
            CGRect(x: 0, y: 0, width: maxFrame.width, height: 120)
        }
        router.addChild(toastRouter, config: config)
    }
}
