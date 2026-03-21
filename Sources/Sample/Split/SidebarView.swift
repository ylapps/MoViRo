//
//  SidebarView.swift
//  Moviro
//

import SwiftUI

// MARK: - View

/// Sidebar view for the split navigation tab. Demonstrates push navigation within a split view.
struct SidebarView: BaseView {

    @State var model: SidebarModel

    init(model: SidebarModel) {
        self.model = model
    }

    var body: some View {
        List {
            ForEach(model.items, id: \.self) { item in
                Button(item) {
                    model.router?.pushDetail(title: item)
                }
            }
        }
        .navigationTitle("Sidebar")
    }
}
