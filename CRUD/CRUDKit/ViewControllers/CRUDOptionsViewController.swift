//
//  CRUDOptionsViewController.swift
//  Installer
//
//  Created by hong tianjun on 2019/4/13.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import Foundation
import RxSwift
import CocoaLumberjack

open class CRUDValueOptionsViewController<T: Codable, O: CRUDTypedOptionsType>: PGTableViewController<PGListViewModel<T>>, CRUDOptionsViewControllerType where O.OptionsValue == T {
    
    public var containerController: CRUDOptionsContainerViewController?
    
    public var isMutliSelect: Bool = false
    
    public func clear() {
        self.viewModel.unselectAll()
        self.tableView.reloadData()
    }
    
    public func selectAll() {
        self.viewModel.selectAll()
        self.tableView.reloadData()
    }
    
    public func finishedSelection() {
        self.options?.selectedItem.value = self.viewModel.selectedItems.value
    }
    
    
    public var options: O?
    
    
    init(options: O, items: [T], selectedItems: [T]) {
        let viewModel = PGListViewModel<T>(items)
        viewModel.selectedItems.value = selectedItems
        self.options = options
        super.init(viewModel: viewModel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.isMutliSelect = self.isMutliSelect
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        self.viewModel.items.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: UITableViewCell.identifier, cellType: UITableViewCell.self)) { [weak self] index,item,cell in
            self?.cellFor(item: item, index: index, cell: cell)
            }.disposed(by: bag)
        
        // 点击
        self.tableView.rx.itemSelected.subscribe {[weak self] (event) in
            guard let indexPath = event.element,
                let item = self?.viewModel.items.value[indexPath.row] else { return }
            self?.didSelect(item, index: indexPath.row)
            }.disposed(by: bag)
    }
    
    
    func cellFor(item: T, index: Int, cell: UITableViewCell) {
        cell.textLabel?.text = "\(self.viewModel[index])"
        
        let isSelected = self.viewModel.selectedItems.value.first { (it) -> Bool in
            return item == it
            } != nil
        
        cell.accessoryType = isSelected ? .checkmark : .none
    }
    
    func didSelect(_ item: T, index: Int) {
        
        let isSelected = self.viewModel.selectedItems.value.first { (it) -> Bool in
            return item == it
            } != nil
        if isSelected {
            self.viewModel.selectedItems.value.removeAll { (it) -> Bool in
                return item == it
            }
        }else {
            self.viewModel.select(index)
        }
        
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        
        guard let mutliSelect = self.options?.isMutliSelect, mutliSelect  else {
            self.finishedSelection()
            self.containerController?.removeFromParentController()
            return
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.containerController?.reset(height: CGFloat(self.viewModel.count * 44))
    }
}

open class CRUDModelOptionsViewController<T: CRUDModelType,O: CRUDTypedOptionsType>: CRUDListViewController<T, CRUDListViewModel<T>>, CRUDOptionsViewControllerType where O.OptionsValue == T {
    
    
    public func finishedSelection() {
        self.options?.selectedItem.value = self.viewModel.selectedItems.value
    }
    
    public var containerController: CRUDOptionsContainerViewController?
    
    public var isMutliSelect: Bool = false
    
    public func clear() {
        self.viewModel.unselectAll()
        self.tableView.reloadData()
    }
    
    public func selectAll() {
        self.viewModel.selectAll()
        self.tableView.reloadData()
    }
    
    public var options: CRUDModelFilterOptions<T>!
    
    public init(options: O, viewModel: CRUDListViewModel<T>, selectedItems: [T]) {
        viewModel.selectedItems.value = selectedItems
        self.options = options as? CRUDModelFilterOptions<T>
        super.init(viewModel: viewModel)
    }
    
    public init(options: O, selectedItems: [T]) {
        let viewModel = CRUDListViewModel<T>()
        viewModel.selectedItems.value = selectedItems
        self.options = options as? CRUDModelFilterOptions<T>
        super.init(viewModel: viewModel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.isMutliSelect = self.isMutliSelect
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        self.viewModel.items.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: UITableViewCell.identifier, cellType: UITableViewCell.self)) { [weak self] index,item,cell in
            self?.cellFor(item: item, index: index, cell: cell)
            }.disposed(by: bag)
        
        // 点击
        self.tableView.rx.itemSelected.subscribe {[weak self] (event) in
            guard let indexPath = event.element,
                let item = self?.viewModel.items.value[indexPath.row] else { return }
            self?.didSelect(item, index: indexPath.row)
            }.disposed(by: bag)
        
        self.tableView.mj_header.beginRefreshing()
    }
    
    func cellFor(item: T, index: Int, cell: UITableViewCell) {
        cell.textLabel?.text = "\(item)"
        
        cell.accessoryType = self.viewModel.isSelected(item) ? .checkmark : .none
    }
    
    func didSelect(_ item: T, index: Int) {
        if self.viewModel.isSelected(item) {
            self.viewModel.unselect(item)

        }else {
            self.viewModel.select(index)
        }
        
        if !self.isMutliSelect {
            self.finishedSelection()
            self.containerController?.removeFromParentController()
        }
        
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewModel.items.asObservable().subscribe {[weak self] (event) in
            guard let count = self?.viewModel.items.value.count else { return }
            guard count > 0 else { return }
            
            self?.containerController?.reset(height: CGFloat(count * 44))
            }.disposed(by: bag)
    }
}


//open class CRUDDictionaryOptionViewController: CRUDModelOptionsViewController<dictionary>, CRUDOptionsType {
//    
//    open func setOptions(_ options: CRUDOptions) {
//        guard let aa = options as? CRUDDictionaryOptions<T> else { return }
//        self.options = aa
//    }
//
//    public var options: CRUDDictionaryOptions<T>!
//    
//    
//    
//    public init(code: String, selectedItems: [dictionary]) {
//        super.init(selectedItems: selectedItems)
//        self.viewModel.filters.value = [CRUDFilter(field: "pdCode", op: .EQUALS, value: "position")]
//    }
//    
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//}
