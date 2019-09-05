//
//  String+Ex.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/1/21.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import Foundation

extension String {
    
    public var lineString: String {
        let str = NSMutableString(string: self)
        let regex = try! NSRegularExpression(pattern: "[A-Z]", options: NSRegularExpression.Options(rawValue:0))
        let res = regex.replaceMatches(in: str, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(1, str.length-1), withTemplate: "-$0")
        if res > 0  { return str.lowercased as String }
        return self
    }
}
