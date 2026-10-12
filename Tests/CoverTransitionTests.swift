//
//  CoverTransitionTests.swift
//  MoviroTests
//

@testable import Moviro
import SwiftUI
import Testing

/// A full-screen cover with a transition of its own. The test window presents
/// no covers (see `WindowHost`), so the cover's content view is hosted
/// directly: that is where the content is inserted and removed, and what the
/// presenting router's two-step dismissal waits on.
@Suite("Cover transitions", .serialized)
@MainActor
struct CoverTransitionTests {

    private static let fade = AnyModalRouter.Transition.fullScreen(
        transition: .opacity,
        animation: .easeOut(duration: 0.05),
        removal: .easeIn(duration: 0.25)
    )

    // MARK: - Transition

    @Test func isAFullScreenCoverOfItsOwnKind() {
        let fade = Self.fade
        #expect(fade.isFullScreen)
        #expect(AnyModalRouter.Transition.fullScreen.isFullScreen)
        #expect(!AnyModalRouter.Transition.sheet.isFullScreen)
        #expect(fade != .fullScreen)
        #expect(fade != .sheet)
        #expect(fade == .fullScreen(transition: .slide))
        #expect(fade.hashValue == AnyModalRouter.Transition.fullScreen(transition: .slide).hashValue)
        #expect(AnyModalRouter.Transition.fullScreen.coverTransition == nil)
    }

    @Test func removalAnimationDefaultsToTheInsertionOne() {
        let cover = AnyModalRouter.Transition.fullScreen(transition: .opacity, animation: .linear(duration: 2)).coverTransition
        #expect(cover?.insertion == .linear(duration: 2))
        #expect(cover?.removal == .linear(duration: 2))
        #expect(Self.fade.coverTransition?.removal == .easeIn(duration: 0.25))
    }

    @Test func fillsTheFullScreenSlotNotTheSheetOne() {
        let parent = StubModalRouter(transition: .sheet)
        let cover = StubModalRouter(transition: Self.fade)
        parent.presented = cover
        #expect(parent.fullScreen === cover)
        #expect(parent.sheet == nil)
        #expect(parent.popover == nil)
    }

    // MARK: - Router only

    @Test func presentingIsImmediate() {
        let parent = StubModalRouter(transition: .sheet)
        let cover = StubModalRouter(transition: Self.fade)
        parent.presented = cover
        #expect(parent.presented === cover)
        #expect(cover.presenting === parent)
        #expect(!cover.isCoverContentShown)
    }

    /// Nothing is on screen to leave, so there is nothing to wait for.
    @Test func dismissingBeforeTheContentAppearedIsImmediate() {
        let parent = StubModalRouter(transition: .sheet)
        let cover = StubModalRouter(transition: Self.fade)
        parent.presented = cover
        parent.presented = nil
        #expect(parent.presented == nil)
        #expect(cover.presenting == nil)
    }

    /// With the flag up but no view showing the content — the window went
    /// away, say — the removal has nothing to animate and completes at once,
    /// so a dismissal never waits on a fade nobody would see.
    @Test func dismissingWithNoViewDoesNotWait() async throws {
        let parent = StubModalRouter(transition: .sheet)
        let cover = StubModalRouter(transition: Self.fade)
        parent.presented = cover
        cover.isCoverContentShown = true
        parent.presented = nil
        try await WindowHost.waitUntil { parent.presented == nil }
        #expect(cover.presenting == nil)
        #expect(!cover.isCoverContentShown)
    }

    /// A plain cover is untouched by any of this.
    @Test func plainCoverStillDismissesAtOnce() {
        let parent = StubModalRouter(transition: .sheet)
        let cover = StubModalRouter(transition: .fullScreen)
        parent.presented = cover
        cover.isCoverContentShown = true
        parent.presented = nil
        #expect(parent.presented == nil)
        #expect(cover.presenting == nil)
    }

    // MARK: - On screen

    @Test func theContentIsInsertedOnceTheCoverIsUp() async throws {
        let parent = StubModalRouter(transition: .sheet)
        let cover = RecordingModalRouter(transition: Self.fade)
        parent.presented = cover
        let window = try host(cover)
        defer { window.isHidden = true }

        try await WindowHost.waitUntil { cover.recorder.isOnScreen }
        #expect(cover.isCoverContentShown)
        #expect(cover.recorder.appearCount == 1)
    }

    @Test func dismissingRemovesTheContentBeforeTheCover() async throws {
        let parent = StubModalRouter(transition: .sheet)
        let cover = RecordingModalRouter(transition: Self.fade)
        parent.presented = cover
        let window = try host(cover)
        defer { window.isHidden = true }
        try await WindowHost.waitUntil { cover.recorder.isOnScreen }

        parent.presented = nil

        // The content is leaving; the cover stays up until it has gone.
        #expect(!cover.isCoverContentShown)
        #expect(parent.presented === cover)
        #expect(cover.presenting === parent)

        try await WindowHost.waitUntil { parent.presented == nil }
        #expect(cover.presenting == nil)
        try await WindowHost.waitUntil { !cover.recorder.isOnScreen }
    }

    @Test func theLastValueSetWhileLeavingWins() async throws {
        let parent = StubModalRouter(transition: .sheet)
        let cover = RecordingModalRouter(transition: Self.fade)
        let next = StubModalRouter(transition: .sheet)
        parent.presented = cover
        let window = try host(cover)
        defer { window.isHidden = true }
        try await WindowHost.waitUntil { cover.recorder.isOnScreen }

        parent.presented = nil
        parent.presented = next
        #expect(parent.presented === cover)
        #expect(next.presenting == nil)

        try await WindowHost.waitUntil { parent.presented === next }
        #expect(next.presenting === parent)
        #expect(cover.presenting == nil)
    }

    @Test func requestCloseLeavesThroughTheTransition() async throws {
        let parent = StubModalRouter(transition: .sheet)
        var closedWith: Int?? = .none
        let cover = RecordingFadingModalRouter { closedWith = .some($0) }
        parent.presented = cover
        let window = try host(cover)
        defer { window.isHidden = true }
        try await WindowHost.waitUntil { cover.recorder.isOnScreen }

        cover.requestClose(with: 7)

        #expect(closedWith == .some(7))
        #expect(!cover.isCoverContentShown)
        #expect(parent.presented === cover)
        try await WindowHost.waitUntil { parent.presented == nil }
        #expect(cover.presenting == nil)
    }

    // MARK: - Helpers

    /// The cover's content, as the cover would show it.
    private func host(_ cover: AnyModalRouter) throws -> UIWindow {
        let transition = try #require(cover.transition.coverTransition)
        return WindowHost.host(TransitionedCoverContent(router: cover, cover: transition))
    }
}

private final class RecordingFadingModalRouter: ModalRouterWithCloseReason<RecordingScreen, Int>, Recording {
    var recorder: ScreenRecorder { model.recorder }

    init(onWillCloseWithReason: ReasonHandler? = nil) {
        super.init(
            transition: .fullScreen(transition: .opacity, animation: .easeOut(duration: 0.05), removal: .easeIn(duration: 0.25)),
            onWillCloseWithReason: onWillCloseWithReason
        )
    }

    override func makeModel() -> RecordingModel { RecordingModel() }
}
