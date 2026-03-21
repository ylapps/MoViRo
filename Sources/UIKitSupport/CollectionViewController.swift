//
//  CollectionViewController.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 25.01.2026.
//

open class CollectionViewController<Model>: UICollectionViewController, ModelHolding {

    // MARK: State

    public let model: Model

    // MARK: Initialization

    required public init(model: Model) {
        self.model = model
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.collectionViewLayout = makeCollectionViewLayout()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBinding()
    }

    // MARK: Setup

    open func setupViews() {}
    open func setupBinding() {}

    open func makeCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewFlowLayout()
    }
}
