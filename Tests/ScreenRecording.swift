//
//  ScreenRecording.swift
//  MoviroTests
//
//  Routers whose screens record what SwiftUI does to them, and a window to
//  host them in. The two kinds matter: a bare view hung straight on an
//  `AnyModalRouter` / `AnyPushRouter`, and a `BaseView` with `@State var model`
//  owned by a `ModalRouter` / `PushRouter` — the shape every app screen has.
//

@testable import Moviro
import SwiftUI
import Testing
import UIKit

// MARK: - Recorder

@MainActor
final class ScreenRecorder {
    var bodyEvaluations = 0
    var appearCount = 0
    var disappearCount = 0
    var isOnScreen: Bool { appearCount > disappearCount }
}

@MainActor
protocol Recording: AnyObject {
    var recorder: ScreenRecorder { get }
}

/// Counts its body evaluations and its appearances.
struct RecordingView: View {
    let recorder: ScreenRecorder

    var body: some View {
        let _ = recorder.bodyEvaluations += 1
        Color.clear
            .onAppear { recorder.appearCount += 1 }
            .onDisappear { recorder.disappearCount += 1 }
    }
}

// MARK: - Bare routers

final class RecordingModalRouter: AnyModalRouter, Recording {
    let recorder = ScreenRecorder()

    override init(transition: Transition = .fullScreen) {
        super.init(transition: transition)
    }

    override func makeScreen() -> ErasedScreen {
        .init(RecordingView(recorder: recorder).presentations(of: self))
    }
}

final class RecordingPushRouter: AnyPushRouter, Recording {
    let recorder = ScreenRecorder()

    override func makeScreen() -> ErasedScreen {
        .init(RecordingView(recorder: recorder).pushDestination(of: self))
    }
}

// MARK: - BaseView routers

@Observable
final class RecordingModel: Model<Never> {
    @ObservationIgnored let recorder = ScreenRecorder()
}

struct RecordingScreen: BaseView {
    @State var model: RecordingModel

    init(model: RecordingModel) {
        self.model = model
    }

    var body: some View {
        RecordingView(recorder: model.recorder)
    }
}

final class RecordingScreenModalRouter: ModalRouter<RecordingScreen>, Recording {
    var recorder: ScreenRecorder { model.recorder }

    init() {
        super.init(transition: .fullScreen)
    }

    override func makeModel() -> RecordingModel { RecordingModel() }
}

final class RecordingScreenPushRouter: PushRouter<RecordingScreen>, Recording {
    var recorder: ScreenRecorder { model.recorder }

    override func makeModel() -> RecordingModel { RecordingModel() }
}

// MARK: - Kinds

enum ScreenKind: CaseIterable {
    case bare
    case baseView

    @MainActor
    func makeModal() -> AnyModalRouter & Recording {
        switch self {
        case .bare: RecordingModalRouter()
        case .baseView: RecordingScreenModalRouter()
        }
    }

    @MainActor
    func makePush() -> AnyPushRouter & Recording {
        switch self {
        case .bare: RecordingPushRouter()
        case .baseView: RecordingScreenPushRouter()
        }
    }
}

// MARK: - Window

/// The test process has no window scene, and a window without one does not
/// present a sheet that is asked for after its content appeared — an app
/// does — so presentations are not covered by anything hosted here. Pushes are.
@MainActor
enum WindowHost {

    static func host(_ view: some View) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = UIHostingController(rootView: view)
        window.makeKeyAndVisible()
        return window
    }

    static func waitUntil(
        timeout: Duration = .seconds(5),
        sourceLocation: SourceLocation = #_sourceLocation,
        _ condition: () -> Bool
    ) async throws {
        let deadline = ContinuousClock.now + timeout
        while !condition() {
            guard ContinuousClock.now < deadline else {
                Issue.record("Timed out waiting for the condition", sourceLocation: sourceLocation)
                return
            }
            try await Task.sleep(for: .milliseconds(10))
        }
    }

    /// What these tests rule out would happen within a turn or two of the
    /// change, so there is no event to wait for, only time.
    static func settle(_ duration: Duration = .milliseconds(300)) async throws {
        try await Task.sleep(for: duration)
    }
}
