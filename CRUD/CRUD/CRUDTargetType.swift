//
//  PanguTargetType.swift
//  Pangu
//
//  Created by hong tianjun on 2018/12/10.
//  Copyright © 2018 hong tianjun. All rights reserved.
//

import Foundation
import Moya
import RxSwift




public enum CRUDTargetType  {
    case list(_ path: String, request: Codable)
}


extension CRUDTargetType :TargetType {
    
    public var baseURL: URL {
        return CRUDEnv.current.baseURL
    }
    
    public var path: String {
        switch self {
        case let .list(path,_):
            return path
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!;
    }
    
    public var task: Task {
        switch self {
        case let .list(_,request):
            return .requestJSONEncodable(request)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
}

