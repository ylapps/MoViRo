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

extension ResultPushRouter: ClosableRouter where ClosingResult == Void {

    public func close() { requestClose() }
}

extension ResultModalRouter: ClosableRouter where ClosingResult == Void {

    public func close() { requestClose() }
}
