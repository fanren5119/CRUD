//
//  PGTableViewController.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/2/14.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import MJRefresh
import RxCocoa
import RxSwift

extension Reactive where Base: MJRefreshHeader {
    public var loading: Binder<Bool> {
        return Binder(self.base) { item, value in
            if value {
                item.beginRefreshing()
            } else {
                item.endRefreshing()
            }
        }
    }
}

extension Reactive where Base: MJRefreshFooter {
    public var loadingMore: Binder<Bool> {
        return Binder(self.base) { item, value in
            if value {
                item.beginRefreshing()
            } else {
                item.endRefreshing()
            }
        }
    }
}

extension Reactive where Base: MJRefreshFooter {
    public var enable: Binder<Bool> {
        return Binder(self.base) { item, value in
            if value {
                item.resetNoMoreData()
            } else {
                item.endRefreshingWithNoMoreData()
            }
        }
    }
}

open class PGTableViewController<VM: PGViewModel>: PGViewController<VM> {
    
    open lazy var tableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
}

open class PGRefreshTableViewController<M: PGModelType,VM: PGPullLoadingViewModel<M>>: PGTableViewController<VM>  {

    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupRefresh()
        
    }
    
    private func setupRefresh() {
        // 下拉刷新
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {})
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.viewModel.loadMore()
        })
        self.viewModel.enableMore.bind(to: self.tableView.mj_footer.rx.enable).disposed(by: bag)
        self.viewModel.loadingMore.bind(to: self.tableView.mj_footer.rx.loadingMore).disposed(by: bag)
        self.viewModel.loading.bind(to: self.tableView.mj_header.rx.loading).disposed(by: bag)
        // 下拉刷新
        self.tableView.mj_header.beginRefreshing {[weak self] in
            self?.viewModel.loadFirst()
        }
    }
}


open class PGSingleTableViewController<M: PGModelType,C: PGTableViewCell> : PGRefreshTableViewController<M,PGPullLoadingViewModel<M>> {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(C.self, forCellReuseIdentifier: C.identifier)
        self.viewModel.items.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: C.identifier, cellType: C.self)) { [weak self] index,item,cell in
            self?.cellFor(item: item, index: index, cell: cell)
            }.disposed(by: bag)
        
    }
    
    open func cellFor(item: M, index: Int, cell: C) {
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "\(item)"
    }
    
}
