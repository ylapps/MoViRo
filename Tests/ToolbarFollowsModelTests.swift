//
//  ToolbarFollowsModelTests.swift
//  MoviroTests
//

@testable import Moviro
import SwiftUI
import Testing

/// What a real screen does: the model learns something in `onAppear()`, after
/// the first render, and the body — toolbar content included — has to follow.
@Suite("Toolbar follows the model", .serialized)
@MainActor
struct ToolbarFollowsModelTests {

    @Test func toolbarContentIsReevaluatedAfterOnAppearSetsState() async throws {
        let router = ToolbarPushRouter()
        let window = WindowHost.host(NavigationStackRouter(root: router, transition: .fullScreen).makeView())
        defer { window.isHidden = true }

        try await WindowHost.waitUntil { router.model.isReady }
        try await WindowHost.settle()

        let log = router.model.log
        #expect(log.bodyEvaluations >= 2, "body ran once before onAppear and again after it")
        #expect(log.lastBodyIsReady == true)
        #expect(log.lastToolbarIsReady == true, "the toolbar closure was re-run after the model changed")
    }

    @Test func modalScreenBodyFollowsOnAppear() async throws {
        let router = ToolbarModalRouter()
        let window = WindowHost.host(router.makeView())
        defer { window.isHidden = true }

        try await WindowHost.waitUntil { router.model.isReady }
        try await WindowHost.settle()

        #expect(router.model.log.bodyEvaluations >= 2)
        #expect(router.model.log.lastBodyIsReady == true)
    }
}

// MARK: - Fixtures

@MainActor
final class ToolbarLog {
    var bodyEvaluations = 0
    var lastBodyIsReady: Bool?
    var lastToolbarIsReady: Bool?
}

@Observable
final class ToolbarModel: Model<Never> {
    @ObservationIgnored let log = ToolbarLog()
    private(set) var isReady = false

    override func onAppear() {
        super.onAppear()
        isReady = true
    }
}

struct ToolbarScreen: BaseView {
    @State var model: ToolbarModel
    init(model: ToolbarModel) { self.model = model }

    var body: some View {
        let _ = model.log.bodyEvaluations += 1
        let _ = model.log.lastBodyIsReady = model.isReady
        Text("content")
            .toolbar { toolbarContent() }
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        let _ = model.log.lastToolbarIsReady = model.isReady
        if model.isReady {
            ToolbarItem(placement: .topBarTrailing) {
                Text("share")
            }
        }
    }
}

final class ToolbarPushRouter: PushRouter<ToolbarScreen> {
    override func makeModel() -> ToolbarModel { ToolbarModel() }
}

final class ToolbarModalRouter: ModalRouter<ToolbarScreen> {
    init() { super.init(transition: .fullScreen) }
    override func makeModel() -> ToolbarModel { ToolbarModel() }
}
