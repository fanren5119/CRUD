//
//  PGCollectionViewController.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/2/14.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import MJRefresh

open class PGCollectionViewController<M: PGModelType, VM: PGPullLoadingViewModel<M>>: PGViewController<VM>  {
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return view
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        // 下拉刷新
        self.collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {})
        self.collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.viewModel.loadFirst()
        })
        self.viewModel.loadingMore.bind(to: self.collectionView.mj_footer.rx.loadingMore).disposed(by: bag)
        self.viewModel.enableMore.bind(to: self.collectionView.mj_footer.rx.enable).disposed(by: bag)
        self.viewModel.loading.bind(to: self.collectionView.mj_header.rx.loading).disposed(by: bag)
        
        // 下拉刷新
        self.collectionView.mj_header.beginRefreshing {[weak self] in
            self?.viewModel.loadMore()
        }
    }
    
}

