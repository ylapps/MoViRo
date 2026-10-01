//
//  AnyModalViewTests.swift
//  MoviroTests
//

@testable import Moviro
import SwiftUI
import Testing
import UIKit

/// Renders routers in a window: what is pinned here is how the views behave,
/// which no router-level test can see.
///
/// The test process has no window scene, and a window without one does not
/// present a sheet that is asked for after its content appeared — an app
/// does — so presentations are not covered here.
@Suite("AnyModalView", .serialized)
@MainActor
struct AnyModalViewTests {

    /// Presentations wait for the content to appear. That used to be done by
    /// swapping the whole view once it had, which built the content twice: it
    /// appeared, disappeared and was built again with fresh state.
    @Test func contentIsBuiltOnce() async throws {
        let router = RecordingModalRouter()
        let window = host(router)
        defer { window.isHidden = true }

        try await waitUntil { router.lifecycle.isOnScreen }
        try await settle()
        #expect(router.lifecycle.appearCount == 1)
        #expect(router.lifecycle.disappearCount == 0)
    }

    /// The swap also tore down the NavigationStack inside the content, so a
    /// push set before the stack appeared was built twice as well.
    @Test func presetPushIsBuiltOnceAndKept() async throws {
        let root = RecordingPushRouter()
        let pushed = RecordingPushRouter()
        root.pushed = pushed
        let window = host(NavigationStackRouter(root: root, transition: .fullScreen))
        defer { window.isHidden = true }

        try await waitUntil { pushed.lifecycle.isOnScreen }
        try await settle()
        #expect(root.pushed === pushed)
        #expect(pushed.lifecycle.appearCount == 1)
        #expect(pushed.lifecycle.disappearCount == 0)
    }
}

// MARK: - Helpers

private extension AnyModalViewTests {

    func host(_ router: AnyModalRouter) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = UIHostingController(rootView: router.makeView())
        window.makeKeyAndVisible()
        return window
    }

    func waitUntil(
        timeout: Duration = .seconds(5),
        sourceLocation: SourceLocation = #_sourceLocation,
        _ condition: () -> Bool
    ) async throws {
        let deadline = ContinuousClock.now + timeout
        while !condition() {
            guard ContinuousClock.now < deadline else {
                Issue.record("Timed out waiting for the condition", sourceLocation: sourceLocation)
                return
            }
            try await Task.sleep(for: .milliseconds(10))
        }
    }

    /// What these tests rule out would happen within a turn or two of the
    /// first appearance, so there is no event to wait for, only time.
    func settle() async throws {
        try await Task.sleep(for: .milliseconds(300))
    }
}

// MARK: - Recording Routers

@MainActor
private final class Lifecycle {
    var appearCount = 0
    var disappearCount = 0

    var isOnScreen: Bool { appearCount > disappearCount }
}

private struct LifecycleView: View {
    let lifecycle: Lifecycle

    var body: some View {
        Color.clear
            .onAppear { lifecycle.appearCount += 1 }
            .onDisappear { lifecycle.disappearCount += 1 }
    }
}

private final class RecordingModalRouter: AnyModalRouter {
    let lifecycle = Lifecycle()

    init() {
        super.init(transition: .fullScreen)
    }

    override func makeContentView() -> AnyView {
        AnyView(LifecycleView(lifecycle: lifecycle))
    }
}

private final class RecordingPushRouter: AnyPushRouter {
    let lifecycle = Lifecycle()

    override func makeContentView() -> AnyView {
        AnyView(LifecycleView(lifecycle: lifecycle))
    }
}
