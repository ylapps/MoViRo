//
//  CollectionViewCell.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 25.01.2026.
//

open class CollectionViewCell<Content: BaseView>: UICollectionViewCell where Content.Model: AnyObject {

    // MARK: Properties

    public var model: Content.Model? {
        didSet {
            guard model !== oldValue else { return }
            update(model: model, insets: contentInsets)
        }
    }

    public var contentInsets: NSDirectionalEdgeInsets = .zero {
        didSet {
            guard contentInsets != oldValue else { return }
            update(model: model, insets: contentInsets)
        }
    }

    // MARK: Updates

    private func update(model: Content.Model?, insets: NSDirectionalEdgeInsets) {
        if let model {
            contentConfiguration = UIHostingConfiguration {
                Content.with(model)
            }
            .margins(.top, insets.top)
            .margins(.bottom, insets.bottom)
            .margins(.leading, insets.leading)
            .margins(.trailing, insets.trailing)
        } else {
            contentConfiguration = nil
        }
    }
}
