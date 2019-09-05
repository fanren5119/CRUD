//
//  CRUDModule.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/4/23.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import Foundation

public struct CRUDModule {
    
}

extension CRUDModule {
    
    public struct Name : Hashable, Equatable, RawRepresentable {
        public var rawValue: String
        
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        
        public static let sys = CRUDModule.Name("pgdp-sys-actx")
    }
}
