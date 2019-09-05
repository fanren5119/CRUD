//
//  Provider.swift
//  readingme
//
//  Created by hong tianjun on 2018/5/30.
//  Copyright © 2018年 hong tianjun. All rights reserved.
//

import Moya
import RxSwift
import Result
import CocoaLumberjack


public extension DateFormatter {
    static let chinese: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    static let chineseCustom: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    static let chineseDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
}


public extension Response {
    
    func filterException() throws -> Response {
        do {
            return try filterSuccessfulStatusCodes()
        } catch let error {
            guard let err = error as? MoyaError else {
                throw error
            }
            switch err {
            case .statusCode(let res):
                let code = res.statusCode
                switch code {
                case 500...599:     //服务器错误
                    throw CRUDError.server
                case 404:
                    throw CRUDError.notfound
                case 405:
                    throw CRUDError.notAllowed
                case 400, 401, 403:
                    let messages = try JSONSerialization.jsonObject(with: res.data, options: .allowFragments)
                    guard let msgs = messages as? [String:String] else {
                        throw MoyaError.jsonMapping(res)
                    }
                    var infos = [CRUDBusinessErrorInfo]()
                    for (key,value) in msgs {
                        infos.append(CRUDBusinessErrorInfo(key, value: value))
                    }
                    throw CRUDError.businessError(info: infos, response: res)
                default: throw err
                }
            default:
                throw err
            }
        }
    }
    
    func mapJSONObject<T>(type:T.Type, data: Data) throws -> T where T:Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.chinese)
        do {
            return try decoder.decode(type.self, from: data)
        } catch let error {
            DDLogError("对象映射错误：\(error)")
            throw CRUDError.objectMapping(error.localizedDescription)
        }
    }
}


public extension PrimitiveSequence where TraitType == SingleTrait,ElementType == Response {
    
    func filterException() -> Single<Response> {
        return flatMap { response -> Single<Response> in
            return Single.just(try response.filterException())
        }
    }
    
    
    // 将数据对象转找成实现了JSONObjectSerializable协议的实体对象数组
    func mapJSONObject<T>(type:T.Type) -> Single<T> where T:Decodable  {
        return flatMap { response -> Single<T> in
            return Single.just(try response.mapJSONObject(type: type, data: response.data))
        }
    }
}

public struct DebugPlugin: PluginType {
    
    public init() {
        
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        var req = request.request
        let dic: NSMutableDictionary = NSMutableDictionary.init(dictionary: (req?.allHTTPHeaderFields)!)
        dic.addEntries(from: CRUDConfig.default.getPublicParameters() as! [AnyHashable : Any])
        print("1111fffffff",dic)
        
        #if DEBUG
        let url = request.request?.url?.absoluteString ?? "没有url??"
        let method = (request.request?.httpMethod?.uppercased())!
        DDLogVerbose("\(method):\(url)")
        #endif
    }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case .success(let response):
            if let data = response.request?.httpBody,
                let body = String(data: data, encoding: String.Encoding.utf8) {
                DDLogVerbose(body.replacingOccurrences(of: "\\", with: ""))
            }
            
            do {
                let messages = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments)
                DDLogVerbose("\(messages)")
            } catch {
                DDLogVerbose(String(data: response.data, encoding: String.Encoding.utf8) ?? "")
            }
            
        case .failure(let error):
            if let data = error.response?.request?.httpBody {
                let body = String(data: data, encoding: String.Encoding.utf8)
                DDLogVerbose(String(describing: body))
                let messages = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
                DDLogVerbose("\(messages)")
            }
            DDLogVerbose(error.localizedDescription)
        }
        #endif
    }
}

public class CRUDConfig:NSObject {
    
    public static let `default` :CRUDConfig = CRUDConfig.init()
    
    lazy var pulicParameters:NSMutableDictionary = {
        var dic = NSMutableDictionary()
        return dic
    }()
    
    override init() {
        super.init()
    }
    
    //公共参数
    public func getPublicParameters() -> NSMutableDictionary {
        return self.pulicParameters
    }
    
    public func setParameter(_ parameters: [String:String]) {
        pulicParameters.addEntries(from: parameters)
    }
    
    //增加参数
    public func addParameter(value:String, key:String) {
        pulicParameters.setObject(value, forKey: key as NSCopying)
    }
    
    //删除参数
    public func removeParameterForKey(key:String) {
        pulicParameters.removeObject(forKey: key)
    }
    
    //清空参数
    public func clearParameters() {
        pulicParameters.removeAllObjects()
    }
}


public class CRUDProvider<T: CRUDModelType>: MoyaProvider<CRUDTargetType> {
    
    public init(plugins: [PluginType]) {
        super.init(endpointClosure: {(target) -> Endpoint in
            let url = URL(target: target)
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            
            let headers:NSMutableDictionary =  CRUDConfig.default.getPublicParameters()
            
            return Endpoint(
                url: components?.string ?? url.absoluteString,
                sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                method: target.method,
                task: target.task,
                httpHeaderFields: (headers as! [String : String])
            )
        },plugins: plugins)
    }
    
    public func request<A: CRUDActionType>(_ action: A, path: String? = nil) -> Single<Response> where  T ==  A.ModelType{
        
        var ps: [String] = []
        ps.append(A.ModelType.ver)
        ps.append(A.ModelType.superModel())
        ps.append(A.ModelType.modelName)
        if let p = path {
            ps.append(p)
        }else {
            ps.append(action.path)
        }
        return request(CRUDTargetType.list(ps.joined(separator: "/"), request: action.requestData))
    }
    
    
    public func request<A: CRUDActionType, R: Codable>(_ action: A, result: R.Type, path: String? = nil) -> Single<CRUDResponse<R>> where  T ==  A.ModelType{
 
        var ps: [String] = []
        ps.append(A.ModelType.ver)
        ps.append(A.ModelType.superModel())
        ps.append(A.ModelType.modelName)
        if let p = path {
            ps.append(p)
        }else {
            ps.append(action.path)
        }

        let target = CRUDTargetType.list(ps.joined(separator: "/"), request: action.requestData)
        
        
        return request(target).mapJSONObject(type: CRUDResponse<R>.self)
    }
    
    func request(_ target:CRUDTargetType) -> Single<Response> {
        return self.rx.request(target)
            .filterException()
            .catchError({ (error) -> PrimitiveSequence<SingleTrait, Response> in
                DDLogError("\(error)")
                
                guard let err = error as? CRUDError else { throw error }
                
                switch err {
                case .businessError(let infos, let res):
                    var newInfos = [CRUDBusinessErrorInfo]()
                    for info in infos {
                        let localizedString = "\(T.localizedName(by: info.key) ?? "")\(NSLocalizedString(info.value, comment: ""))"
                        newInfos.append(CRUDBusinessErrorInfo(info.key, value: info.value, localizedString: localizedString))
                    }
                    throw CRUDError.businessError(info: newInfos, response: res)
                default: throw error
                }
            })
    }
}






