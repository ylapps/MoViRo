//
//  SampleModalSwitchRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Routable

@MainActor
protocol ModalSwitchRoutable {
    func showModalSwitch()
}

extension ModalSwitchRoutable where Self: AnyModalRouter {
    func showModalSwitch() {
        presented = SampleModalSwitchRouter()
    }
}

extension ModalSwitchRoutable where Self: AnyPushRouter {
    func showModalSwitch() {
        stack?.presented = SampleModalSwitchRouter()
    }
}

// MARK: - Modal Switch Content View

/// View displayed inside the modal switch. Shows content with toggle and close buttons.
struct ModalSwitchContentView: BaseView {

    @State var model: ModalSwitchContentModel

    init(model: ModalSwitchContentModel) {
        self.model = model
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: model.iconName)
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)

                Text(model.title)
                    .font(.title2)

                Text("Displayed via AnyModalSwitchRouter")
                    .foregroundStyle(.secondary)

                Button("Switch Content") {
                    model.onToggle?()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Modal Switch")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        model.onClose?()
                    }
                }
            }
        }
    }
}

// MARK: - Modal Switch Content Model

@Observable
final class ModalSwitchContentModel: Model<Never> {

    let title: String
    let iconName: String
    var onToggle: (() -> Void)?
    var onClose: (() -> Void)?

    init(title: String, iconName: String) {
        self.title = title
        self.iconName = iconName
        super.init()
    }
}

// MARK: - Modal Switch Content Router

/// Inner modal router used as a child of `AnyModalSwitchRouter`.
final class ModalSwitchContentRouter: ModalRouter<ModalSwitchContentView> {

    let title: String
    let iconName: String
    var onToggle: (() -> Void)?
    var onCloseAction: (() -> Void)?

    init(title: String, iconName: String) {
        self.title = title
        self.iconName = iconName
        super.init(transition: .sheet)
    }

    override func makeModel() -> ModalSwitchContentModel {
        let model = ModalSwitchContentModel(title: title, iconName: iconName)
        model.onToggle = onToggle
        model.onClose = onCloseAction
        return model
    }
}

// MARK: - Sample Modal Switch Router

/// Demonstrates `AnyModalSwitchRouter` — dynamically swaps between two modal content routers.
final class SampleModalSwitchRouter: AnyModalSwitchRouter {

    private let contentA: ModalSwitchContentRouter
    private let contentB: ModalSwitchContentRouter
    private var showingA = true

    init() {
        contentA = ModalSwitchContentRouter(title: "Content A", iconName: "a.circle.fill")
        contentB = ModalSwitchContentRouter(title: "Content B", iconName: "b.circle.fill")
        super.init(current: contentA, transition: .sheet)

        contentA.onToggle = { [weak self] in self?.toggleContent() }
        contentB.onToggle = { [weak self] in self?.toggleContent() }
        contentA.onCloseAction = { [weak self] in self?.presenting?.presented = nil }
        contentB.onCloseAction = { [weak self] in self?.presenting?.presented = nil }
    }

    func toggleContent() {
        showingA.toggle()
        current = showingA ? contentA : contentB
    }
}
