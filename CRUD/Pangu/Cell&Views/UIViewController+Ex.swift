//
//  UIViewController+Ex.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/4/16.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func addToParentController(_ parent: UIViewController) {
        self.willMove(toParent: parent)
        parent.addChild(self)
        parent.view.addSubview(self.view)
        self.didMove(toParent: parent)
    }
    
    public func removeFromParentController() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
        self.didMove(toParent: nil)
    }
}
