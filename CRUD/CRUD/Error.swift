//
//  JSON.swift
//  Health
//
//  Created by hong tianjun on 2018/9/19.
//  Copyright © 2018 hong tianjun. All rights reserved.
//

import Foundation
import Moya

public protocol JSONObjectSerializable {
    
    init(json:[String: Any]) throws;
}

public struct CRUDErrorCode: RawRepresentable, Equatable, Hashable {
    public var rawValue: String
    
    public typealias RawValue = String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension CRUDErrorCode {
    
    //已存在
    static let existed = CRUDErrorCode(rawValue: "exist")
    //不存在
    static let notFound = CRUDErrorCode(rawValue: "not_exist")
    //必须为空
    static let beNull = CRUDErrorCode(rawValue: "must_be_null")
    //不能为空
    static let beNotNull = CRUDErrorCode(rawValue: "must_not_be_null")
    //必须为True
    static let beTrue = CRUDErrorCode(rawValue: "must_be_true")
    //
//    static let beFalse = CRUDErrorCode(rawValue: "must_be_false")
//    static let mustGtOrGte = CRUDErrorCode(rawValue: "must_gt_or_gte")
//    static let mustLtOrLte = CRUDErrorCode(rawValue: "must_lt_or_lte")
//    static let must = CRUDErrorCode(rawValue: "size_must_between")
//    static let code = CRUDErrorCode(rawValue: "must_be_number")
//    static let code = CRUDErrorCode(rawValue: "must_be_past")
//    static let code = CRUDErrorCode(rawValue: "must_be_future")
//    static let code = CRUDErrorCode(rawValue: "must_match_regex")
//    static let mismatch = CRUDErrorCode(rawValue: "not_allowed")
//    static let notSupported = CRUDErrorCode(rawValue: "not_supported")
    static let notBeEmpty = CRUDErrorCode(rawValue: "must_not_be_empty")
//    static let email = CRUDErrorCode(rawValue: "must_be_email")
//    static let auhtorized = CRUDErrorCode(rawValue: "token_errors_auhtorized")
//    static let malformed = CRUDErrorCode(rawValue: "token_errors_malformed")
//    static let expired = CRUDErrorCode(rawValue: "token_errors_expired")
//    static let signature = CRUDErrorCode(rawValue: "token_errors_signature")
//    static let code = CRUDErrorCode(rawValue: "acc_or_pwd_errors")
}


public struct CRUDErrorInfo {
    
}

public extension Error {
    
    func errorMessage() -> String {
        guard let err = self as? CRUDError else {
            guard let moyaError = self as? MoyaError else {
                return self.localizedDescription
            }
            return moyaError.errorDescription
        }
        return err.localizedDescription
    }
}

public struct CRUDBusinessErrorInfo {
    
    var key: String
    var value: String
    var localizedString: String?
    
    var code: CRUDErrorCode {
        return CRUDErrorCode(rawValue: value)
    }
    
    public init(_ key: String, value: String, localizedString: String? = nil) {
        self.key = key
        self.value = value
        self.localizedString = localizedString
    }
}


public enum CRUDError: Error {
    case notfound
    case server
    case notAllowed
    case businessError(info: [CRUDBusinessErrorInfo], response:Response)
    case objectMapping(String)
    case invalidImage
    case expiredToken
    
    public typealias Code = CRUDErrorCode
}

extension CRUDError {
    
    public var code: Code? {
        switch self {
        case .businessError(let info, _):
            guard let code = info.first?.value else { return nil }
            return CRUDErrorCode(rawValue: code)
        case .objectMapping(_):
            return nil
        case .invalidImage:
            return nil
        case .expiredToken:
            return nil
        case .notfound:
            return nil
        case .server:
            return nil
        case .notAllowed:
            return nil
        }
    }
    
    public var domain: String? {
        switch self {
        case .businessError(let info, _):
            guard let key = info.first?.key else { return nil }
            return key
        case .objectMapping(_):
            return nil
        case .invalidImage:
            return nil
        case .expiredToken:
            return nil
        case .notfound:
            return nil
        case .server:
            return nil
        case .notAllowed:
            return nil
        }
    }
}

extension CRUDError : LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .businessError(let info, _):
            guard let code = info.first?.value else { return nil }
            guard let str = info.first?.localizedString else { return code }
            return str
        case .objectMapping(let str):
            return "对象映射错误\(str)"
        case .invalidImage:
            return "无效的图片"
        case .expiredToken:
            return "用户Token失效"
        case .notfound:
            return "找不到资源"
        case .server:
            return "服务器罢工了"
        case .notAllowed:
            return "错误的方法调用"
        }
    }
}

extension MoyaError {
    
    public var errorDescription: String {
        switch self {
        case .imageMapping:
            return "Failed to map data to an Image.(转换图片出错)"
        case .jsonMapping:
            return "Failed to map data to JSON.(转换JSON出错)"
        case .stringMapping:
            return "Failed to map data to a String.(转换字符串出错)"
        case .objectMapping:
            return "Failed to map data to a Decodable object.(转换对象出错)"
        case .encodableMapping:
            return "Failed to encode Encodable object into data."
        case .statusCode(let res):
            return "Status code didn't fall within the given range.(HTTP返回错误:\(res.statusCode)"
        case .requestMapping(let str):
            return "Failed to map Endpoint to a URLRequest.(请求错误\(str)"
        case .parameterEncoding(let error):
            return "Failed to encode parameters for URLRequest. (参数错误:\(error.localizedDescription)"
        case .underlying(let error, let response):     //此处为网络层错误，需要提示用户处理用户网络
            #if DEBUG
            return "查看你的网络连接是否有问题"      //
            #else
            return "未知错误\(error.localizedDescription)\(response)"
            #endif
        }
    }
}
