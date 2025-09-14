//
//  AnyModalRouter.swift
//  SUISimpleRouting
//
//  Created by Yevhenii Lytvynenko on 15.11.2024.
//

import SwiftUI

// MARK: - Router

@Observable
open class AnyModalRouter: AnyRouter {

    // MARK: State
    
    /// Current modal transition
    public let transition: Transition
    
    /// Router which presents this router.
    @ObservationIgnored
    public internal(set) weak var presenting: AnyModalRouter?

    /// Router presented from this router.
    public var presented: AnyModalRouter? {
        willSet {
            // Clean up old relationship first
            if let oldPresented = presented {
                oldPresented.presenting = nil
            }
            
            // Set up new relationship
            if let newPresented = newValue {
                newPresented.presenting = self
            }
        }
    }

    // MARK: Initialization

    init(transition: Transition, presented: AnyModalRouter? = nil) {
        self.transition = transition
        self._presented = presented
        super.init()
    }
    
    // Convenience initializers
    public static func sheet(presented: AnyModalRouter? = nil) -> Self {
        Self(transition: .sheet, presented: presented)
    }
    
    public static func fullScreen(presented: AnyModalRouter? = nil) -> Self {
        Self(transition: .fullScreen, presented: presented)
    }
    
    public static func popover(presented: AnyModalRouter? = nil) -> Self {
        Self(transition: .popover, presented: presented)
    }

    // MARK: Makers

    public final func makeView() -> some View {
        AnyModalView(router: self)
    }
    
    // MARK: - Modal Presentation Convenience Methods
    
    /// Presents a router modally
    public func present(_ router: AnyModalRouter) {
        presented = router
    }
    
    /// Dismisses the currently presented router
    public func dismiss() {
        presented = nil
    }
    
    /// Dismisses all presented routers in the chain
    public func dismissAll() {
        var current = self
        while current.presented != nil {
            let next = current.presented
            current.presented = nil
            if let next = next {
                current = next
            }
        }
    }
    
    /// Returns the depth of the modal presentation chain
    public var modalDepth: Int {
        var depth = 0
        var current = self
        while let presented = current.presented {
            depth += 1
            current = presented
        }
        return depth
    }
}

private extension AnyModalRouter {

    var sheet: AnyModalRouter? {
        get { presented?.transition == .sheet ? presented : nil }
        set { presented = newValue }
    }

    var fullScreen: AnyModalRouter? {
        get { presented?.transition == .fullScreen ? presented : nil }
        set { presented = newValue }
    }

    var popover: AnyModalRouter? {
        get { presented?.transition == .popover ? presented : nil }
        set { presented = newValue }
    }
}

public extension AnyModalRouter {

    enum Transition: Hashable, Sendable {
        case sheet
        case fullScreen
        case popover
    }
}

// MARK: - View

struct AnyModalView: View {

    @State var router: AnyModalRouter

    var body: some View {
        router.makeContentView()
            .sheet(
                item: $router.sheet,
                content: { $0.makeView() }
            )
            .fullScreenCover(
                item: $router.fullScreen,
                content: { $0.makeView() }
            )
            .popover(
                item: $router.popover,
                attachmentAnchor: .rect(.bounds), // TODO: - Pass from transition
                arrowEdge: .bottom, // TODO: - Pass from transition
                content: { $0.makeView() }
            )
    }
}
