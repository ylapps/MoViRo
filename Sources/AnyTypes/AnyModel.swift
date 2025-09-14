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

    public internal(set) var isAppeared = false {
        didSet {
            guard oldValue != isAppeared else { return }
            
            if isAppeared {
                appearingCount += 1
                if appearingCount == 1 {
                    onAppear()
                }
            } else {
                appearingCount = max(0, appearingCount - 1)
                if appearingCount == 0 {
                    onDisappear()
                }
            }
        }
    }

    // MARK: Initialization

    init() {}
    deinit {}

    // MARK: Life cycle

    open func onAppear() {}
    open func onDisappear() {}
}
