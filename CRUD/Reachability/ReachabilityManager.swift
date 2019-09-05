//
//  ReachabilityManager.swift
//  CocoaLumberjack
//
//  Created by hong tianjun on 2019/3/14.
//



import Foundation
import CocoaLumberjack
import RxSwift
import RxCocoa


public class ReachabilityManager: NSObject {
    
    public static let shared = ReachabilityManager()
    
    let reachability = try? Reachability(hostname: "www.baidu.com")
    
    public var reachabilityStatus: Reachability.Connection {
        return reachability?.connection ?? .unavailable
    }
    
    public var isNetworkAvailable: Bool {
        return reachabilityStatus == .cellular || reachabilityStatus == .wifi
    }
    public var isWiFi: Bool {
        return reachabilityStatus == .wifi
    }
    
    
    // outputs
    private let connectionSubject = PublishSubject<Reachability.Connection>()
    public var connection: Driver<Reachability.Connection> {
        return connectionSubject.asDriver(onErrorJustReturn: .unavailable)
    }
    
    
    public func startMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: Notification.Name.reachabilityChanged, object: nil)
        
        do {
            try reachability?.startNotifier()
        }catch   { //ReachabilityError
            DDLogError("启动网络监听出错：\(error)")
            connectionSubject.onError(error)
        }
    }
    
    public func stopMonitoring() {
        reachability?.stopNotifier()
        
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    }
    
    @objc func reachabilityChanged(notification: NSNotification) {
        guard let conn = reachability?.connection else {
            connectionSubject.onNext(.unavailable)
            return
        }
        switch conn {
        case .wifi:
            DDLogDebug("Network reachable through WiFi")
        case .cellular:
            DDLogDebug("Network reachable through Cellular Data")
        case .unavailable:
            DDLogDebug("Network reachable unavailable")
        case .none:
            DDLogDebug("Network reachable none")
        }
        connectionSubject.onNext(conn)
        
    }
}
