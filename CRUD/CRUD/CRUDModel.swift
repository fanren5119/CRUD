//
//  CRUDModel.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/1/20.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import RxSwift
import Moya

public enum Status: Int16,Codable  {
    case vaild
    case invalid
    case removed = 9
    
    var title: String {
        switch self {
        case .vaild:
            return "有效"
        case .invalid:
            return "已失效"
        case .removed:
            return "已删除"
        }
    }
}

public protocol CRUDModelType: PGModelType, Equatable {
    var id: String? {get set}
    /* 数据状态
     0 - 禁用
     1 - 启用
     9 - 逻辑删除
     */
    var st: Status? {get set}
    // 业务使用状态
    var status: Int16? {get set}
    // 版本号
  //  var v: Int? {get set}
    // 创建时间
    var ct: Float? {get set}
    // 修改时间
    var mt: Float? {get set}
    
    static var ver: String { get }
    
    static var localizedName: String? { get }
    
    static var moduleName: CRUDModule.Name { get }
    //父模块名
    static func superModel() -> String
    
    static func properties() -> [CRUDProperty]
}

extension CRUDModelType {
    
    static var level: Int { return 1 }
    
    public static var ver: String { return "v1" }
    
    public static var moduleName: CRUDModule.Name { return CRUDModule.Name.sys }
    
    public static var localizedName: String? { return nil }
    
    // 获取模型名称
    static var modelName: String {
        let name = "\(type(of: self))"
        
        let subNames = name.split(separator: ".")
        if subNames.count > 1 { return String(subNames[0]).lineString.lowercased() }
        return name.lowercased()
    }
    
    // 获取指定字段名称的CRUDProperty
    static func property(_ name: String) -> CRUDProperty? {
        let fields = properties().filter({ (property) -> Bool in
            return property.name == name
        })
        guard fields.count > 0 else { return nil}
        return fields[0]
    }
    
    static func localizedName(by domain: String) -> String?  {
        var msg = self.localizedName
        let names = domain.split(separator: ".")
        if let fieldName = names.last,
            let property = self.property(String(fieldName)) {
            msg?.append(property.title)
        }
        return msg
    }
}

extension CRUDModelType {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

open class CRUDModel: NSObject, CRUDModelType {
    
    open class func superModel() -> String {
        return ""
    }
    
    open class func properties() -> [CRUDProperty] {
        return []
    }
    
    public var id: String?
    
    public var st: Status?
    
    public var status: Int16?
    
    //public var v: Int?
    
    public var ct: Float?
    
    public var mt: Float?
    
    
    required public override init() {

    }
    
    open class var ver: String { return "v1" }
    
    open class var modelName: String {
        let name = String(cString: class_getName(self))
        
        let subNames = name.split(separator: ".")
        if subNames.count > 1 { return String(subNames[1]).lineString.lowercased() }
        return name.lowercased()
    }
    
    // MARK: CustomStringConvertible
    
    override open var description: String {
        return ""
    }
    
    // MARK: CustomDebugStringConvertible
    
    override open var debugDescription: String {
        return description
    }
}

extension CRUDModel {

    var createTime: Date? {
        guard let interval = self.ct else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(interval))
    }
    
    var updateTime: Date? {
        guard let interval = self.mt else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(interval))
    }
    
    func properties() -> [[String: Any]] {
        var count: UInt32 = 0
        guard let properties = class_copyPropertyList(self.classForCoder, &count) else { return [] }

        var temp = [[String: Any]]()
        for i in 0...(count-1) {
            let name = String(cString: property_getName(properties[Int(i)]))

            let others = ["description", "debugDescription"]
            if let _ = others.first(where: { $0 == name })  { continue }
            print(name)

            guard let attr = property_getAttributes(properties[Int(i)]) else { continue }
            let attributes = String(cString: attr)
            print(attributes)

            guard let value = self.value(forKey: name) else { continue }
            temp.append([name: value])
        }
        properties.deallocate()
        return temp
    }
    
}










