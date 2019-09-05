//
//  CRUDListViewController.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/1/20.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import MJRefresh
import RxSwift
import RxCocoa



// 此处主要解决下拉刷新，及下拉加载更多的问题
open class CRUDListViewController<M: CRUDModelType, VM: CRUDListViewModel<M>>: PGRefreshTableViewController<M,VM>,CRUDContainerContentViewControllerType {
    
    public var contentView: UIView {
        return self.view
    }
    
    public var contentScrollView: UIScrollView? {
        return tableView
    }
    
    public var searchItems: [String] = []
    
    public var conditionItems: [CRUDOptions]  = []
    
    public func searchConditionChange(_ search: CRUDSearch?) {
        self.viewModel.search.value = search
        guard self.tableView.mj_header != nil else {
            return
        }
        self.tableView.mj_header.beginRefreshing()
    }
    
    public func filterConditionChange(_ filters: [CRUDBaseFilter]) {
        self.viewModel.filters.value = filters
        guard self.tableView.mj_header != nil else {
            return
        }
        self.tableView.mj_header.beginRefreshing()
    }
    
    public func sortsConditionChange(_ sorts: [CRUDSort]) {
        self.viewModel.sort.value = sorts
        guard self.tableView.mj_header != nil else {
            return
        }
        self.tableView.mj_header.beginRefreshing()
    }
    
    public func conditionChange(_ search: CRUDSearch?, filters: [CRUDBaseFilter], sorts: [CRUDSort]) {
        self.viewModel.search.value = search
        self.viewModel.filters.value = filters
        self.viewModel.sort.value = sorts
        self.tableView.mj_header.beginRefreshing()
    }
    
//    public init(viewModel: CRUDListViewModel<M> = VM()) {
//        super.init(viewModel: viewModel)
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.items.asObservable().subscribe(onNext: { (info) in
            if info.count > 0{
                 self.showDefault()
            }
            else {
                self.showEmpty()
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
            self?.tableView.mj_header.beginRefreshing()
        }
    }
    
    
}



open class CRUDSingleListViewController<M: CRUDModelType, VM: CRUDListViewModel<M>,C: PGTableViewCell>: CRUDListViewController<M,VM> {
    
    
//    public init() {
//        super.init(viewModel: CRUDListViewModel<M>())
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 配置
        self.tableView.register(C.self, forCellReuseIdentifier: C.identifier)
        self.viewModel.items.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: C.identifier, cellType: C.self)) { [weak self] index,item,cell in
            self?.cellFor(item: item, index: index, cell: cell)
            }.disposed(by: bag)
        
        // 点击
        self.tableView.rx.itemSelected.subscribe {[weak self] (event) in
            guard let indexPath = event.element,
                let item = self?.viewModel.items.value[indexPath.row] else { return }
            self?.showDetail(for: item)
            }.disposed(by: bag)
        
        
        // Action
        self.tableView.rx.itemDeleted.subscribe { [weak self] (event) in
            guard let indexPath = event.element,
                let item = self?.viewModel.items.value[indexPath.row] else { return }
            self?.deleteItem(for: item, index: indexPath as NSIndexPath)
            }.disposed(by: bag)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe(onNext: { [weak self]() in
            let viewController = CRUDComposeViewController<M>()
            self?.present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
        }).disposed(by: bag)
    }
    
    open func cellFor(item: M, index: Int, cell: C) {
        cell.textLabel?.text = "\(item)"
    }
    open func showDetail(for item: M) {}
    open func deleteItem(for item: M, index: NSIndexPath) {}
//    
//    open func showDetail(for item: M) {
//        guard let id = item.id else { return }
//
////        let viewController = CRUDSingleDetailViewController<M>(id: id)
////        self.navigationController?.pushViewController(viewController, animated: true)
//    }
}
