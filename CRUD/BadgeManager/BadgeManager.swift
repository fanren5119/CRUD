//
//  BadgeManager.swift
//  Account
//
//  Created by hong tianjun on 2018/12/3.
//

import Foundation
import CocoaLumberjack
import RxCocoa
import RxSwift


public class BadgeNode {
    
    public struct Key: Hashable,Equatable{
        var value = String()
        
        public init(rawValue: String) {
            value = rawValue
        }
        
        public init(_ rawValue: String) {
            value = rawValue
        }
        
        static public let Count = BadgeNode.Key("count")
    }
    
    public var key: Key
    public var value: Variable<Int>
    var children: [BadgeNode] = []
    weak var parent: BadgeNode?
    
    init(_ key: Key, value: Variable<Int>) {
        self.key = key
        self.value = value
    }
    
    public func add(child: BadgeNode) {
        children.append(child)
        child.parent = self
    }
    
    public func search(key: Key) -> BadgeNode? {
        if self.key == key {
            return self
        }
        
        for child in children {
            if let found = child.search(key: key) {
                return found
            }
        }
        return nil
    }
    
    public func recalculate() {
        var sum = 0
        for child in children {
            sum += child.value.value
        }
        self.value.value = sum
        
        self.parent?.recalculate()
    }
    
    public func reset() {
        self.value.value = 0
        for child in children {
            child.reset()
        }
        self.parent?.recalculate()
    }
    
    public func setValue(_ value: Int) {
        self.value.value = value
        
        if let p = self.parent { p.recalculate() }
    }
    
    public func addValue(_ value: Int) -> Void {
        self.value.value += value
        
        self.parent?.recalculate()
    }
}



open class BadgeManager {
    
    private var badges = BadgeNode(BadgeNode.Key.Count, value: Variable<Int>(0))
    
    public init() {
        
    }
    
    public func addBadge(_ key: BadgeNode.Key, to: BadgeNode.Key? = nil) {
        if let badgeKey = to {
            if let badge = badges.search(key: badgeKey) {
                badge.add(child: BadgeNode(key, value: Variable<Int>(0)))
            }
        }else {
            badges.add(child: BadgeNode(key, value: Variable<Int>(0)))
        }
    }
    
    public func badgeObservable(key: BadgeNode.Key) -> Observable<Int>? {
        return badges.search(key: key)?.value.asObservable()
    }
    
    public func reset(key: BadgeNode.Key) {
        if let badge = badges.search(key: key) {
            badge.reset()
        }
    }
    
    public func badge(_ key: BadgeNode.Key) -> BadgeNode? {
        return badges.search(key: key)
    }
    
    public func set(_ value: Int, for key: BadgeNode.Key) {
        if let badge = badges.search(key: key) {
            badge.setValue(value)
        }
    }
    
    public func add(_ add: Int, for key: BadgeNode.Key) {
        if let badge = badges.search(key: key) {
            badge.addValue(add)
        }
    }
}

extension Reactive where Base: UITabBarItem {
    public var badgeValue: Binder<Int> {
        return Binder(self.base) { item, value in
            item.badgeValue = value > 0 ? "\(value)" : nil
        }
    }
    
    public var badgeSign: Binder<Int> {
        return Binder(self.base) { item, value in
            item.badgeValue = value > 0 ? "" : nil
        }
    }
}

extension Reactive where Base: UIBarButtonItem {
    public var badgeValue: Binder<Int> {
        return Binder(self.base) { item, value in
            //            item.badgeV?alue = value > 0 ? "\(value)" : nil
        }
    }
}

extension Reactive where Base: UIButton {
    public var badgeValue: Binder<Int> {
        return Binder(self.base) { item, value in
            //            item.badgeValue = "\(value)"
        }
    }
}
