//
//  CRUD.swift
//  Pangu
//
//  Created by hong tianjun on 2018/12/19.
//  Copyright © 2018 hong tianjun. All rights reserved.
//

import Foundation
import Moya

public protocol CRUDEnvType {
    
    var baseURL: URL { get }
}

public enum CRUDEnv : CRUDEnvType {
    case debug
    case stag
    case production
    case custom(_ baseURL: String)
    
    public var baseURL: URL {
        switch self {
        case .debug: return URL(string: "http://47.100.164.38/api/")!
        case .stag: return URL(string: "http://47.100.164.38:81/api/")!
        case .production: return URL(string: "http://demo.fresheracloud.com/api/")!
        case .custom(let url): return URL(string: url)!
        }
    }
    
    #if DEBUG
    public static var current: CRUDEnv = .debug
    #else
    public static var current: CRUDEnv = .production
    #endif
    
}

public struct CRUD<Base> {
    
    /// Base object to extend.
    public let base: Base
    
    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

/// A type that has reactive extensions.
public protocol CRUDCompatible {
    /// Extended type
    associatedtype CompatibleType: Codable
    
    /// Reactive extensions.
    static var crud: CRUD<CompatibleType>.Type { get set }
    
    /// Reactive extensions.
    var crud: CRUD<CompatibleType> { get set }
}

extension CRUDCompatible {
    /// Reactive extensions.
    public static var crud: CRUD<Self>.Type {
        get {
            return CRUD<Self>.self
        }
        set {
            // this enables using Reactive to "mutate" base type
        }
    }
    
    /// Reactive extensions.
    public var crud: CRUD<Self> {
        get {
            return CRUD(self)
        }
        set {
            // this enables using Reactive to "mutate" base object
        }
    }
}
