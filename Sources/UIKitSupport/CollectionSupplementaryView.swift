//
//  CollectionSupplementaryView.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 25.01.2026.
//

open class CollectionSupplementaryView<Content: BaseView>: UICollectionReusableView where Content.Model: AnyObject {

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

    private weak var content: UIView?

    // MARK: Updates

    private func update(model: Content.Model?, insets: NSDirectionalEdgeInsets) {
        guard let model else {
            content?.removeFromSuperview()
            return
        }
        let hostingConfiguration = UIHostingConfiguration { Content.with(model) }
            .margins(.top, insets.top)
            .margins(.bottom, insets.bottom)
            .margins(.leading, insets.leading)
            .margins(.trailing, insets.trailing)
        let content = hostingConfiguration.makeContentView()
        addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.content = content
    }
}
