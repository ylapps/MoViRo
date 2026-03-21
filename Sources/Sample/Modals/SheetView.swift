//
//  SheetView.swift
//  Moviro
//

import SwiftUI

// MARK: - View

/// Demonstrates a `.sheet` modal presentation.
struct SheetView: BaseView {

    @State var model: SheetModel

    init(model: SheetModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "rectangle.bottomhalf.inset.filled")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("Sheet Modal")
                .font(.title)

            Text("Presented as .sheet transition")
                .foregroundStyle(.secondary)

            Button("Dismiss") {
                model.router?.close()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
