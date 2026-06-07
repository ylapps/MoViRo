//
//  PopoverView.swift
//  Moviro
//

import SwiftUI

// MARK: - View

/// Demonstrates a `.popover` modal presentation.
struct PopoverView: BaseView {

    @State var model: PopoverModel

    init(model: PopoverModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Popover")
                .font(.headline)

            Text("Presented as .popover transition")
                .foregroundStyle(.secondary)
                .font(.caption)

            Button("Dismiss") {
                model.router?.requestClose()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
