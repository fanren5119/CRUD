//
//  CRUDViewController.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/1/20.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class CRUDViewController<M: CRUDModelType, VM: CRUDDetailViewModel<M>>: PGDetailViewController<M,VM> {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
}
