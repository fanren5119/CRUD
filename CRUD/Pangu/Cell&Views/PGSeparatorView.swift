//
//  SeparatorView.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/4/17.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit

public final class PGSeparatorView: UIView {
    
    // MARK: Lifecycle
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    public override var intrinsicContentSize: CGSize {
        #if swift(>=4.2)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
        #else
        return CGSize(width: UIViewNoIntrinsicMetric, height: height)
        #endif
    }
    
    internal var color: UIColor {
        get { return backgroundColor ?? .clear }
        set { backgroundColor = newValue }
    }
    
    public var height: CGFloat = 1 {
        didSet { invalidateIntrinsicContentSize() }
    }
    
}
