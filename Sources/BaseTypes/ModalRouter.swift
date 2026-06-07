//
//  ModalRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import SwiftUI

/// A modal router that carries no typed closing result.
/// This is the standard base class for modal screen routers.
public typealias ModalRouter<ViewType: BaseView> = ResultModalRouter<ViewType, Void>
