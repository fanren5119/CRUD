//
//  CRUDProperty.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/2/19.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import Foundation
import Eureka

public enum CRUDControlType: Int, Codable {
    case text               // 文本框
    case hidden             // 隐藏
    case password           // 密码
    case texterea           // 文本哉
    case select             // 下接选择
    case checkbox           // 复选框
    case radio              // 单选
    case file               // 文件上传
    case number             // 数字类型
    case digits             // 整数
    case time               // 时间
    case email              // 邮件
    case url                // url
    case phone              // 电话
    case debitcard          // 银行卡
    case ipv4               // ipv4地址
    case ipv6               // ipv6地址
    case autocomplete       // 自动填充，展示字段
    case spinner            // 数字调节
    case slider             // 滑块
    case rating             // 评分
    case colorpicker        // 颜色选择
    case ajaxuploader       // Ajax上传
    case richeditor         // 富文本
    case file_mutli         // 多文件上传
    case select_mutli       // 多选
    case droptree           // 下拉数
    case droptree_mutli     // 下拉数多选
    case droptable          // 下拉表格
    case address            // 地址控件
}

public protocol CRUDPropertyType: Codable {
    // 标题
    var name: String {get}
    // 标题
    var title: String {get}
    // 输入类型
    var `type`: CRUDControlType {get}
    // 占位符
    var placeholder: String? {get set}
    
    func row(by tag: String?) -> BaseRow
}

open class CRUDProperty : CRUDPropertyType {
    
    public var name: String
    
    public var title: String
    
    public var type: CRUDControlType = .text
    
    public var placeholder: String?
    
    public var children: [CRUDProperty] = []
    
    enum CodingKeys:String, CodingKey {
        case name
        case children = "d"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        
        self.title = self.name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        if children.count > 0 {
            try container.encode(["fields": self.children], forKey: .children)
        }
    }
    
    public init(_ name: String, children: [CRUDProperty] = []) {
        self.name = name
        self.title = name
        self.children = children
    }
    
    public init(name: String, title: String? = nil, type: CRUDControlType = .text, placeholder: String? = nil) {
        self.name = name
        if let t = title { self.title = t } else { self.title = name}
        self.type = type
        self.placeholder = placeholder
    }
    
    public func row(by tag: String? = nil) -> BaseRow {
        return TextRow(tag: tag ?? self.name)
    }
}

protocol CRUDTypedPropertyType: CRUDPropertyType {
    
    associatedtype ValueType: Equatable
    
    func propertyType() -> ValueType.Type
}

public class CRUDModelProperty<T: CRUDModelType> : CRUDProperty {
    typealias ValueType = T.Type
    
//    open var level: Int = 2
    
    
    func propertyType() -> T.Type {
        return T.self
    }
    
    enum ModelCodingKeys:String, CodingKey {
        case name
        case cls = "d"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ModelCodingKeys.self)
        try container.encode(self.name, forKey: .name)
        
        
        
//        if T.level == level { return }
//        level -= 1
        try container.encode(["fields": T.properties()], forKey: .cls)
    }
    
//    public init(name: String, title: String? = nil, type: CRUDControlType = .text, placeholder: String? = nil, level: Int = 1) {
//        super.init(name: name, title: title, type: type, placeholder: placeholder)
//        self.level = level
//    }
//
//    required public init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
    
    public override func row(by tag: String? = nil) -> BaseRow {
        switch self.type {
        case .select:
            let row = PushRow<T>(tag: self.name)
            row.title = self.title
            return row
        default:
            return super.row()
        }
    }
}

public class CRUDBoolProperty: CRUDProperty, CRUDTypedPropertyType {
    typealias ValueType = Bool
    
    func propertyType() -> Bool.Type {
        return Bool.self
    }
    
    public init(name: String, title: String? = nil, type: CRUDControlType = .text, placeholder: String? = nil, rules:[CRUDValidationType<Bool>]? = nil) {
        super.init(name: name, title: title, type: type, placeholder: placeholder)
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public override func row(by tag: String? = nil) -> BaseRow {
        switch self.type {
        case .checkbox:
            let row = SwitchRow(tag: self.name)
            row.title = self.title
            return row
        default:
            return super.row()
        }
    }
}

public class CRUDValueProperty<T:Comparable>: CRUDProperty, CRUDTypedPropertyType {

    public typealias ValueType = T
    public func propertyType() -> T.Type {
        return T.self
    }
    // 验证规则
    let rules: [CRUDValidationType<T>]?
    
    public init(name: String, title: String? = nil, type: CRUDControlType = .text, placeholder: String? = nil, rules:[CRUDValidationType<T>]? = nil) {
        self.rules = rules
        super.init(name: name, title: title, type: type, placeholder: placeholder)
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func createRuleSet() -> RuleSet<T> {
        guard let rules = self.rules else { return RuleSet<T>() }
        
        
        var ruleSet = RuleSet<ValueType>()
        for rule in rules {
            switch rule {
            case .required(let msg):
                ruleSet.add(rule: RuleRequired(msg: msg ?? "", id: nil))
            case .true(let msg):
                ruleSet.add(rule: RuleRequired(msg: msg ?? "", id: nil))
                
            case .false(let msg):
                ruleSet.add(rule: RuleRequired(msg: msg ?? "", id: nil))
            case .gte(let value, let msg):
                ruleSet.add(rule: RuleGreaterThan(min: value, msg: msg, id: nil))
            case .lte(let value, let msg):
                ruleSet.add(rule: RuleSmallerOrEqualThan(max: value, msg: msg, id: nil))
            case .number(let msg):
                ruleSet.add(rule: RuleClosure(closure: { (num) -> ValidationError? in
                    // 校验规则 ValidationError
                    return nil
                }))
            case .range(let begin, let end, let msg):
                guard let max = end as? UInt, let min = begin as? UInt else { break }
//                row.add(rule: RuleRequired())
//                row.add(rule: RuleMaxLength(maxLength: 1))
//                                row.add<ValueType>(rule: RuleMaxLength(maxLength: 10))
            //                ruleSet.add(rule: RuleMinLength(minLength: min, msg: msg, id: nil))
            case .befor(let time, let msg):
//                 ruleSet.add(rule: RuleGreaterThan<T>(min: time, msg: msg, id: nil))
                break
            case .after(let time, let msg):
                ruleSet.add(rule: RuleRequired(msg: msg ?? "", id: nil))
            case .regex(let regex, let msg):
                let prompt = msg ?? ""
//                ruleSet.add(rule: RuleRegExp(regExpr: regex, allowsEmpty: false, msg: prompt, id: nil))
            }
        }
        return ruleSet
    }
    
    
    public override func row(by tag: String? = nil) -> BaseRow {
        switch self.type {
        case .text:
            return TextRow(tag: self.name)
        case .hidden:
            return TextRow(tag: tag)
        case .password:
            let row = PasswordRow(tag: tag)
            if let _ = self.rules {
                row.add(ruleSet: createRuleSet() as! RuleSet<String>)
            }
            return row
        case .texterea:
            let row = TextAreaRow(tag: tag)
            return row
        case .checkbox:
            return TextRow(tag: tag)
        case .radio:
            return TextRow(tag: tag)
        case .file:
            return TextRow(tag: tag)
        case .number:
            return TextRow(tag: tag)
        case .digits:
            return TextRow(tag: tag)
        case .time:
            let row = DateTimeRow(tag: tag)
//                        if let rules = self.rules,
//                            let ruleSet = self.createRuleSet(rules) as? RuleSet<Date> {
//                            row.add(ruleSet: ruleSet)
//                        }
            return row
        case .email:
            return TextRow(tag: tag)
        case .url:
            return TextRow(tag: tag)
        case .phone:
            return TextRow(tag: tag)
        case .debitcard:
            return TextRow(tag: tag)
        case .ipv4:
            return TextRow(tag: tag)
        case .ipv6:
            return TextRow(tag: tag)
        case .autocomplete:
            return TextRow(tag: tag)
        case .spinner:
            return TextRow(tag: tag)
        case .slider:
            return TextRow(tag: tag)
        case .rating:
            return TextRow(tag: tag)
        case .colorpicker:
            return TextRow(tag: tag)
        case .richeditor:
            return TextRow(tag: tag)
        case .file_mutli:
            return TextRow(tag: tag)
        default:
            return super.row(by: tag)
        }
    }
}

//public class CRUDOptionsProperty<T:Equatable>: CRUDValueProperty<T> {
//    
//    
//    // 可选项
//    var options: [T]?
//    // 可选项关联的实体
//    var optionClass: CRUDModelType?
//    
//    init(name: String, title: String? = nil,type: CRUDControlType = .text, placeholder: String? = nil, rules:[CRUDValidationType<T>]? = nil, options: [T]? = nil, optionClass:CRUDModelType? = nil) {
//        self.options = options
//        self.optionClass = optionClass
//        super.init(name: name, title: title, type: type, placeholder: placeholder)
//        
//    }
//    
//    required public init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
//    
//    public override func row(by tag: String?) -> BaseRow {
//        switch self.type {
//        case .text:
//            return TextRow(tag: tag)
//        case .hidden:
//            return TextRow(tag: tag)
//        case .password:
//            return TextRow(tag: tag)
//        case .texterea:
//            return TextRow(tag: tag)
//        case .select:
//            let row = ActionSheetRow<T>(tag: tag)
//            row.options = self.options
//            return row
//        case .checkbox:
//            return TextRow(tag: tag)
//        case .radio:
//            return TextRow(tag: tag)
//        case .file:
//            return TextRow(tag: tag)
//        case .number:
//            return TextRow(tag: tag)
//        case .digits:
//            return TextRow(tag: tag)
//        case .time:
//            let row = DateTimeRow(tag: tag)
//            row.add(rule: RuleRequired<Date>(msg: "asdfasd", id: nil))
//            return row
//        case .email:
//            return TextRow(tag: tag)
//        case .url:
//            return TextRow(tag: tag)
//        case .phone:
//            return TextRow(tag: tag)
//        case .debitcard:
//            return TextRow(tag: tag)
//        case .ipv4:
//            return TextRow(tag: tag)
//        case .ipv6:
//            return TextRow(tag: tag)
//        case .autocomplete:
//            return TextRow(tag: tag)
//        case .spinner:
//            return TextRow(tag: tag)
//        case .slider:
//            return TextRow(tag: tag)
//        case .rating:
//            return TextRow(tag: tag)
//        case .colorpicker:
//            return TextRow(tag: tag)
//        case .ajaxuploader:
//            return TextRow(tag: tag)
//        case .richeditor:
//            return TextRow(tag: tag)
//        case .file_mutli:
//            return TextRow(tag: tag)
//        case .select_mutli:
//            return TextRow(tag: tag)
//        case .droptree:
//            return TextRow(tag: tag)
//        case .droptree_mutli:
//            return TextRow(tag: tag)
//        case .droptable:
//            return TextRow(tag: tag)
//        case .address:
//            return TextRow(tag: tag)
//        default:
//            return super.row(by: tag)
//        }
//    }
//}

