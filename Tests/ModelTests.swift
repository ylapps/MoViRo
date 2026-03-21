//
//  ModelTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("Model<Router>")
@MainActor
struct ModelTests {

    @Test func modelHoldsWeakRouterReference() {
        let model = createModelWithRouter()
        #expect(model.router == nil)
    }

    /// Creates a model with a router that goes out of scope when this function returns.
    @inline(never)
    private func createModelWithRouter() -> Model<StubModalRouter> {
        let router = StubModalRouter(transition: .sheet)
        let model = Model<StubModalRouter>(router: router)
        #expect(model.router != nil)
        return model
    }

    @Test func modelWithNeverRouter() {
        let model = Model<Never>()
        #expect(model.id != UUID()) // has a valid id
    }

    @Test func modelEquality() {
        let a = Model<Never>()
        let b = Model<Never>()
        #expect(a == a)
        #expect(a != b)
    }

    @Test func modelHashing() {
        let a = Model<Never>()
        let b = Model<Never>()
        var set = Set<Model<Never>>()
        set.insert(a)
        set.insert(b)
        #expect(set.count == 2)
        #expect(set.contains(a))
        #expect(set.contains(b))
    }

    @Test func modelWithNilRouter() {
        let model = Model<StubModalRouter>(router: nil)
        #expect(model.router == nil)
    }

    @Test func modelWithNonNilRouterIsAccessible() {
        let router = StubModalRouter(transition: .sheet)
        let model = Model<StubModalRouter>(router: router)
        #expect(model.router === router)
    }

    @Test func modelInheritsAnyModelBehavior() {
        let model = Model<Never>()
        // Model inherits from AnyModel — verify it has appear tracking
        model.isAppeared = true
        model.isAppeared = false
    }

    @Test func modelIdIsStable() {
        let model = Model<Never>()
        let id1 = model.id
        let id2 = model.id
        #expect(id1 == id2)
    }
}
