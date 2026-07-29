//
//  AlertRoutable.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 29.07.2026.
//

@MainActor
public protocol AlertRoutable {

    func showAlert(config: AlertRouter.Config)
}

extension AlertRoutable where Self: AnyPushRouter {

    public func showAlert(config: AlertRouter.Config) {
        presented = AlertRouter(config: config)
    }
}

extension AlertRoutable where Self: AnyModalRouter {

    public func showAlert(config: AlertRouter.Config) {
        presented = AlertRouter(config: config)
    }
}
