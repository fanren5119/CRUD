//
//  CRUDDetailViewController.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/1/20.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import RxSwift

open class CRUDDetailViewController<M: CRUDModelType, VM: CRUDDetailViewModel<M>>: CRUDViewController<M,VM> {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.item.asObservable().subscribe(onNext: { (info) in
            if info?.id == nil {
                self.showEmpty()
            }
            else {
                self.showDefault()
            }
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }).disposed(by: self.bag)
        self.viewModel.noticeFail.asObserver().subscribe(onNext: { (error) in
            self.showError()
        }, onError: { (error) in
            
        }, onCompleted: {
            
        }).disposed(by: self.bag)
        self.setReloadHandler {[weak self] in
            self?.showLoading()
            self?.viewModel.loadData()
        }
    }
}


open class CRUDSingleDetailViewController<M: CRUDModel>: PGTableViewController<CRUDDetailViewModel<M>> {
    
    public  init(id: String) {
        super.init(viewModel: CRUDDetailViewModel<M>(id: id))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(String(describing: self.viewModel.item.value))"
        
        // Cell 配置
        self.tableView.register(PGTableViewCell.self, forCellReuseIdentifier: PGTableViewCell.identifier)

        self.viewModel.item.asObservable().flatMap { (item) -> Single<[[String: Any]]> in
                guard let it = item else { return Single.just([]) }
            
                return Single.just(it.properties())
            }.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: PGTableViewCell.identifier, cellType: PGTableViewCell.self)) { [weak self] index, item, cell in
                self?.cellFor(item: item, index: index, cell: cell)
            }.disposed(by: bag)
        
        // 动作
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe({ [weak self](_) in
            self?.showActions()
        }).disposed(by: bag)
        
        self.viewModel.loadData()
        
    }
    
    public func cellFor(item: [String: Any], index: Int, cell: PGTableViewCell) {
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "\(item)"
    }
    
    public func showActions() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for action in self.viewModel.actions {
            controller.addAction(UIAlertAction(title: action.title, style: .default, handler: {[weak self] (act) in
                self?.viewModel.request(action: action)
            }))
        }
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
}

