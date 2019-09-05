//
//  ECSPStatusViewController.swift
//  RealmTest
//
//  Created by XUEYING FANG on 2019/2/13.
//  Copyright © 2019 XUEYING FANG. All rights reserved.
//

import UIKit

public enum  ECSPViewControllerStatus {
    case Default
    case Loading
    case Empty
    case Exception
}

open class ECSPStatusViewController: UIViewController {

    public typealias ECSPStatusViewControllerReloadHandler = () -> Void
    private var reloadHandler:ECSPStatusViewControllerReloadHandler?
    
    private lazy var emptyView:ECSPEmptyView? = {
        var view = ECSPEmptyView.init(frame: self.view.bounds)
        var gesture = UITapGestureRecognizer.init(target: self, action: #selector(exceptionViewTouched(_:)))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    private lazy var exceptionView:ECSPExceptionView? = {
        var view = ECSPExceptionView.init(frame: self.view.bounds)
        var gesture = UITapGestureRecognizer.init(target: self, action: #selector(exceptionViewTouched(_:)))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    private lazy var loadingView:ECSPLoadingView? = {
        var view = ECSPLoadingView.init(frame: self.view.bounds)
        var gesture = UITapGestureRecognizer.init(target: self, action: #selector(emptyViewTouched(_:)))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    private var status:ECSPViewControllerStatus = .Default

    public func setStatus(status:ECSPViewControllerStatus) {

        self.clearStatusView()
        switch status {
        case .Empty:
            self.status = .Empty
            self.setStatusView(view: self.emptyView!)
            break
        case .Exception:
            self.status = .Exception
            self.setStatusView(view: self.exceptionView!)
            break
        case .Loading:
            self.status = .Loading
            self.setStatusView(view: self.loadingView!)
            break
        default:
            break
        }
    }
    
    public func showLoading() {
        self.showLoadingWith(title: "加载中...", subtitle: nil, image: nil)
    }
    
    public func showLoadingWith(title:String?) {
        self.showLoadingWith(title: title, subtitle: nil, image: nil)
    }
    
    public func showLoadingWith(title:String? ,subtitle:String?) {
        self.showLoadingWith(title: title, subtitle: subtitle, image: nil)
    }
    
    public func showLoadingWith(title:String? ,subtitle:String? ,image:UIImage?) {
        loadingView!.tittle = title
        loadingView!.subtitle = subtitle
        self.setStatus(status: .Loading)
    }
    
    public func showDefault() {
        self.setStatus(status: .Default)
    }
    
    public func showDefaultView() {
   
    }
    
    public func showEmpty() {
        self.showEmptyWith(title: "暂无内容", subtitle: nil, image: UIImage.init(named: "empty"))
    }
    
    public func showEmptyWith(title:String?) {
        self.showEmptyWith(title: title, subtitle: nil, image: UIImage.init(named: "empty"))
    }
    
    public func showEmptyWith(title:String? ,subtitle:String?) {
        self.showEmptyWith(title: title, subtitle: subtitle, image: UIImage.init(named: "empty"))
    }
    
   public  func showEmptyWith(title:String? ,subtitle:String? ,image:UIImage?) {
        emptyView!.tittle = title
        emptyView!.subtitle = subtitle
        emptyView!.image = image
        self.setStatus(status: .Empty)
    }
    
    public func showError() {
        self.showErrorWith(title: "怎么也连不上，点击屏幕再试试?", subtitle: "点击屏幕刷新", image: UIImage.init(named: "error"))
    }
    
    public func showErrorWith(title:String?) {
        self.showErrorWith(title: title, subtitle: nil, image: UIImage.init(named: "error"))
    }
    
    public func showErrorWith(title:String? ,subtitle:String?) {
        self.showErrorWith(title: title, subtitle: subtitle, image: UIImage.init(named: "error"))
    }
    
    public func showErrorWith(title:String? ,subtitle:String? ,image:UIImage?) {
        exceptionView!.tittle = title;
        exceptionView!.subtitle = subtitle;
        exceptionView!.image = image
        self.setStatus(status: .Exception)
    }
    
    @objc func exceptionViewTouched(_ gesture:UITapGestureRecognizer) {
        self.performReloadHandler()
    }
    
    @objc func emptyViewTouched(_ gesture:UITapGestureRecognizer) {
        self.performReloadHandler()
    }
    
    public func setReloadHandler(handler: @escaping ECSPStatusViewControllerReloadHandler) {
//         objc_setAssociatedObject(self, "reloadHandler", handler, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.reloadHandler = handler
    }
    
   private func performReloadHandler() {
        if self.reloadHandler != nil {
            self.reloadHandler!()
        }
    }
    
   private func setStatusView(view: UIView) {
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        self.view.bringSubviewToFront(view)
    }
    
    private func clearStatusView() {
        if  emptyView != nil && emptyView!.superview != nil {
            emptyView!.removeFromSuperview()
           // emptyView = nil
        }
        
        if loadingView != nil && loadingView!.superview != nil {
            loadingView!.removeFromSuperview()
         //   loadingView = nil
        }
        
        if exceptionView != nil && exceptionView!.superview != nil {
            exceptionView!.removeFromSuperview()
          //  exceptionView = nil
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

