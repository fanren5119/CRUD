//
//  PGViewModels.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/2/14.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import Foundation
import RxSwift

public protocol PGViewModelType {
    
    // 提示成功订阅
    var noticeInfo: PublishSubject<String> { get }
    // 提示成功订阅
    var noticeSuccess: PublishSubject<String> { get }
    // 提示订阅
    var noticeFail: PublishSubject<Error> { get }
    
    var pleaseWait: PublishSubject<Bool> { get }
}

public protocol PGLoadingType {
    // 加载订阅
    var loading: PublishSubject<Bool> { get }
    
    // 第一页
    func loadData() -> Void
}

public protocol PGLoadingMoreType {
    
    // 加载更多订阅
    var loadingMore: PublishSubject<Bool> { get }
    // 下一页
    func loadMore() -> Void
}

open class PGViewModel: PGViewModelType {
    
    // RxSwift垃圾收集包
    public let bag = DisposeBag()

    public var noticeInfo: PublishSubject<String> = PublishSubject<String>()
    
    public var noticeSuccess: PublishSubject<String> = PublishSubject<String>()
    
    public var noticeFail: PublishSubject<Error> = PublishSubject<Error>()
    
    public var pleaseWait: PublishSubject<Bool> = PublishSubject<Bool>()
    
}

open class PGValueViewModel<T: Codable>: PGViewModel {
    
    public var item: Variable<T?> = Variable<T?>(nil)
    
    var isNil: Bool {
        guard let _ = item.value else {
            return true
        }
        return false
    }
    
    var value: T? {
        return item.value
    }
    
    public init(_ item: T? = nil) {
        self.item.value = item
        super.init()
    }
}

open class PGListViewModel<T: Codable>: PGViewModel {
    
    public var items: Variable<[T]> = Variable<[T]>([])
    
    // 是否多选
    public var isMutliSelect:Bool = false
    // 已选中的选项
    lazy public var selectedItems: Variable<[T]> = {
        return Variable([])
    }()
    
    public var count: Int {
        return items.value.count
    }
    
    public var first: T? {
        return items.value.first
    }
    
    public var last: T? {
        return items.value.last
    }
    
    public func remove(where shouldBeRemoved: (T) throws -> Bool) rethrows {
        try items.value.removeAll(where: shouldBeRemoved)
    }
    
    public func removeFirst() -> T {
        return items.value.removeFirst()
    }
    
    public func removeLast() -> T {
        return items.value.removeLast()
    }
    
    public func clear() {
        items.value.removeAll()
    }
    
    public subscript(index: Int) -> T {
        return items.value[index]
    }
    
    public init(_ items: [T] = []) {
        self.items.value = items
        super.init()
    }
    
    // 清空选择
    open func unselectAll() {
        self.selectedItems.value.removeAll()
    }
    
    // 选择全部
    open func selectAll() {
        self.selectedItems.value = self.items.value
    }
    
    open func unselect(_ index: Int) {
        self.selectedItems.value.remove(at: index)
    }
    
    public func unselect(where shouldBeUnSelect: (T) throws -> Bool) rethrows {
        selectedItems.value.removeLast()
        try selectedItems.value.removeAll(where: shouldBeUnSelect)
    }
    
    open func select(_ index: Int) {
        if isMutliSelect {
            self.selectedItems.value.append(self.items.value[index])
        }else {
            self.selectedItems.value = [self.items.value[index]]
        }
    }
    
}

// 数据加载view model
open class PGLoadingViewModel<M: PGModelType>: PGValueViewModel<M>, PGLoadingType {
    
    public var loading: PublishSubject<Bool> = PublishSubject<Bool>()

    open func loadData() {}
}

// 分页数据加载 view model
open class PGPullLoadingViewModel<M: PGModelType>: PGListViewModel<M>, PGLoadingMoreType {
    
    public var loading: PublishSubject<Bool> = PublishSubject<Bool>()
    public var loadingMore: PublishSubject<Bool> = PublishSubject<Bool>()
    public var enableMore: PublishSubject<Bool> = PublishSubject<Bool>()
    
    open func loadFirst() {
        fatalError("loadFirst has not been implemented")
    }
    
    open func loadMore() {
        fatalError("loadMore has not been implemented")
    }
}
