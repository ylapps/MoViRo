//
//  BaseView.swift
//  ModalPet
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import SwiftUI

@MainActor
public protocol BaseView: View {
    associatedtype Model: AnyModel
    init(model: Model)
}

public extension BaseView {

    static func with(_ model: Model) -> some View {
        Self(model: model)
            .onAppear { [weak model] in model?.isAppeared = true }
            .onDisappear { [weak model] in model?.isAppeared = false }
    }
}
