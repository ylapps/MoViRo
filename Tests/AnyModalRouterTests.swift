//
//  AnyModalRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AnyModalRouter Graph Wiring")
@MainActor
struct AnyModalRouterTests {

    @Test func initialState() {
        let router = StubModalRouter(transition: .sheet)
        #expect(router.presenting == nil)
        #expect(router.presented == nil)
        #expect(router.transition == .sheet)
    }

    @Test func initWithPresented() {
        let child = StubModalRouter(transition: .sheet)
        let parent = StubModalRouter(transition: .fullScreen, presented: child)
        #expect(parent.presented === child)
        #expect(child.presenting === parent)
    }

    @Test func settingPresentedEstablishesBackReference() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        a.presented = b
        #expect(b.presenting === a)
        #expect(a.presented === b)
    }

    @Test func replacingPresentedClearsOldBackReference() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        let c = StubModalRouter(transition: .sheet)
        a.presented = b
        a.presented = c
        #expect(b.presenting == nil)
        #expect(c.presenting === a)
        #expect(a.presented === c)
    }

    @Test func settingPresentedToNilClearsBackReference() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        a.presented = b
        a.presented = nil
        #expect(b.presenting == nil)
        #expect(a.presented == nil)
    }

    @Test func chainedPresentations() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        let c = StubModalRouter(transition: .sheet)
        a.presented = b
        b.presented = c
        #expect(a.presented === b)
        #expect(b.presented === c)
        #expect(b.presenting === a)
        #expect(c.presenting === b)
    }

    @Test func chainedPresentationMiddleRemoval() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        let c = StubModalRouter(transition: .sheet)
        a.presented = b
        b.presented = c
        // Remove b from a
        a.presented = nil
        #expect(b.presenting == nil)
        // C remains as b's presented — b is just detached from a
        #expect(b.presented === c)
        #expect(c.presenting === b)
    }

    @Test func transitionTypes() {
        let sheet = StubModalRouter(transition: .sheet)
        let full = StubModalRouter(transition: .fullScreen)
        let pop = StubModalRouter(transition: .popover())
        #expect(sheet.transition == .sheet)
        #expect(full.transition == .fullScreen)
        #expect(pop.transition == .popover())
    }

    @Test func identifiableConformance() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        #expect(a.id != b.id)
    }

    @Test func equatableConformance() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        #expect(a == a)
        #expect(a != b)
    }

    @Test func selfPresentation() {
        let a = StubModalRouter(transition: .sheet)
        // willSet: a.presenting = nil, then a.presenting = a
        a.presented = a
        // Should not crash; a presents itself
        #expect(a.presented === a)
        #expect(a.presenting === a)
    }

    @Test func hashableConformance() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        var set = Set<AnyModalRouter>()
        set.insert(a)
        set.insert(b)
        set.insert(a) // duplicate
        #expect(set.count == 2)
        #expect(set.contains(a))
        #expect(set.contains(b))
    }

    @Test func transitionIsImmutable() {
        let router = StubModalRouter(transition: .popover())
        #expect(router.transition == .popover())
        // transition is `let` — cannot change after init
    }

    @Test func presentedWillSetClearsChainCorrectly() {
        // A presents B, B presents C, then A presents D
        // B should be disconnected, but B→C chain should remain intact
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        let c = StubModalRouter(transition: .sheet)
        let d = StubModalRouter(transition: .sheet)
        a.presented = b
        b.presented = c
        a.presented = d
        #expect(b.presenting == nil)
        #expect(d.presenting === a)
        #expect(b.presented === c) // B→C chain preserved
        #expect(c.presenting === b) // C still points to B
    }
}
