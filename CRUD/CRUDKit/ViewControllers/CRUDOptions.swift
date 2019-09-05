//
//  CRUDOptions.swift
//  Installer
//
//  Created by hong tianjun on 2019/4/13.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


public protocol CRUDOptionsType {
    
    var finished: Variable<[CRUDConditionType]> { get }
    // 标题显示
    var title: String { get set }
    // 回显标题
    var displayTitle: String? { get set }
    //是否多选
    var isMutliSelect:Bool  { get set }
    // 展示数据的viewController
    func conditionViewController() -> CRUDOptionViewController?
    
}


public protocol CRUDTypedOptionsType: CRUDOptionsType {
    associatedtype OptionsValue: Equatable
    
    var selectedItem: Variable<[OptionsValue]> { get }
    
    func didFinished(for items: [OptionsValue]) -> [CRUDConditionType]
}


open class CRUDOptions: CRUDOptionsType  {
    
    public var finished: Variable<[CRUDConditionType]> = Variable<[CRUDConditionType]>([])
    
    public var title: String
    
    public var displayTitle: String?
    
    public var isMutliSelect: Bool = false
    
    open func conditionViewController() -> CRUDOptionViewController? {
        return nil
    }
    
    public init(_ title:String, isMutliSelect: Bool = false) {
        self.title = title
        self.isMutliSelect = isMutliSelect
    }
}

open class CRUDTypedOptions<T: Codable>: CRUDOptions, CRUDTypedOptionsType where T: Equatable {
    
    var bag = DisposeBag()
    
    public typealias OptionsValue = T
    
    public var selectedItem: Variable<[T]> = Variable<[T]>([])
    
    public init(_ title:String, selected: [T] = [], isMutliSelect: Bool = false) {
        super.init(title, isMutliSelect: isMutliSelect)
        self.selectedItem.value = selected
        
        _ = selectedItem.asObservable().map {[weak self] (items) -> [CRUDConditionType] in
            guard let this = self else { return [] }
            return this.didFinished(for: items)
            }.bind(to: self.finished)
    }
    
    public func didFinished(for items: [T]) -> [CRUDConditionType] {
        return []
    }
}


open class CRUDSortOptions: CRUDTypedOptions<CRUDSort>  {
    
    public typealias OptionsValue = CRUDSort
    
    var values: [CRUDSort] = []
    
    public init(_ title:String, values: [CRUDSort], selected: [CRUDSort] = []) {
        self.values = values
        super.init(title, selected: selected, isMutliSelect: false)
    }
    
    open override func conditionViewController() -> CRUDOptionViewController? {
        let viewController = CRUDValueOptionsViewController(options: self, items: values, selectedItems: selectedItem.value)
        viewController.isMutliSelect = self.isMutliSelect
        return viewController
    }
    
    open override func didFinished(for items: [CRUDSort]) -> [CRUDConditionType] {
        if items.count == 0 {
            self.displayTitle = nil
            return []
        }
        self.displayTitle = "\(items[0])"
        return items
    }
}

public typealias CRUDValueOptions = CRUDFilterOptions

open class CRUDFilterOptions<T: Codable> : CRUDTypedOptions<T> where T: Equatable {
    
    public typealias OptionsValue = T
    // 字段名称
    public var name: String
    
    var values: [OptionsValue] = []
    
    var radioOperator: Operator = .EQUALS
    
    public init(_ title:String, name: String, values: [OptionsValue], selected: [OptionsValue] = [], isMutliSelect: Bool = false, operator: Operator = .EQUALS) {
        self.name = name
        self.values = values
        super.init(title, selected: selected, isMutliSelect: isMutliSelect)
        
        self.radioOperator = `operator`
    }
    
    open override func conditionViewController() -> CRUDOptionViewController? {
        let viewController = CRUDValueOptionsViewController(options: self, items: values, selectedItems: selectedItem.value)
        viewController.isMutliSelect = self.isMutliSelect
        return viewController
    }
    
    open override func didFinished(for items: [T]) -> [CRUDConditionType] {
        if items.count == 0 {
            self.displayTitle = nil
            return []
        }
        
        self.displayTitle = "\(items[0])"
        if isMutliSelect {
            return [CRUDInFilter(field: name, values: items)]
        }else {
            return [CRUDFilter(field: name, op: self.radioOperator, value: items[0])]
        }
    }
}


open class CRUDModelFilterOptions<Model: CRUDModelType> : CRUDFilterOptions<Model> {
    
    public typealias OptionsValue = CRUDModelType
    
    
    public init(_ title:String, name: String, selected: [Model] = [], isMutliSelect: Bool = false) {
        super.init(title, name: name, values: [], selected: selected, isMutliSelect: isMutliSelect)
    }
    
    override open func conditionViewController() -> CRUDOptionViewController? {
        let viewController = CRUDModelOptionsViewController(options: self, selectedItems: selectedItem.value)
        viewController.isMutliSelect = self.isMutliSelect
        return viewController
    }
    
    override open func didFinished(for items: [Model]) -> [CRUDConditionType] {
        if items.count == 0 {
            self.displayTitle = nil
            return []
        }
        
        self.displayTitle = "\(items[0])"
        if isMutliSelect {
            return [CRUDInFilter(field: name, values: modelAllIds(items: items))]
        }else {
            return [CRUDFilter(field: name, op: self.radioOperator, value: modelAllIds(items: items)[0])]
        }

    }
    
    private func modelAllIds(items: [Model]) -> [String]{
        var ids: [String]  = []
        for item in items {
            guard let id = item.id else { continue }
            ids.append(id)
        }
        return ids
    }
}

