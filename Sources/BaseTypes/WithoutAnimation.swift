//
//  WithoutAnimation.swift
//  WorkoutTimer
//
//  Created by Yevhenii Lytvynenko on 06.06.2025.
//

import SwiftUI

@MainActor
func withoutAnimation(action: @escaping () -> Void) {
    let wasAnimationEnabled = UIView.areAnimationsEnabled
    UIView.setAnimationsEnabled(false)
    
    var transaction = Transaction(animation: nil)
    transaction.disablesAnimations = true
    
    withTransaction(transaction) {
        action()
    }
    
    // Restore previous animation state
    UIView.setAnimationsEnabled(wasAnimationEnabled)
}
