//
//  CRUDAction.swift
//  Pangu
//
//  Created by hong tianjun on 2019/1/14.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import Foundation

public protocol CRUDActionType {
    associatedtype ModelType: CRUDModelType
    
    var path: String {get}
    
    var name: String {get}
    
    var title: String {get}
    
    var requestData: CRUDRequest<ModelType> { get}
}

public enum CRUDAction<T: CRUDModelType>: CRUDActionType {
    
    case list(obj:T?, page: Int, pageSize: Int, search:CRUDSearch?, filter: [CRUDBaseFilter]?, sort: [CRUDSort]?, ids:[String]?, parameters: [CRUDBaseParameter]?, fields: [CRUDProperty]?)
    case create(_ obj: T, parameters: [CRUDBaseParameter]?)
    case count(obj:T?, filters:[CRUDBaseFilter]? ,search:String?, parameters: [CRUDBaseParameter]?)
    case show(obj:T?, id: String, idField:String?, parameters: [CRUDBaseParameter]?,fields: [CRUDProperty]?)
    case update(obj: T ,id: String, parameters: [CRUDBaseParameter]?)
    case updateBatch(ids: [String] ,objs: [T], parameters: [CRUDBaseParameter]?)
    case remove(id: String, parameters: [CRUDBaseParameter]?)
    case removeBatch(ids: [String], parameters: [CRUDBaseParameter]?)
    case active(id: String, parameters: [CRUDBaseParameter]?)
    case activeBatch(ids: [String], parameters: [CRUDBaseParameter]?)
    case inactive(id: String, parameters: [CRUDBaseParameter]?)
    case inactiveBatch(ids: [String], parameters: [CRUDBaseParameter]?)
    case delete(id: String, parameters: [CRUDBaseParameter]?)
    case deleteBatch(ids: [String], parameters: [CRUDBaseParameter]?)
    case audit(id: String, parameters: [CRUDBaseParameter]?)
    case auditBatch(ids: [String], parameters: [CRUDBaseParameter]?)
    
    public var requestData: CRUDRequest<T> {
        switch self {
        case .list(let obj, let page, let pageSize, let search, let filters,let sort, let ids, let parameters, let fields):
            return CRUDRequest<T>.list(object: obj, page: page, pageSize: pageSize, search: search, filter:filters, sort:sort, ids: ids, parameters: parameters, fields: fields)
        case .create(let obj, let parameters):
            return CRUDRequest<T>.create(object: obj, parameters: parameters)
        case .count(let obj, let filters ,let search, let parameters):
            return CRUDRequest<T>.count(object:obj, filters:filters ,search: search, parameters: parameters)
        case .show(let obj, _, let field, let parameters, let fields):
            return CRUDRequest<T>.show(object: obj, idField: field, parameters: parameters, fields: fields)
        case .update(let obj ,_, let parameters):
            return CRUDRequest<T>.update(object: obj, parameters: parameters)
        case .updateBatch(let ids, let objs, let parameters):
            return CRUDRequest<T>.updateBatch(ids:ids ,objects: objs, parameters: parameters)
        case .remove(_, let parameters):
            var request =  CRUDRequest<T>()
            request.setupCommonParameters(parameters)
            return request
        case .removeBatch(let ids, let parameters):
            return CRUDRequest<T>.batch(ids:ids, parameters: parameters)
        case .active(_, let parameters):
            var request =  CRUDRequest<T>()
            request.setupCommonParameters(parameters)
            return request
        case .activeBatch(let ids, let parameters):
            return CRUDRequest<T>.batch(ids:ids, parameters: parameters)
        case .inactive(_, let parameters):
            var request =  CRUDRequest<T>()
            request.setupCommonParameters(parameters)
            return request
        case .inactiveBatch(let ids, let parameters):
            return CRUDRequest<T>.batch(ids:ids, parameters: parameters)
        case .delete(_, let parameters):
            var request =  CRUDRequest<T>()
            request.setupCommonParameters(parameters)
            return request
        case .deleteBatch(let ids, let parameters):
            return CRUDRequest<T>.batch(ids:ids, parameters: parameters)
        case .audit(_, let parameters):
            var request =  CRUDRequest<T>()
            request.setupCommonParameters(parameters)
            return request
        case .auditBatch(let ids, let parameters):
            return CRUDRequest<T>.batch(ids:ids, parameters: parameters)
        }
    }
    
    public var name: String {
        let name = String(cString: class_getName(T.self as? AnyClass))
        
        let subNames = name.split(separator: ".")
        if subNames.count > 1 { return String(subNames[1]).lineString.lowercased() }
        return name
    }
    
    public var path: String {
        switch self {
        case .list:
            return ""
        case .create:
            return "create"
        case .count:
            return "count"
        case .show(_, let id, _, _, _):
            return "show/\(id)"
        case .update(_ ,let id,_):
            return "update/\(id)"
        case .updateBatch:
            return "update-batch"
        case .remove(let id):
            return "remove/\(id)"
        case .removeBatch:
            return "remove-batch"
        case .active(let id):
            return "active/\(id)"
        case .activeBatch:
            return "active-batch"
        case .inactive(let id):
            return "inactive/\(id)"
        case .inactiveBatch:
            return "inactive-batch"
        case .delete(let id):
            return "delete/\(id)"
        case .deleteBatch:
            return "delete-batch"
        case .audit(let id):
            return "audit/\(id)"
        case .auditBatch:
            return "audit-batch"
        }
    }
    
    public var title: String {
        switch self {
        case .list:
            return "列表"
        case .create:
            return "新建"
        case .count:
            return "数量"
        case .show:
            return "详情"
        case .update:
            return "更新"
        case .updateBatch:
            return "批量更新"
        case .remove:
            return "删除"
        case .removeBatch:
            return "批量删除"
        case .active:
            return "激活"
        case .activeBatch:
            return "批量激活"
        case .inactive:
            return "失效"
        case .inactiveBatch:
            return "批量失效"
        case .delete:
            return "删除"
        case .deleteBatch:
            return "批量删除"
        case .audit:
            return "审计"
        case .auditBatch:
            return "批量审计"
        }
    }
    
}
