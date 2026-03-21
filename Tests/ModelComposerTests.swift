//
//  ModelComposerTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("ModelComposer")
@MainActor
struct ModelComposerTests {

    @Test func itemViewModelCreatesNew() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        let vm = composer.itemViewModel(for: "a")
        #expect(vm.id == "a")
    }

    @Test func itemViewModelReturnsCachedWhileStronglyHeld() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        let vm1 = composer.itemViewModel(for: "a")
        let vm2 = composer.itemViewModel(for: "a")
        #expect(vm1 === vm2)
    }

    @Test func itemViewModelCreatesNewAfterDeallocation() {
        var factoryCallCount = 0
        let composer = ModelComposer<String, StubViewModel> { id in
            factoryCallCount += 1
            return StubViewModel(id: id)
        }
        // First call — factory invoked
        releaseViewModel(composer: composer, id: "a")
        #expect(factoryCallCount == 1)
        // Cached weak ref is now nil, so factory must be invoked again
        let vm2 = composer.itemViewModel(for: "a")
        _ = vm2
        #expect(factoryCallCount == 2)
    }

    /// Helper that creates and releases a view model within an autoreleasepool.
    private func releaseViewModel(composer: ModelComposer<String, StubViewModel>, id: String) {
        autoreleasepool {
            _ = composer.itemViewModel(for: id)
        }
    }

    @Test func existingViewModelReturnsNilForUnknown() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        #expect(composer.existingViewModel(for: "unknown") == nil)
    }

    @Test func existingViewModelReturnsCachedInstance() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        let vm = composer.itemViewModel(for: "a")
        let existing = composer.existingViewModel(for: "a")
        #expect(existing === vm)
    }

    @Test func existingViewModelReturnsNilAfterDeallocation() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        releaseViewModel(composer: composer, id: "a")
        #expect(composer.existingViewModel(for: "a") == nil)
    }

    @Test func existingViewModelsReturnsAllLive() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        let vmA = composer.itemViewModel(for: "a")
        releaseViewModel(composer: composer, id: "b")
        let live = composer.existingViewModels()
        #expect(live.count == 1)
        #expect(live.first === vmA)
    }

    @Test func updateItems() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        composer.update(items: ["a", "b"])
        #expect(composer.itemIDs == ["a", "b"])
    }

    @Test func updateItemsStoresDuplicatesAsIs() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        composer.update(items: ["a", "a"])
        // The code does NOT deduplicate — stores as-is
        #expect(composer.itemIDs == ["a", "a"])
    }

    @Test func updateItemsSkipsWhenEqual() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        composer.update(items: ["a"])
        composer.update(items: ["a"]) // guard short-circuits
        #expect(composer.itemIDs == ["a"])
    }

    @Test func updateItemsNil() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        composer.update(items: ["a"])
        composer.update(items: nil)
        #expect(composer.itemIDs == nil)
    }

    @Test func multipleIDsIndependentCaching() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        let vmA = composer.itemViewModel(for: "a")
        let vmB = composer.itemViewModel(for: "b")
        #expect(vmA !== vmB)
        #expect(vmA.id == "a")
        #expect(vmB.id == "b")
    }

    @Test func itemViewModelAlwaysReturnsNonNil() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        // Even after cache miss, always creates new
        releaseViewModel(composer: composer, id: "x")
        let vm2 = composer.itemViewModel(for: "x")
        #expect(vm2.id == "x")
    }

    @Test func existingViewModelsFiltersOutDeallocated() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        let vmA = composer.itemViewModel(for: "a")
        releaseViewModel(composer: composer, id: "b")
        releaseViewModel(composer: composer, id: "c")
        let live = composer.existingViewModels()
        // Only "a" should be alive
        #expect(live.count == 1)
        #expect(live.first === vmA)
    }

    @Test func existingViewModelForDifferentIds() {
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        let vmA = composer.itemViewModel(for: "a")
        let vmB = composer.itemViewModel(for: "b")
        #expect(composer.existingViewModel(for: "a") === vmA)
        #expect(composer.existingViewModel(for: "b") === vmB)
    }

    @Test func itemViewModelRefreshesCacheEntry() {
        // Calling itemViewModel(for:) with a still-alive entry returns same instance
        let composer = ModelComposer<String, StubViewModel> { id in
            StubViewModel(id: id)
        }
        let vm1 = composer.itemViewModel(for: "a")
        let vm2 = composer.itemViewModel(for: "a")
        let vm3 = composer.itemViewModel(for: "a")
        #expect(vm1 === vm2)
        #expect(vm2 === vm3)
    }
}
