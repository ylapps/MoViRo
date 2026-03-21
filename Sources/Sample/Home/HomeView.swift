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
                    model.router?.pushDetail()
                }
                Button("Push Switch Screen") {
                    model.router?.pushSwitchScreen()
                }
            }

            Section("Modal Navigation") {
                Button("Present Sheet") {
                    model.router?.presentSheet()
                }
                Button("Present Full Screen") {
                    model.router?.presentFullScreen()
                }
                Button("Present Modal Switch") {
                    model.router?.presentModalSwitch()
                }
            }
        }
        .navigationTitle("Home")
    }
}
