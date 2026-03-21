//
//  ModelComposer.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 14.02.2026.
//

import Combine

public final class ModelComposer<ItemID: Hashable & Sendable, ItemViewModel: AnyObject> {

    // MARK: Types

    public typealias ItemViewModelProvider = (ItemID) -> ItemViewModel

    // MARK: State

    private let itemViewModelProvider: ItemViewModelProvider
    private var viewModels = [ItemID: Weak<ItemViewModel>]()
    @Published public private(set) var itemIDs: [ItemID]?
    public var itemIDsPublisher: AnyPublisher<[ItemID]?, Never> { $itemIDs.removeDuplicates().eraseToAnyPublisher() }

    // MARK: Initialization

    public init(itemViewModelProvider: @escaping ItemViewModelProvider) {
        self.itemViewModelProvider = itemViewModelProvider
    }

    // MARK: Actions

    public func update(items: [ItemID]?) {
        guard self.itemIDs != items else { return }
        self.itemIDs = items
    }

    public func itemViewModel(for itemId: ItemID) -> ItemViewModel {
        let existingViewModel = existingViewModel(for: itemId)
        let viewModel = existingViewModel ?? itemViewModelProvider(itemId)
        viewModels[itemId] = .init(viewModel)
        return viewModel
    }

    public func existingViewModel(for itemId: ItemID) -> ItemViewModel? {
        viewModels[itemId]?.wrapped
    }

    public func existingViewModels() -> [ItemViewModel] {
        viewModels.values.compactMap(\.wrapped)
    }
}


// MARK: - Weak

private struct Weak<Wrapped> where Wrapped: AnyObject {

    // MARK: Properties

    private(set) weak var wrapped: Wrapped?

    // MARK: Initialization

    init(_ wrapped: Wrapped?) {
        self.wrapped = wrapped
    }
}
