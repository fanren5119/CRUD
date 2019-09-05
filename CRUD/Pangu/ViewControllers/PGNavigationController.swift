//
//  PGNavigationController.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/2/14.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import RxSwift

open class PGNavigationController: UINavigationController {
    // RxSwift垃圾收集包
    public let bag = DisposeBag()
}
