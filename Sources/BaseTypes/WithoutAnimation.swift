//
//  WithoutAnimation.swift
//  WorkoutTimer
//
//  Created by Yevhenii Lytvynenko on 06.06.2025.
//

import SwiftUI

@inline(__always)
public func withoutAnimation(action: () -> Void) {
    UIView.setAnimationsEnabled(false)
    defer { UIView.setAnimationsEnabled(true) }
    
    var transaction = Transaction()
    transaction.disablesAnimations = true
    withTransaction(transaction, action)
}
