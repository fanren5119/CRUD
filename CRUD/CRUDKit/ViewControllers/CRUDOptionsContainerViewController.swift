//
//  CRUDOptionsContainerViewController.swift
//  Installer
//
//  Created by hong tianjun on 2019/4/12.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit


public protocol CRUDOptionsViewControllerType {
    
    var containerController: CRUDOptionsContainerViewController? { get set}
    
    var isMutliSelect: Bool { get set}
    
    func clear()
    
    func selectAll()
    
    func finishedSelection()
    
}

public typealias CRUDOptionViewController = CRUDOptionsViewControllerType & UIViewController


public class CRUDOptionsContainerViewController: UIViewController {
    
    public var conditionViewController: CRUDOptionsViewControllerType & UIViewController
    
    var conditionHeight: CGFloat = 200
    
    lazy var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.backgroundColor = UIColor.white
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        return toolbar
    }()
    
    
    public init(_ conditionViewController: CRUDOptionsViewControllerType & UIViewController) {
        self.conditionViewController = conditionViewController
        super.init(nibName: nil, bundle: nil)
        
        // TODO: 此处需要确认每一个内容的viewController都要有这个属性吗
        self.conditionViewController.containerController = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentViewController()
        setupMaskView()
        setupToolbar()
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        self.removeFromParentController()
    }
    
    @objc func clear(btn: UIBarButtonItem) {
        conditionViewController.clear()
    }
    
    @objc func all(btn: UIBarButtonItem) {
        conditionViewController.selectAll()
    }
    
    @objc func done(btn: UIBarButtonItem) {
        // 结束选择
        conditionViewController.finishedSelection()
        self.removeFromParentController()
    }
    
    public func reset(height: CGFloat) {
        conditionHeight = min(height, self.view.bounds.height - 200)
        conditionViewController.view.snp.updateConstraints({ (maker) in
            maker.height.equalTo(conditionHeight)
            maker.left.right.top.equalToSuperview()
        })
        
        UIView.animate(withDuration: TimeInterval(0.3)) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupContentViewController() {
        conditionViewController.addToParentController(self)
        conditionViewController.view.snp.makeConstraints({ (maker) in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(conditionHeight)
        })
    }
    
    func setupMaskView() {
        self.view.addSubview(maskView)
        maskView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalToSuperview()
            maker.top.equalTo(conditionViewController.view.snp_bottom)
        }
        maskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    }
    
    func setupToolbar() {
        // 如果不是多选就不显示了
        if !conditionViewController.isMutliSelect { return }
        
        let item1 = UIBarButtonItem(title: "清空", style: .plain, target: self, action: #selector(clear))
        let item2 = UIBarButtonItem(title: "全选", style: .plain, target: self, action: #selector(all))
        let item3 = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(done))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [item1, item2, space, item3]
        self.view.addSubview(toolbar)
        toolbar.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(maskView.snp_top)
        }
    }
}
