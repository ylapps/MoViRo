//
//  SampleWindowRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Routable

@MainActor
protocol WindowAlertRoutable: AnyObject {
    var windowRouter: SampleWindowRouter? { get }
    func showWindowAlert()
}

extension WindowAlertRoutable {
    func showWindowAlert() {
        windowRouter?.showWindowAlert()
    }
}

@MainActor
protocol WindowToastRoutable: AnyObject {
    var windowRouter: SampleWindowRouter? { get }
    func showWindowToast()
}

extension WindowToastRoutable {
    func showWindowToast() {
        windowRouter?.showWindowToast()
    }
}

// MARK: - Router

/// Sample window router demonstrating `AnyWindowRouter`.
/// Uses `SampleAppRouter` as the main window content and provides methods
/// to show alerts and toasts in separate `UIWindow` layers.
final class SampleWindowRouter: AnyWindowRouter {

    init() {
        let appRouter = SampleAppRouter()
        super.init(current: appRouter)
        appRouter.homeStack.homeRouter.windowRouter = self
    }

    // MARK: Window Navigation

    /// Shows an alert in a separate UIWindow (independent of any modal presentation).
    func showWindowAlert() {
        let alertRouter = WindowAlertRouter(windowRouter: self)
        addChild(alertRouter, level: .alert, backgroundColor: .clear)
    }

    /// Shows a toast banner in a separate UIWindow overlay.
    func showWindowToast() {
        let toastRouter = WindowToastRouter(windowRouter: self)
        let screen = windowScene?.screen.bounds ?? UIScreen.main.bounds
        let toastFrame = CGRect(x: 0, y: 0, width: screen.width, height: 120)
        addChild(toastRouter, level: .alert + 1, backgroundColor: .clear, frame: toastFrame)
    }
}

// MARK: - Window Alert

/// A simple modal router that renders an alert-style card in its own `UIWindow`.
private final class WindowAlertRouter: AnyModalRouter {

    @ObservationIgnored
    weak var windowRouter: SampleWindowRouter?

    init(windowRouter: SampleWindowRouter) {
        self.windowRouter = windowRouter
        super.init(transition: .fullScreen)
    }

    override func makeContentView() -> AnyView {
        AnyView(WindowAlertView(router: self))
    }
}

private struct WindowAlertView: View {

    let router: WindowAlertRouter

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 36))
                    .foregroundStyle(.orange)

                Text("Window Alert")
                    .font(.headline)

                Text("This alert is displayed in a separate UIWindow, independent of any modal presentation.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Dismiss") {
                    router.windowRouter?.removeChild(router)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(32)
        }
    }
}

// MARK: - Window Toast

/// A simple modal router that renders a toast banner in its own `UIWindow`.
private final class WindowToastRouter: AnyModalRouter {

    @ObservationIgnored
    weak var windowRouter: SampleWindowRouter?

    init(windowRouter: SampleWindowRouter) {
        self.windowRouter = windowRouter
        super.init(transition: .fullScreen)
    }

    override func makeContentView() -> AnyView {
        AnyView(WindowToastView(router: self))
    }
}

private struct WindowToastView: View {

    let router: WindowToastRouter
    @State private var isVisible = false

    var body: some View {
        VStack {
            if isVisible {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Action completed successfully")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .animation(.spring(duration: 0.35), value: isVisible)
        .onAppear {
            isVisible = true
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak router] in
                guard let router else { return }
                dismiss()
            }
        }
    }

    private func dismiss() {
        isVisible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak router] in
            guard let router else { return }
            router.windowRouter?.removeChild(router)
        }
    }
}
