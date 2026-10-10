//
//  Appearance.swift
//  Moviro
//

import SwiftUI

public extension View {

    /// Runs `model.onAppear()` and `onDisappear()` with this view's appearance.
    /// Appearances are counted, so several views sharing one model start it
    /// once and stop it when the last of them has gone.
    func appearance(of model: AnyModel) -> some View {
        onAppear { [weak model] in model?.isAppeared = true }
            .onDisappear { [weak model] in model?.isAppeared = false }
    }
}
