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
    private var _isAppeared: Bool = false

    public internal(set) var isAppeared: Bool {
        get { _isAppeared }
        set {
            guard _isAppeared != newValue else { return } // Avoid unnecessary work
            _isAppeared = newValue
            
            if newValue {
                if appearingCount == 0 {
                    onAppear()
                }
                appearingCount += 1
            } else {
                appearingCount -= 1
                if appearingCount == 0 {
                    onDisappear()
                }
            }
        }
    }

    // MARK: Initialization

    init() { 
        MoviroLogger.logInit(Self.self, category: .model)
    }
    
    deinit { 
        MoviroLogger.logDeinit(Self.self, category: .model)
    }

    // MARK: Life cycle

    open func onAppear() { 
        MoviroLogger.logAppear(Self.self)
    }
    
    open func onDisappear() { 
        MoviroLogger.logDisappear(Self.self)
    }
}
