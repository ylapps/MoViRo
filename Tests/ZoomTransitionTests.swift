//
//  ZoomTransitionTests.swift
//  MoviroTests
//

@testable import Moviro
import SwiftUI
import Testing

@Suite("Zoom push transitions", .serialized)
@MainActor
struct ZoomTransitionTests {

    @Test func thePushIsAutomaticUnlessAsked() {
        #expect(StubPushRouter().transition == .automatic)
        #expect(StubVoidResultPushRouter().transition == .automatic)
        #expect(StubResultPushRouter().transition == .automatic)
    }

    @Test func aZoomCarriesItsSourceID() {
        #expect(ZoomPushRouter(sourceID: 3).transition == .zoom(sourceID: 3))
        #expect(ZoomPushRouter(sourceID: 3).transition != .zoom(sourceID: 4))
        #expect(ZoomResultPushRouter(sourceID: "card").transition == .zoom(sourceID: "card"))
        #expect(RecordingPushRouter(transition: .zoom(sourceID: "a")).transition == .zoom(sourceID: "a"))
    }

    /// A zoom destination under a stack whose root carries the matching
    /// source: both build, the pushed screen appears once and goes on pop.
    @Test func aZoomPushAppearsAndPopsInsideAStack() async throws {
        let root = ZoomSourcePushRouter()
        let window = WindowHost.host(NavigationStackRouter(root: root, transition: .fullScreen).makeView())
        defer { window.isHidden = true }
        try await WindowHost.waitUntil { root.recorder.isOnScreen }

        let pushed = RecordingPushRouter(transition: .zoom(sourceID: ZoomSourcePushRouter.sourceID))
        root.pushed = pushed
        try await WindowHost.waitUntil { pushed.recorder.isOnScreen }
        try await WindowHost.settle()
        #expect(pushed.recorder.appearCount == 1)

        root.pushed = nil
        try await WindowHost.waitUntil { !pushed.recorder.isOnScreen }
        #expect(root.recorder.isOnScreen)
    }

    /// A zoom push set before the stack is on screen — a deep link — is
    /// built once and kept, like any other preset push.
    @Test func aPresetZoomPushIsBuiltOnceAndKept() async throws {
        let root = ZoomSourcePushRouter()
        let pushed = RecordingPushRouter(transition: .zoom(sourceID: ZoomSourcePushRouter.sourceID))
        root.pushed = pushed
        let window = WindowHost.host(NavigationStackRouter(root: root, transition: .fullScreen).makeView())
        defer { window.isHidden = true }

        try await WindowHost.waitUntil { pushed.recorder.isOnScreen }
        try await WindowHost.settle()
        #expect(root.pushed === pushed)
        #expect(pushed.recorder.appearCount == 1)
        #expect(pushed.recorder.disappearCount == 0)
    }
}

// MARK: - Stubs

private final class ZoomPushRouter: PushRouter<StubResultView> {
    init(sourceID: Int) { super.init(transition: .zoom(sourceID: sourceID)) }
    override func makeModel() -> StubResultModel { StubResultModel() }
}

private final class ZoomResultPushRouter: PushRouterWithCloseReason<StubResultView, String> {
    init(sourceID: String) { super.init(transition: .zoom(sourceID: sourceID), onWillCloseWithReason: nil) }
    override func makeModel() -> StubResultModel { StubResultModel() }
}

/// A root whose screen carries a zoom source.
private final class ZoomSourcePushRouter: AnyPushRouter, Recording {
    static let sourceID = "card"
    let recorder = ScreenRecorder()

    override func makeScreen() -> ErasedScreen {
        .init(
            RecordingView(recorder: recorder)
                .zoomTransitionSource(id: Self.sourceID)
                .pushDestination(of: self)
        )
    }
}
