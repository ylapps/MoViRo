//
//  ScreenLifecycleTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

/// Renders routers in a window: what is pinned here is how the screens
/// behave, which no router-level test can see.
@Suite("Screen lifecycle", .serialized)
@MainActor
struct ScreenLifecycleTests {

    /// Presentations wait for the content to appear. That used to be done by
    /// swapping the whole view once it had, which built the content twice: it
    /// appeared, disappeared and was built again with fresh state.
    @Test(arguments: ScreenKind.allCases)
    func contentIsBuiltOnce(kind: ScreenKind) async throws {
        let router = kind.makeModal()
        let window = WindowHost.host(router.makeView())
        defer { window.isHidden = true }

        try await WindowHost.waitUntil { router.recorder.isOnScreen }
        try await WindowHost.settle()
        #expect(router.recorder.appearCount == 1)
        #expect(router.recorder.disappearCount == 0)
    }

    /// The swap also tore down the NavigationStack inside the content, so a
    /// push set before the stack appeared was built twice as well.
    @Test(arguments: ScreenKind.allCases)
    func presetPushIsBuiltOnceAndKept(kind: ScreenKind) async throws {
        let root = kind.makePush()
        let pushed = kind.makePush()
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
