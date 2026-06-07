//
//  AnyWindowRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 24.04.2026.
//

import SwiftUI
import UIKit

// MARK: - Router

/// A router that displays `AnyModalRouter` content in separate `UIWindow` layers.
///
/// Each child router is presented in its own `UIWindow` stacked above the current one.
/// This makes the child view hierarchy completely independent — no modal presentation
/// conflicts, no interference with sheets/alerts on the main window.
///
/// Typical use-cases:
/// - Showing alerts in a separate window so they aren't blocked by existing modals.
/// - Showing transparent overlay windows for banners / toasts.
///
/// Usage:
/// ```swift
/// let windowRouter = AnyWindowRouter(current: myAppRouter)
///
/// // In your App.body:
/// windowRouter.makeScene()
///
/// // Show a child window (e.g. an alert overlay):
/// windowRouter.addChild(alertRouter, level: .alert)
///
/// // Remove it:
/// windowRouter.removeChild(alertRouter)
/// ```
@Observable
@MainActor
open class AnyWindowRouter: Identifiable {

    public struct ChildConfig: Sendable {
        public var level: UIWindow.Level
        public var backgroundColor: UIColor
        public var frameResolver: (@Sendable (_ maxFrame: CGRect) -> CGRect)?

        public init(
            level: UIWindow.Level = .alert,
            backgroundColor: UIColor = .clear,
            frameResolver: (@Sendable (_ maxFrame: CGRect) -> CGRect)? = nil
        ) {
            self.level = level
            self.backgroundColor = backgroundColor
            self.frameResolver = frameResolver
        }
    }

    // MARK: <Identifiable>

    public let id = UUID()

    // MARK: State

    /// The router whose content is displayed in the main window.
    public private(set) var current: AnyModalRouter

    /// All child routers, each displayed in its own `UIWindow`.
    public private(set) var children: [AnyModalRouter] = []

    /// Active `UIWindow` instances keyed by router id.
    @ObservationIgnored
    private var windows: [UUID: UIWindow] = [:]

    /// Child configurations keyed by router id.
    @ObservationIgnored
    private var configs: [UUID: ChildConfig] = [:]

    /// The window scene captured from the view hierarchy.
    @ObservationIgnored
    public internal(set) var windowScene: UIWindowScene?

    // MARK: Initialization

    public init(current: AnyModalRouter) {
        self.current = current
    }

    #if DEBUG
    deinit {
        print("☠️ [WINDOW ROUTER] \(Self.self) deinit")
    }
    #endif

    // MARK: Child Management

    /// Adds a child router displayed in a new `UIWindow` above the current one.
    ///
    /// - Parameters:
    ///   - child: The router whose view will be shown in the new window.
    ///   - config: Configuration for the child window (level, background color, frame).
    open func addChild(
        _ child: AnyModalRouter,
        config: ChildConfig = ChildConfig()
    ) {
        guard !children.contains(where: { $0.id == child.id }) else { return }
        children.append(child)
        configs[child.id] = config

        guard let scene = windowScene else { return }
        presentWindow(for: child, in: scene)
    }

    /// Removes a child router and tears down its `UIWindow`.
    open func removeChild(_ child: AnyModalRouter) {
        dismissWindow(for: child)
        children.removeAll { $0.id == child.id }
        configs[child.id] = nil
    }

    /// Removes all child windows.
    open func removeAllChildren() {
        for child in children {
            dismissWindow(for: child)
        }
        children.removeAll()
        configs.removeAll()
    }

    // MARK: Makers

    /// Creates a `View` showing the current router's content.
    /// Child windows are managed via UIKit and appear above this view automatically.
    public func makeView() -> some View {
        AnyWindowRootView(router: self)
    }

    /// Returns a `Scene` wrapping this router in a `WindowGroup`.
    public func makeScene() -> some Scene {
        AnyWindowScene(router: self)
    }

    // MARK: Private

    fileprivate func sceneDidBecomeAvailable(_ scene: UIWindowScene) {
        windowScene = scene
        for child in children where windows[child.id] == nil {
            presentWindow(for: child, in: scene)
        }
    }

    private func presentWindow(
        for child: AnyModalRouter,
        in scene: UIWindowScene
    ) {
        let config = configs[child.id] ?? ChildConfig()

        let hosting = UIHostingController(rootView: child.makeView())
        hosting.view.backgroundColor = config.backgroundColor

        let window = PassthroughWindow(windowScene: scene)
        window.windowLevel = config.level
        window.backgroundColor = .clear
        window.rootViewController = hosting

        if let frameResolver = config.frameResolver {
            window.frame = frameResolver(scene.screen.bounds)
            window.isPassthroughEnabled = false
        }

        window.isHidden = false
        windows[child.id] = window
    }

    private func dismissWindow(for child: AnyModalRouter) {
        guard let window = windows.removeValue(forKey: child.id) else { return }
        // Defer hiding so the current touch event is fully consumed by this window
        // before it is removed. Otherwise the touch falls through to the window below.
        DispatchQueue.main.async {
            window.isHidden = true
            window.rootViewController = nil
        }
    }
}

// MARK: - Scene

private struct AnyWindowScene: Scene {

    @State var router: AnyWindowRouter

    var body: some Scene {
        WindowGroup {
            router.makeView()
        }
    }
}

// MARK: - View

private struct AnyWindowRootView: View {

    @State var router: AnyWindowRouter

    var body: some View {
        router.current.makeView()
            .id(router.current.id)
            .background(WindowSceneReader(router: router))
    }
}

/// An invisible UIKit bridge that captures the `UIWindowScene` from the view hierarchy
/// and passes it to the router so child `UIWindow` instances can be created.
private struct WindowSceneReader: UIViewRepresentable {

    let router: AnyWindowRouter

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            guard let scene = uiView.window?.windowScene else { return }
            if router.windowScene == nil {
                router.sceneDidBecomeAvailable(scene)
            }
        }
    }
}

// MARK: - Passthrough Window

/// A `UIWindow` subclass that optionally passes touches through to windows below
/// when the touch lands on empty areas (system container views between the window
/// and the root view controller's view).
///
/// When `isPassthroughEnabled` is `true`, only touches that land on actual content
/// inside the root view controller are captured; everything else falls through.
open class PassthroughWindow: UIWindow {

    // MARK: Properties

    public var isPassthroughEnabled: Bool = true

    // MARK: Life Cycle

    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isPassthroughEnabled else {
            return super.hitTest(point, with: event)
        }
        guard let rootViewController,
              let view = super.hitTest(point, with: event)
        else { return nil }
        // There is a strange view on iPadOS between window and root view controller that
        // intercepts touches. This check determines if we hit it or any other system overlay.
        guard !rootViewController.view.hasSuperview(view) else { return nil }
        return view
    }
}

private extension UIView {
    func hasSuperview(_ view: UIView) -> Bool {
        var superview = self.superview
        while let current = superview {
            if current === view {
                return true
            }
            superview = current.superview
        }
        return false
    }
}

// AnyWindowRouter
// WindowRouter<Model>: AnyWindowRouter
