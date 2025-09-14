//
//  AnyModel.swift
//  ModalPet
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import Foundation

@MainActor
open class AnyModel {

    // MARK: State

    private var appearingCount = 0

    public internal(set) var isAppeared: Bool = false {
        didSet {
            guard isAppeared != oldValue else { return }
            if isAppeared {
                if appearingCount == 0 { onAppear() }
                appearingCount += 1
            } else {
                appearingCount = max(appearingCount - 1, 0)
                if appearingCount == 0 { onDisappear() }
            }
        }
    }

    // MARK: Initialization

    init() {
        #if DEBUG
        print("🧩 [MODEL] \(Self.self) init")
        #endif
    }
    deinit {
        #if DEBUG
        print("☠️ [MODEL] \(Self.self) deinit")
        #endif
    }

    // MARK: Life cycle

    open func onAppear() {
        #if DEBUG
        print("💡 [MODEL] \(Self.self) appear")
        #endif
    }
    open func onDisappear() {
        #if DEBUG
        print("🫣 [MODEL] \(Self.self) disappear")
        #endif
    }
}
