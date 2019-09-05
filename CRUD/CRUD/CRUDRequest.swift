//
//  CRUDRequest.swift
//  Pangu
//
//  Created by hong tianjun on 2018/12/21.
//  Copyright © 2018 hong tianjun. All rights reserved.
//

import Foundation

public protocol CRUDRequestType: Codable {
    associatedtype ModelType: Codable
    
}

//分页设置
public struct CRUDPage: Codable {
    // page
    public var p: Int = 0
    // page size
    public var ps: Int = 20
    // total page
    public var tp: Int?
    // total sencodd
    public var ts: Int?
    
    public init(page: Int = 1, pageSize: Int = 20) {
        self.p = page
        self.ps = pageSize
    }
}

public protocol CRUDConditionType: Codable {
    
}
// 查询
public struct CRUDSearch: CRUDConditionType, Codable {
    
    let key: String
    let fields: [String]
    public init(_ key: String, fields:[String]) {
        self.key = key
        self.fields = fields
    }
}
// 排序
public struct CRUDSort: CRUDConditionType, Codable, Equatable, CustomStringConvertible{
    let field: String
    let isDesc: Bool
    var title: String?
    
    enum CodingKeys: CodingKey {
        case field
        case isDesc
    }
    
    public init(_ name: String, isDesc: Bool = false, title: String? = nil) {
        self.field = name
        self.isDesc = isDesc
        self.title = title
    }
    
    
    public var description: String {
        guard let t = title else {
            return field
        }
        return t
    }
    
    public static func == (lhs: CRUDSort, rhs: CRUDSort) -> Bool {
        return lhs.field == rhs.field && lhs.isDesc == rhs.isDesc
    }
}


public enum Operator: String, Codable {
    case EQUALS = "EQUALS"  // 等于
    case NE = "NE"          // 不等于
    case GT = "GT"          // 大于
    case LT = "LT"          // 小于
    case GTE = "GTE"        // 大于等于
    case LTE = "LTE"        // 小于等于
    case BETWEEN = "BETWEEN"    // 区间
    case LIKE = "LIKE"      // 模糊匹配
    case IN = "IN"          // 包含
    case ISNULL = "ISNULL"  //
    case NOTNULL = "NOTNULL"
    case DISCOUNT = "NOTNULL22"
    case ALLOF = "ALLOF"
}


public class CRUDBaseFilter: CRUDConditionType, Codable {
    public let field: String
    public let `operator`: Operator
    
    public init(field: String, op: Operator) {
        self.field = field
        self.operator = op
    }
    
}

// 过滤条件
public class CRUDFilter<F: Codable>: CRUDBaseFilter, CustomStringConvertible {
    public let value: F
    
    
    public init(field: String, op: Operator, value: F) {
        self.value = value
        super.init(field: field, op: op)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    enum CodingKeys: CodingKey {
        case field
        case `operator`
        case value
        case value_to
        case values
    }
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
    
    public var description: String { return "\(field) \(`operator`) \(value)" }
}


public class CRUDBetweenFilter<F: Codable>: CRUDBaseFilter ,CustomStringConvertible{
    public let value: F
    public let value_to: F
    
    
    public init(field: String,value: F, to: F) {
        self.value = value
        self.value_to = to
        super.init(field: field, op: .BETWEEN)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    enum CodingKeys: CodingKey {
        case field
        case `operator`
        case value
        case value_to
        case values
    }
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(value_to, forKey: .value_to)
    }
    
    public var description: String { return "\(field) \(`operator`) \(value) -- \(value_to)" }
}


public class CRUDInFilter<F: Codable>: CRUDBaseFilter, CustomStringConvertible {
    public let values: [F]
    
    
    public init(field: String, values:[F], op: Operator = .IN) {
        self.values = values
        super.init(field: field, op: op)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    enum CodingKeys: CodingKey {
        case field
        case `operator`
        case value
        case value_to
        case values
    }
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(values, forKey: .values)
    }
    
    public var description: String { return "\(field) \(`operator`) \(values)" }
}

public class CRUDBaseParameter: Codable {
    var key: String
    
    init(key: String) {
        self.key = key
    }
}


public class CRUDParameter<T: Codable>: CRUDBaseParameter {
    
    var value: T
    
    public init(_ key: String, value: T) {
        self.value = value
        super.init(key: key)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    enum CodingKeys: CodingKey {
        case name
        case value
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.value, forKey: .value)
    }
}

open class CRUDBaseField: Codable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

public class CRUDField<T: CRUDModelType>: CRUDBaseField where T: Equatable {
    
    var cls: CRUDRequest<T>.Type?
    var value: T?
    
    init(name:String, cls: CRUDRequest<T>? = nil) {
        super.init(name: name)
        self.cls = CRUDRequest<T>.self
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    enum CodingKeys:String, CodingKey {
        case name
        case cls = "d"
    }
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        
        let fields = self.cls?.fields()
        try container.encode(fields, forKey: .cls)
    }
}

func ==<T> (left: CRUDField<T>, right: CRUDField<T>) -> Bool {
    return left.value == right.value
}



public struct CRUDCommonParameter: Codable {
    
    public static var `default` = CRUDCommonParameter()
    
    var parameters: [CRUDBaseParameter] = []
    
    public mutating func add(_ parameter: CRUDBaseParameter) {
        self.parameters.append(parameter)
    }
    
    public mutating func add<T: Codable>(_ key: String, value: T) {
        self.parameters.append(CRUDParameter(key, value: value))
    }
    
    public mutating func remove(_ key: String) {
        self.parameters = parameters.filter { (parameter) -> Bool in
            return !(parameter.key == key)
        }
    }
    
    public mutating func clear() {
        self.parameters.removeAll()
    }
}


public struct CRUDRequest<T>: Codable where T: CRUDModelType{

    
    //条件设置
    public struct CRUDCondition: Codable {
        public var alters: [[String: String]]? = nil
        public var fields: [CRUDProperty]? = nil
        public var filters: [CRUDBaseFilter]? = nil
        public var sorts: [CRUDSort]? = nil
        public var search: CRUDSearch? = nil
        public var c: [CRUDBaseParameter]? = nil
        
        public var idField: String? = nil
        public var page: CRUDPage? = nil
        public var retFields: Bool?
        public var retFilters: Bool?
        public var retOnlySt: Bool = false
        public var retPage: Bool?
        public var retSearch: Bool?
        public var retSorts: Bool?
    }
    
    public var condition: CRUDCondition = CRUDCondition()
    public var ids: [String]? = nil
    public var obj: T?
    
    enum CodingKeys:String, CodingKey {
        case condition = "d"
        case ids = "i"
        case obj
    }
    
    init() {
    }
    
    init(object: T) {
        self.obj = object
    }
    
    //为了保证所有数据有效，添加filters必须调用此方法
    public mutating func addFilter(_ filter: [CRUDBaseFilter]) {
        if self.condition.filters == nil {
            self.condition.filters = [CRUDFilter(field: "st", op: .NE, value: 9)]
        }
        self.condition.filters?.append(contentsOf: filter)
    }
    
    public mutating func addParameter(_ parameter: CRUDBaseParameter) {
        if self.condition.c == nil {
            self.condition.c = []
        }
        self.condition.c?.append(parameter)
    }
    
    public mutating func setupCommonParameters(_ parameters: [CRUDBaseParameter]? = nil) {
        if var p = parameters {
            p.append(contentsOf: CRUDCommonParameter.default.parameters)
            self.condition.c = p
        }else {
            self.condition.c = CRUDCommonParameter.default.parameters
        }
    }
    
    
    public static func list(object:T? = nil, page: Int, pageSize: Int, search:CRUDSearch? = nil, filter: [CRUDBaseFilter]? = nil, sort: [CRUDSort]? = nil, ids:[String]? = nil, parameters: [CRUDBaseParameter]? = nil, fields: [CRUDProperty]? = nil) -> CRUDRequest {
        var request = CRUDRequest()
        request.obj = object
        // 指定页面
        request.condition.page = CRUDPage(page: page, pageSize: pageSize)
        request.condition.retPage = true
        // 指定ID
        if let i = ids, i.count > 0 { request.ids = i }
        // 排序条件
        if let t = sort, t.count > 0 { request.condition.sorts = t }
        // 搜索条件
        if let s = search {
            request.condition.search = s
        }
        // 过滤条件
        if let f = filter, f.count > 0 {
            request.addFilter(f)
        }
        
        // 显示字段
        if let d = fields, d.count > 0 {
            request.condition.fields = d
        }else {
            request.condition.fields = T.properties()
        }
        //
        // 设置自定义，或公共参数
        request.setupCommonParameters(parameters)
        return request
    }
    
    public static func fields() -> [CRUDProperty] {
        return T.properties()
    }
    
    public static func create(object: T, parameters: [CRUDBaseParameter]? = nil) -> CRUDRequest {
        var request = CRUDRequest()
        request.obj = object
        // 设置自定义，或公共参数
        request.setupCommonParameters(parameters)
        return request
    }
    
    public static func show(object:T?, idField:String?, parameters: [CRUDBaseParameter]? = nil, fields: [CRUDProperty]? = nil) -> CRUDRequest {
        var request = CRUDRequest()
        request.obj = object
        request.condition.idField = idField
        // 显示字段
        if let d = fields, d.count > 0 {
            request.condition.fields = d
        }else {
            request.condition.fields = T.properties()
        }
        // 设置自定义，或公共参数
        request.setupCommonParameters(parameters)
        return request
    }
    
    public static func batch(ids: [String], parameters: [CRUDBaseParameter]? = nil) -> CRUDRequest {
        var request = CRUDRequest()
        request.ids = ids
        // 设置自定义，或公共参数
        request.setupCommonParameters(parameters)
        return request
    }
    
    public static func update(object: T, parameters: [CRUDBaseParameter]? = nil) -> CRUDRequest {
        var request = CRUDRequest()
        request.obj = object
        // 设置自定义，或公共参数
        request.setupCommonParameters(parameters)
        return request
    }
    
    public static func updateBatch(ids: [String] ,objects: [T], parameters: [CRUDBaseParameter]? = nil) -> CRUDRequest {
        var request = CRUDRequest()
        // 设置自定义，或公共参数
        request.setupCommonParameters(parameters)
        return request
    }
    
    public static func count(object: T?, filters: [CRUDBaseFilter]? = nil ,search: String? = nil, parameters: [CRUDBaseParameter]? = nil) -> CRUDRequest {
        var request =  CRUDRequest()
        request.obj = object
        request.addFilter(filters ?? [])
        // 设置自定义，或公共参数
        request.setupCommonParameters(parameters)
        return request
    }
    
}

public struct CRUDResponse<T: Codable>: Codable {
    public var page: CRUDPage?
    public let result: T
    
    public init(result: T) {
        self.result =  result
    }
}
