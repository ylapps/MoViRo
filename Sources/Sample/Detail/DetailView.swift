//
//  DetailView.swift
//  Moviro
//

import SwiftUI

// MARK: - View

/// A pushed detail screen. Demonstrates presenting modals from a pushed context
/// and using `ClosableRouter` to pop back.
struct DetailView: BaseView {

    @State var model: DetailModel

    init(model: DetailModel) {
        self.model = model
    }

    var body: some View {
        List {
            Section("Modal from Detail") {
                Button("Present Sheet") {
                    model.router?.showSheet()
                }
                Button("Present Full Screen") {
                    model.router?.showFullScreen()
                }
                Button("Present Popover") {
                    model.router?.showPopover()
                }
            }

            Section("Alert") {
                Button("Show Alert") {
                    model.router?.showAlert()
                }
                Button("Alert → then Sheet") {
                    model.router?.showAlertThenSheet()
                }
                Button("Sheet → then Alert") {
                    model.router?.showSheetThenAlert()
                }
            }

            Section {
                Button("Close (Pop)", role: .destructive) {
                    model.router?.close()
                }
            }
        }
        .navigationTitle("Detail")
    }
}

#Preview {
    NavigationStackRouter(root: DetailRouter(), transition: .fullScreen).makeView()
}
