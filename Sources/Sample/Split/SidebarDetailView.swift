//
//  SidebarDetailView.swift
//  Moviro
//

import SwiftUI

// MARK: - View

/// Detail view shown in the split view's detail column when an item is selected.
struct SidebarDetailView: BaseView {

    @State var model: SidebarDetailModel

    init(model: SidebarDetailModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text(model.title)
                .font(.title)

            Text("Pushed inside NavigationSplitView")
                .foregroundStyle(.secondary)
        }
        .navigationTitle(model.title)
    }
}
