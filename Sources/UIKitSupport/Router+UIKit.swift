//
//  Router+UIKit.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 18.01.2026.
//

// MARK: - Routers

public typealias ModalUIRouter<VC: UIViewController & ModelHolding> = ModalRouter<UIKitContent<VC>> where VC.Model: AnyModel
public typealias PushUIRouter<VC: UIViewController & ModelHolding> = PushRouter<UIKitContent<VC>> where VC.Model: AnyModel

