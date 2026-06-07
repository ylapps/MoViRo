//
//  SampleWindowRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Routable

@MainActor
protocol WindowAlertRoutable: AnyObject {
    var windowModel: SampleWindowModel? { get }
    func showWindowAlert()
}

extension WindowAlertRoutable {
    func showWindowAlert() {
        windowModel?.showWindowAlert()
    }
}

@MainActor
protocol WindowToastRoutable: AnyObject {
    var windowModel: SampleWindowModel? { get }
    func showWindowToast()
}

extension WindowToastRoutable {
    func showWindowToast() {
        windowModel?.showWindowToast()
    }
}

// MARK: - Router

/// Sample window router demonstrating `WindowRouter`.
/// Uses `SampleAppRouter` as the main window content.
/// Window-level orchestration (alerts, toasts) lives in `SampleWindowModel`.
final class SampleWindowRouter: WindowRouter<SampleWindowModel> {

    init() {
        let appRouter = SampleAppRouter()
        super.init(current: appRouter)
        appRouter.homeStack.homeRouter.windowModel = model
    }

    override func makeModel() -> SampleWindowModel {
        SampleWindowModel(router: self)
    }
}

// MARK: - Window Alert

/// A simple modal router that renders an alert-style card in its own `UIWindow`.
final class WindowAlertRouter: AnyModalRouter {

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

struct WindowAlertView: View {

    let router: WindowAlertRouter
    @State private var isVisible = false

    var body: some View {
        ZStack {
            if isVisible {
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
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(24)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 32))
                .padding(32)
                .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .opacity))
            }
        }
        .animation(.bouncy(duration: 0.3), value: isVisible)
        .onAppear { isVisible = true }
    }

    private func dismiss() {
        isVisible = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak router] in
            guard let router else { return }
            router.windowRouter?.removeChild(router)
        }
    }
}

// MARK: - Window Toast

/// A simple modal router that renders a toast banner in its own `UIWindow`.
final class WindowToastRouter: AnyModalRouter {

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

struct WindowToastView: View {

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
