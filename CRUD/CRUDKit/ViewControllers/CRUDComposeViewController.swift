//
//  CRUDComposeViewController.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/1/20.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import RxCocoa
import Eureka
import RxSwift

//
//extension ActionSheetRow : RowConfigType  {
//    public typealias ConfigType = T
//    
//}
//
///**
// *  Protocol that every row type has to conform to.
// */
//public protocol RowConfigType: RowType {
//    
//    associatedtype ConfigType: Equatable
//    
//    init(_ tag: String?, _ config: CRUDValueProperty<ConfigType>)
//}
//
//extension RowConfigType where Self: BaseRow {
//    
//    /**
//     Default initializer for a row
//     */
//    public init(_ tag: String? = nil, _ config: CRUDValueProperty<ConfigType>) {
//        self.init(tag: tag)
//        
//        let sets = RuleSet<ConfigType>()
////        self.add(rule: sets)
//    }
//}
//
//
//protocol CRUDPropertyRowType {
//    
//    func createFormRow() -> BaseRow
//}
//
//extension CRUDValueProperty: CRUDPropertyRowType {
//    
//    func createFormRow() -> BaseRow {
//        switch self.type {
//        case .time:
//            let row = DateTimeRow(tag: "tag")
//            row.add(rule: RuleRequired(msg: "asdfasd", id: nil))
//            return row
//        default:
//            return TextRow()
//        }
//    }
//}
//

open class CRUDFormViewController<M: CRUDModelType>: FormViewController {
    
    public var bag = DisposeBag()
    
    // 主ViewModel
    public let viewModel = CRUDListViewModel<M>()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
}

open class CRUDComposeViewController<M: CRUDModelType>: CRUDFormViewController<M> {

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe(onNext: { [weak self]() in
            self?.save()
        }).disposed(by: bag)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [weak self]() in
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: bag)
        
        
        let section = Section()
        for item in M.properties() {
            section.append(item.row())
        }
        form.append(section)
        
    }
    
    open func save() {
        let errors = form.validate()
        guard errors.count == 0 else {
            print(errors)
            return
        }
        
//        let m = M()
//        for (key,value) in form.values() {
//            print(key,value)
//        }
//        self.viewModel.request(action: .create(m, parameters: nil))
    }
    
    func rows() {
        
        TextRow("") { (row) in
            row.title = ""
        }
        
    }
}
//
//    
//    func createRow<T>(tag: String, property: CRUDValueProperty<T>) -> BaseRow  {
//        switch property.type {
//        case .text:
//            
//            return TextRow("asdfa", { (row) in
//                
//            })
//        case .hidden:
//            return TextRow(tag: tag)
//        case .password:
//            return TextRow(tag: tag)
//        case .texterea:
//            return TextRow(tag: tag)
//        case .select:
//            let row = ActionSheetRow("dfsd", property)
////            row.options = self.options
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
//            return TextRow(tag: tag)
//        }
//    }
//}
//
//
