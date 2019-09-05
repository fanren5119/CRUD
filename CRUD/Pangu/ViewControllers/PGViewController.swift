//
//  ViewController.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/2/14.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UIViewController {
    var noticeInfo: Binder<String> {
        return Binder(self.base) { item, value in
            item.infoNotice(value)
        }
    }
    
    var noticeSuccess: Binder<String> {
        return Binder(self.base) { item, value in
            item.successNotice(value)
        }
    }
    
    var noticeFail: Binder<Error> {
        return Binder(self.base) { item, value in
            item.errorNotice(value.errorMessage())
        }
    }
    
    var pleaseWait: Binder<Bool> {
        return Binder(self.base) { item, value in
            if value {
                item.pleaseWait()
            }else {
                item.clearAllNotice()
            }
        }
    }
}

open class PGViewController<VM: PGViewModelType> : ECSPStatusViewController {
    // RxSwift垃圾收集包
    public let bag = DisposeBag()
    // 主ViewModel
    public let viewModel: VM
    
    // 初始化的方式，必须要传一个viewModel进来
    public init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.noticeInfo.bind(to: self.rx.noticeInfo).disposed(by: bag)
        viewModel.noticeSuccess.bind(to: self.rx.noticeSuccess).disposed(by: bag)
        viewModel.noticeFail.bind(to: self.rx.noticeFail).disposed(by: bag)
        viewModel.pleaseWait.bind(to: self.rx.pleaseWait).disposed(by: bag)
        // Do any additional setup after loading the view.
        
    }
    
}



fileprivate extension Reactive where Base: UIViewController {
    var loading: Binder<Bool> {
        return Binder(self.base) { item, value in
            if value {
                
            }else {
                
            }
        }
    }
}

fileprivate extension Reactive where Base: UIView {
    var loading: Binder<Bool> {
        return Binder(self.base) { item, value in
            
            
        }
    }
}

open class PGDetailViewController<M:PGModelType,VM: PGLoadingViewModel<M>> : PGViewController<VM> {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.loading.bind(to: self.rx.loading).disposed(by: bag)
        viewModel.loadData()
    }
    
}

