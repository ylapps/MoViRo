//
//  FullScreenView.swift
//  Moviro
//

import SwiftUI

// MARK: - View

/// Demonstrates a `.fullScreen` modal presentation.
struct FullScreenView: BaseView {

    @State var model: FullScreenModel

    init(model: FullScreenModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "rectangle.inset.filled")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("Full Screen Modal")
                .font(.title)

            Text("Presented as .fullScreen transition")
                .foregroundStyle(.secondary)

            Button("Dismiss") {
                model.router?.close()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
