//
//  ScreenUpdateTests.swift
//  MoviroTests
//

@testable import Moviro
import SwiftUI
import Testing

/// How much of a screen SwiftUI re-evaluates when something around it changes,
/// and whether the screen follows its router. Hosted in a window, so the
/// numbers are what an app would see.
@Suite("Screen updates", .serialized)
@MainActor
struct ScreenUpdateTests {

    /// Changing `presented` is the presentation modifier's business; the
    /// screen's own body has no reason to run again.
    @Test(arguments: ScreenKind.allCases)
    func presentedChangeDoesNotReevaluateContent(kind: ScreenKind) async throws {
        let router = kind.makeModal()
        let window = WindowHost.host(router.makeView())
        defer { window.isHidden = true }
        try await WindowHost.waitUntil { router.recorder.isOnScreen }
        try await WindowHost.settle()
        let before = router.recorder.bodyEvaluations

        router.presented = AlertRouter(config: .init(title: "Hi"))
        try await WindowHost.settle()
        router.presented = nil
        try await WindowHost.settle()

        #expect(router.recorder.bodyEvaluations == before)
    }

    /// Same for `pushed` on a push router inside a stack.
    @Test(arguments: ScreenKind.allCases)
    func pushedChangeDoesNotReevaluateContent(kind: ScreenKind) async throws {
        let root = kind.makePush()
        let window = WindowHost.host(NavigationStackRouter(root: root, transition: .fullScreen).makeView())
        defer { window.isHidden = true }
        try await WindowHost.waitUntil { root.recorder.isOnScreen }
        try await WindowHost.settle()
        let before = root.recorder.bodyEvaluations

        let pushed = kind.makePush()
        root.pushed = pushed
        try await WindowHost.waitUntil { pushed.recorder.isOnScreen }
        try await WindowHost.settle()
        root.pushed = nil
        try await WindowHost.waitUntil { !pushed.recorder.isOnScreen }
        try await WindowHost.settle()

        #expect(root.recorder.bodyEvaluations == before)
    }

    /// A parent re-evaluating its body with the same router in hand must not
    /// rebuild the router's screen.
    @Test(arguments: ScreenKind.allCases)
    func parentReevaluationDoesNotRebuildScreen(kind: ScreenKind) async throws {
        let router = kind.makeModal()
        let ticker = Ticker()
        let window = WindowHost.host(TickingParent(ticker: ticker) { router.makeView() })
        defer { window.isHidden = true }
        try await WindowHost.waitUntil { router.recorder.isOnScreen }
        try await WindowHost.settle()
        let before = router.recorder.bodyEvaluations

        for _ in 0..<5 {
            ticker.tick += 1
            try await WindowHost.settle(.milliseconds(50))
        }

        #expect(router.recorder.bodyEvaluations == before)
        #expect(router.recorder.appearCount == 1)
    }

    /// Replacing a pushed router with another of the same kind shows the new
    /// one. The screen follows the router it is handed: it used to keep the
    /// first one it was given as `@State`, and the second never appeared.
    @Test(arguments: ScreenKind.allCases)
    func replacedPushedRouterShowsTheNewScreen(kind: ScreenKind) async throws {
        let root = kind.makePush()
        let first = kind.makePush()
        root.pushed = first
        let window = WindowHost.host(NavigationStackRouter(root: root, transition: .fullScreen).makeView())
        defer { window.isHidden = true }
        try await WindowHost.waitUntil { first.recorder.isOnScreen }
        try await WindowHost.settle()

        let second = kind.makePush()
        root.pushed = second
        try await WindowHost.waitUntil { second.recorder.isOnScreen }
        try await WindowHost.settle()

        #expect(second.recorder.isOnScreen)
        #expect(!first.recorder.isOnScreen)
    }

    /// A modal switch router swaps its whole screen, once.
    @Test(arguments: ScreenKind.allCases)
    func modalSwitchShowsTheNewCurrent(kind: ScreenKind) async throws {
        let first = kind.makeModal()
        let switcher = AnyModalSwitchRouter(current: first, transition: .fullScreen)
        let window = WindowHost.host(switcher.makeView())
        defer { window.isHidden = true }
        try await WindowHost.waitUntil { first.recorder.isOnScreen }
        try await WindowHost.settle()

        let second = kind.makeModal()
        switcher.current = second
        try await WindowHost.waitUntil { second.recorder.isOnScreen }
        try await WindowHost.settle()

        #expect(second.recorder.isOnScreen)
        #expect(!first.recorder.isOnScreen)
        #expect(first.recorder.appearCount == 1)
        #expect(second.recorder.appearCount == 1)
    }
}

// MARK: - A parent that re-evaluates on demand

@Observable
@MainActor
private final class Ticker {
    var tick = 0
}

private struct TickingParent<Content: View>: View {
    let ticker: Ticker
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            Text("tick \(ticker.tick)")
            content()
        }
    }
}
