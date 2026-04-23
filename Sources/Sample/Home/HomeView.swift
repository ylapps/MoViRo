//
//  HomeView.swift
//  Moviro
//

import SwiftUI

// MARK: - View

/// Root view of the Home tab. Demonstrates push and modal navigation triggers.
struct HomeView: BaseView {

    @State var model: HomeModel

    init(model: HomeModel) {
        self.model = model
    }

    var body: some View {
        List {
            Section("Push Navigation") {
                Button("Push Detail") {
                    model.router?.showDetail()
                }
                Button("Push Switch Screen") {
                    model.router?.showPushSwitch()
                }
            }

            Section("Modal Navigation") {
                Button("Present Sheet") {
                    model.router?.showSheet()
                }
                Button("Present Full Screen") {
                    model.router?.showFullScreen()
                }
                Button("Present Modal Switch") {
                    model.router?.showModalSwitch()
                }
            }

            Section("Window Navigation") {
                Button("Show Window Alert") {
                    model.router?.showWindowAlert()
                }
                Button("Show Window Toast") {
                    model.router?.showWindowToast()
                }
            }
        }
        .navigationTitle("Home")
    }
}
