//
//  AnyWindowRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AnyWindowRouter")
@MainActor
struct AnyWindowRouterTests {

    @Test func initialState() {
        let current = StubModalRouter(transition: .fullScreen)
        let router = AnyWindowRouter(current: current)
        #expect(router.current === current)
        #expect(router.children.isEmpty)
    }

    @Test func addChild() {
        let current = StubModalRouter(transition: .fullScreen)
        let router = AnyWindowRouter(current: current)
        let child = StubModalRouter(transition: .sheet)
        router.addChild(child)
        #expect(router.children.count == 1)
        #expect(router.children.first === child)
    }

    @Test func addMultipleChildren() {
        let current = StubModalRouter(transition: .fullScreen)
        let router = AnyWindowRouter(current: current)
        let child1 = StubModalRouter(transition: .sheet)
        let child2 = StubModalRouter(transition: .fullScreen)
        router.addChild(child1)
        router.addChild(child2)
        #expect(router.children.count == 2)
    }

    @Test func addSameChildTwiceIsIgnored() {
        let current = StubModalRouter(transition: .fullScreen)
        let router = AnyWindowRouter(current: current)
        let child = StubModalRouter(transition: .sheet)
        router.addChild(child)
        router.addChild(child)
        #expect(router.children.count == 1)
    }

    @Test func removeChild() {
        let current = StubModalRouter(transition: .fullScreen)
        let router = AnyWindowRouter(current: current)
        let child = StubModalRouter(transition: .sheet)
        router.addChild(child)
        router.removeChild(child)
        #expect(router.children.isEmpty)
    }

    @Test func removeNonExistentChildIsNoOp() {
        let current = StubModalRouter(transition: .fullScreen)
        let router = AnyWindowRouter(current: current)
        let child = StubModalRouter(transition: .sheet)
        router.removeChild(child) // should not crash
        #expect(router.children.isEmpty)
    }

    @Test func removeAllChildren() {
        let current = StubModalRouter(transition: .fullScreen)
        let router = AnyWindowRouter(current: current)
        router.addChild(StubModalRouter(transition: .sheet))
        router.addChild(StubModalRouter(transition: .fullScreen))
        router.removeAllChildren()
        #expect(router.children.isEmpty)
    }

    @Test func identifiableConformance() {
        let a = AnyWindowRouter(current: StubModalRouter(transition: .fullScreen))
        let b = AnyWindowRouter(current: StubModalRouter(transition: .fullScreen))
        #expect(a.id != b.id)
    }
}
