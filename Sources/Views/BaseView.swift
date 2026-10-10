//
//  BaseView.swift
//  Moviro
//

import SwiftUI

@MainActor
public protocol ModelHolding {
    associatedtype Model
    init(model: Model)
}

@MainActor
public protocol BaseView: View & ModelHolding where Model: AnyModel {}

public extension BaseView {

    /// The view, with its model's lifecycle tied to the view's appearance.
    static func with(_ model: Model) -> some View {
        Self(model: model).appearance(of: model)
    }
}
