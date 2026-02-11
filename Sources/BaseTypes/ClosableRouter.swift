//
//  ClosableRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 16.01.2026.
//

@MainActor
public protocol ClosableRouter {

    func close()
}

public extension ClosableRouter where Self: AnyModalRouter {

    func close() {
        presenting?.presented = nil
    }
}

public extension ClosableRouter where Self: AnyPushRouter {

    func close() {
        guard let pushing else {
            stack?.presenting?.presented = nil
            return
        }
        pushing.pushed = nil
    }
}
