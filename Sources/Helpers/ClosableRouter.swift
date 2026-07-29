//
//  ClosableRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 29.07.2026.
//

@MainActor
public protocol ClosableRouter: AnyObject {

    func close()
}

extension PushRouter: ClosableRouter {

    public func close() { requestClose() }
}

extension ModalRouter: ClosableRouter {

    public func close() { requestClose() }
}
