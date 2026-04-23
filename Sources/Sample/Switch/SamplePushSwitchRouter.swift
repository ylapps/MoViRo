//
//  SamplePushSwitchRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Routable

@MainActor
protocol PushSwitchRoutable {
    func showPushSwitch()
}

extension PushSwitchRoutable where Self: AnyPushRouter {
    func showPushSwitch() {
        pushed = SamplePushSwitchRouter()
    }
}

// MARK: - Push Switch Content View

/// View displayed inside the push switch. Shows content and a toggle button.
struct PushSwitchContentView: BaseView {

    @State var model: PushSwitchContentModel

    init(model: PushSwitchContentModel) {
        self.model = model
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: model.iconName)
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text(model.title)
                .font(.title2)

            Text("Displayed via AnyPushSwitchRouter")
                .foregroundStyle(.secondary)

            Button("Switch Content") {
                model.onToggle?()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle(model.title)
    }
}

// MARK: - Push Switch Content Model

@Observable
final class PushSwitchContentModel: Model<Never> {

    let title: String
    let iconName: String
    var onToggle: (() -> Void)?

    init(title: String, iconName: String) {
        self.title = title
        self.iconName = iconName
        super.init()
    }
}

// MARK: - Push Switch Content Router

/// Inner push router used as a child of `AnyPushSwitchRouter`.
final class PushSwitchContentRouter: PushRouter<PushSwitchContentView> {

    let title: String
    let iconName: String
    var onToggle: (() -> Void)?

    init(title: String, iconName: String) {
        self.title = title
        self.iconName = iconName
        super.init()
    }

    override func makeModel() -> PushSwitchContentModel {
        let model = PushSwitchContentModel(title: title, iconName: iconName)
        model.onToggle = onToggle
        return model
    }
}

// MARK: - Sample Push Switch Router

/// Demonstrates `AnyPushSwitchRouter` — dynamically swaps between two push content routers
/// within a navigation stack.
final class SamplePushSwitchRouter: AnyPushSwitchRouter, ClosableRouter {

    private let contentA: PushSwitchContentRouter
    private let contentB: PushSwitchContentRouter
    private var showingA = true

    init() {
        contentA = PushSwitchContentRouter(title: "Screen A", iconName: "a.circle.fill")
        contentB = PushSwitchContentRouter(title: "Screen B", iconName: "b.circle.fill")
        super.init(current: contentA)

        contentA.onToggle = { [weak self] in self?.toggleContent() }
        contentB.onToggle = { [weak self] in self?.toggleContent() }
    }

    func toggleContent() {
        showingA.toggle()
        current = showingA ? contentA : contentB
    }
}
