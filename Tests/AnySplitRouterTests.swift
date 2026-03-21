//
//  AnySplitRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AnySplitRouter")
@MainActor
struct AnySplitRouterTests {

    @Test func splitHasNavigationStackProperties() {
        let root = StubPushRouter()
        let split = AnySplitRouter(root: root)
        // AnySplitRouter inherits from AnyNavigationStackRouter
        #expect(split.root === root)
    }

    @Test func rootStackIsSplit() {
        let root = StubPushRouter()
        let split = AnySplitRouter(root: root)
        #expect(root.stack === split)
        #expect(root.split === split)
    }

    @Test func pushFromRootGetsSplitAsStack() {
        let root = StubPushRouter()
        let split = AnySplitRouter(root: root)
        let detail = StubPushRouter()
        root.pushed = detail
        #expect(detail.stack === split)
        #expect(detail.split === split)
    }

    @Test func columnVisibilityStored() {
        let root = StubPushRouter()
        let split = AnySplitRouter(
            columnVisibility: .doubleColumn,
            root: root
        )
        #expect(split.columnVisibility == .doubleColumn)
    }

    @Test func styleStored() {
        let root = StubPushRouter()
        let split = AnySplitRouter(style: .balanced, root: root)
        #expect(split.style == .balanced)
    }

    @Test func splitIsModalRouter() {
        let root = StubPushRouter()
        let split = AnySplitRouter(root: root)
        let presented = StubModalRouter(transition: .sheet)
        split.presented = presented
        #expect(presented.presenting === split)
        #expect(split.presented === presented)
    }

    @Test func defaultTransitionIsFullScreen() {
        let root = StubPushRouter()
        let split = AnySplitRouter(root: root)
        #expect(split.transition == .fullScreen)
    }

    @Test func pushedFromRootPropagatesSplit() {
        let root = StubPushRouter()
        let split = AnySplitRouter(root: root)
        let b = StubPushRouter()
        let c = StubPushRouter()
        root.pushed = b
        b.pushed = c
        // All should have split as their stack and split
        #expect(b.split === split)
        #expect(c.split === split)
    }

    @Test func defaultStyleIsAutomatic() {
        let root = StubPushRouter()
        let split = AnySplitRouter(root: root)
        #expect(split.style == .automatic)
    }
}
