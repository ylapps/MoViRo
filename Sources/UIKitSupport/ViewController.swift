//
//  ViewController.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 25.01.2026.
//

open class ViewController<Model>: UIViewController, ModelHolding {

    public let model: Model

    required public init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupViews()
        setupBinding()
    }

    open func setupHierarchy() {}
    open func setupLayout() {}
    open func setupViews() {}
    open func setupBinding() {}
}
