//
//  CRUDValidation.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/1/23.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import Foundation

public enum CRUDValidationType<T> {
    case required(msg:String?)                           // 不能为空
    case `true`(msg:String?)                             // 必须为真
    case `false`(msg:String?)                            // 必须为假
    case gte(value: T, msg:String?)                      // 大于等于
    case lte(value: T, msg:String?)                      // 小于等于
    case number(msg:String?)                             // 数字
    case range(begin: T, end: T, msg:String?)            // 区间
    case befor(time: Date, msg:String?)                  // 在时间之前
    case after(time: Date, msg:String?)                  // 在时间之后
    case regex(regex: String, msg:String?)               // 正则表达式
}
