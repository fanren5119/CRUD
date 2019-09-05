//
//  CRUDViewModel.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/1/20.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import RxSwift
import Moya

public protocol CRUDViewModelType: PGViewModelType {
    associatedtype MMType: CRUDModelType
    
    var provider: CRUDProvider<MMType> { get }
    
    func request<Action: CRUDActionType>(action: Action, path: String?) where Action.ModelType == MMType
}

open class CRUDListViewModel<M: CRUDModelType>: PGPullLoadingViewModel<M>, CRUDViewModelType {
    
    
    public var provider: CRUDProvider<M> = CRUDProvider<M>(plugins:[DebugPlugin()])
    
    public var page: CRUDPage = CRUDPage()
    
    public var search: Variable<CRUDSearch?> = Variable(nil)
    
    public var sort: Variable<[CRUDSort]> = Variable([])
    
    public var filters: Variable<[CRUDBaseFilter]> = Variable([])
    
    public var fields: [CRUDProperty] = []
    
    public var ids: Variable<[String]> = Variable([])
    
    public var parameters: Variable<[CRUDBaseParameter]> = Variable([])
    
    public var delete: PublishSubject<(Bool,Error?)> = PublishSubject<(Bool,Error?)>()
    
    
    public required init() {
        super.init()
    }
    
    // FECRUDViewModelType
    // 下拉刷新
    public func request<Action: CRUDActionType>(action: Action, path: String? = nil) where Action.ModelType == M  {
        self.loading.onNext(true)
        provider.request(action, result: [M].self, path: path).subscribe(onSuccess: {[weak self] (response) in
            self?.loading.onNext(false)
            // 更新当前页数
            if let page = response.page {
                self?.updatePageInfo(page: page)
                // 如果是下拉刷新，清空数据重新来过
                if page.p == 1 { self?.items.value.removeAll() }
            }
            self?.items.value.append(contentsOf: response.result)
        }) { (error) in
            self.loading.onNext(false)
            self.noticeFail.onNext(error)
            }.disposed(by: bag)
    }
    // 加载更多
    public func requestMore<Action: CRUDActionType>(action: Action, path: String? = nil) where Action.ModelType == M {
        provider.request(action, result: [M].self, path: path).subscribe(onSuccess: {[weak self] (response) in
            self?.loadingMore.onNext(false)
            // 更新当前页数
            if let page = response.page {
                self?.updatePageInfo(page: page)
            }
            self?.items.value.append(contentsOf: response.result)
        }) { (error) in
            self.loadingMore.onNext(false)
            self.noticeFail.onNext(error)
            }.disposed(by: bag)
    }
    
    // 等待载入不返回结果
    public func waitRequest<Action: CRUDActionType>(action: Action, success: String? = nil, fail: String? = nil, path: String? = nil) where Action.ModelType == M  {
        self.pleaseWait.onNext(true)
        provider.request(action, path: path).subscribe(onSuccess: {[weak self] (response) in
            self?.pleaseWait.onNext(false)
            guard let s = success else {
                self?.noticeSuccess.onNext("操作成功!")
                return
            }
            self?.noticeSuccess.onNext(s)
        }) {[weak self] (error) in
            self?.pleaseWait.onNext(false)
            guard let f = fail else {
                self?.noticeFail.onNext(error)
                return
            }
            //            self?.noticeFail.onNext
            }.disposed(by: bag)
    }
    
    // 批量修改操作待有相关场景再实现
//    public func updateBatch(id: String, success: String? = nil, fail: String? = nil) {
//        waitRequest(action: CRUDAction<M>.updateBatch(id: id), success: success, fail: fail)
//    }
    
    public func remove(id: String, success: String? = nil, fail: String? = nil) {
        waitRequest(action: CRUDAction<M>.remove(id: id, parameters: self.parameters.value), success: success, fail: fail)
    }
    public func removeBatch(ids: [String], success: String? = nil, fail: String? = nil) {
        waitRequest(action: CRUDAction<M>.removeBatch(ids: ids, parameters: self.parameters.value), success: success, fail: fail)
    }
    public func activeBatch(ids: [String], success: String? = nil, fail: String? = nil) {
        waitRequest(action: CRUDAction<M>.activeBatch(ids: ids, parameters: self.parameters.value), success: success, fail: fail)
    }
    public func inactiveBatch(ids: [String], success: String? = nil, fail: String? = nil) {
        waitRequest(action: CRUDAction<M>.inactiveBatch(ids: ids, parameters: self.parameters.value), success: success, fail: fail)
    }
    public func deleteBatch(ids: [String], success: String? = nil, fail: String? = nil) {
        waitRequest(action: CRUDAction<M>.deleteBatch(ids: ids, parameters: self.parameters.value), success: success, fail: fail)
    }
    public func auditBatch(ids: [String], success: String? = nil, fail: String? = nil) {
        waitRequest(action: CRUDAction<M>.auditBatch(ids: ids, parameters: self.parameters.value), success: success, fail: fail)
    }
    

    open override func loadFirst() {
        
        let action = CRUDAction<M>.list(obj: nil, page: 1, pageSize: page.ps, search: self.search.value, filter: self.filters.value, sort:self.sort.value, ids: self.ids.value, parameters: self.parameters.value, fields: self.fields)
        
        request(action: action)
    }
    
    open override func loadMore() {
        
        let page = self.page.p + 1
        let action = CRUDAction<M>.list(obj: nil, page: page, pageSize: self.page.ps, search: self.search.value, filter: self.filters.value, sort:self.sort.value, ids: self.ids.value, parameters: self.parameters.value, fields: self.fields)
        
        requestMore(action: action)
    }
    
    
    
    private func updatePageInfo(page: CRUDPage) {
        self.page.p = page.p
        self.page.tp = page.tp
        self.page.ts = page.ts
        
        // 有没有更多的数据，有true,无 false
        self.enableMore.onNext(self.page.p < self.page.tp!)
    }
    
    
    
    // 删除元素
    public func remove(_ item: M) {
        self.items.value.removeAll { (model) -> Bool in
            guard let id1 = item.id, let id2 = model.id else { return false}
            return id1 == id2
        }
    }
    
    // 是否选中
    public func isSelected(_ item: M) -> Bool {
        return self.selectedItems.value.first(where: { (model) -> Bool in
            guard let id1 = item.id, let id2 = model.id else { return false}
            return id1 == id2
        }) != nil
    }
    
    // 反选元素
    public func unselect(_ item: M) {
        self.selectedItems.value.removeAll { (model) -> Bool in
            guard let id1 = item.id, let id2 = model.id else { return false}
            return id1 == id2
        }
    }
}

open class CRUDDetailViewModel<M: CRUDModelType>: PGLoadingViewModel<M>, CRUDViewModelType {
    
    public var id: String?
    
    public var parameters: Variable<[CRUDBaseParameter]> = Variable([])
    
    public var fields: [CRUDProperty] = []
    
    public init(id: String) {
        super.init()
        self.id = id
    }
    
    public init(item: M) {
        super.init()
        self.item = Variable(item)
    }
    
    public var provider: CRUDProvider<M> = CRUDProvider<M>(plugins:[DebugPlugin()])
    
    var actions: [CRUDAction<M>] {
        return [
            .remove(id: self.id!, parameters: nil),
        ]
    }
    // FECRUDViewModelType
    public func request<Action: CRUDActionType>(action: Action, path: String? = nil) where Action.ModelType == M {
        self.loading.onNext(true)
        provider.request(action, result: M.self, path: path).subscribe(onSuccess: {[weak self] (response) in
            self?.loading.onNext(false)
            self?.item.value = response.result
            
        }) { (error) in
            self.loading.onNext(false)
            self.noticeFail.onNext(error)
            }.disposed(by: bag)
    }
    
    public func waitRequest<Action: CRUDActionType>(action: Action, success: String? = nil, fail: String? = nil, path: String? = nil)where Action.ModelType == M  {
        self.pleaseWait.onNext(true)
        provider.request(action, path: path).subscribe(onSuccess: {[weak self] (response) in
            self?.pleaseWait.onNext(false)
            guard let s = success else {
                self?.noticeSuccess.onNext("操作成功!")
                return
            }
            self?.noticeSuccess.onNext(s)
        }) {[weak self] (error) in
            self?.pleaseWait.onNext(false)
            guard let f = fail else {
                self?.noticeFail.onNext(error)
                return
            }
            //            self?.noticeFail.onNext
            }.disposed(by: bag)
    }

    public func delete(success: String? = nil, fail: String? = nil) {
        guard let id = (self.id == nil ? self.item.value?.id : self.id) else { return }
        waitRequest(action: CRUDAction<M>.delete(id: id, parameters: self.parameters.value), success: success, fail: fail)
    }
    
    public func save(success: String? = nil, fail: String? = nil) {
        guard let item = self.item.value else { return }
        waitRequest(action: CRUDAction<M>.create(item, parameters: self.parameters.value), success: success, fail: fail)
    }
    
    public func update(success: String? = nil, fail: String? = nil) {
        guard let id = (self.id == nil ? self.item.value?.id : self.id) else { return }
        guard let item = self.item.value else { return }
        waitRequest(action: CRUDAction<M>.update(obj: item, id: id, parameters: self.parameters.value), success: success, fail: fail)
    }
    
    public func remove(success: String? = nil, fail: String? = nil) {
        guard let id = (self.id == nil ? self.item.value?.id : self.id) else { return }
        waitRequest(action: CRUDAction<M>.remove(id: id, parameters: self.parameters.value), success: success, fail: fail)
    }
    
    public func active(success: String? = nil, fail: String? = nil) {
        guard let id = (self.id == nil ? self.item.value?.id : self.id) else { return }
        waitRequest(action: CRUDAction<M>.active(id: id, parameters: self.parameters.value), success: success, fail: fail)
    }
    
    public func inactive(success: String? = nil, fail: String? = nil) {
        guard let id = (self.id == nil ? self.item.value?.id : self.id) else { return }
        waitRequest(action: CRUDAction<M>.inactive(id: id, parameters: self.parameters.value), success: success, fail: fail)
    }
    
    public func audit(success: String? = nil, fail: String? = nil) {
        guard let id = (self.id == nil ? self.item.value?.id : self.id) else { return }
        waitRequest(action: CRUDAction<M>.audit(id: id, parameters: self.parameters.value), success: success, fail: fail)
    }
    
    open override func loadData() {
        guard let id = (self.id == nil ? self.item.value?.id : self.id) else { return }
        let action = CRUDAction<M>.show(obj:nil, id: id, idField:nil, parameters: self.parameters.value, fields: self.fields)
        request(action: action)
    }
}
