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
            .onAppear { model.isAppeared = true }
            .onDisappear { model.isAppeared = false }
    }
}
