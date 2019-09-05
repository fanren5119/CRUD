//
//  CRUDPickerContainerController.swift
//  fec-inspect-config-ios
//
//  Created by hong tianjun on 2019/6/6.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import Eureka
import UIKit
import Foundation
import RxSwift
import RxCocoa

public protocol CRUDPickerContentViewController: UIViewController {
    associatedtype ContentModel: Equatable
    
    var heightVariable: PublishSubject<Float> { get }
    
    var finishedSubject: PublishSubject<[ContentModel]> { get }
}


open class CRUDPickerContainerController<Model, ContentController: CRUDPickerContentViewController>: PGViewController<PGViewModel> where ContentController.ContentModel == Model {
    
    typealias ContentModel = Model
    
    // 导航Controller
    var navController: PGNavigationController
    // 内容Controller
    var contentViewController: ContentController
    
    // 最小高度
    var minHeight: Float = 256.0
    
    // 输出，内容选项选择后触发此事件
    public var finishedSubject: PublishSubject<[Model]> = PublishSubject<[Model]>()
    
    var maskView: UIView = {
        let view = UIView()
        return view
    }()

    public init(_ contentViewContrroller: ContentController) {
        self.contentViewController = contentViewContrroller
        navController = PGNavigationController(rootViewController: contentViewContrroller)
        super.init(viewModel: PGViewModel())
    
        
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        maskView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        self.view.addSubview(maskView)
        maskView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        addChild(navController)
        navController.willMove(toParent: self)
        self.view.addSubview(navController.view)
        navController.didMove(toParent: self)
        
        navController.view.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(maskView.snp_bottomMargin)
            maker.height.equalTo(44.0)
        }
        
        self.contentViewController.heightVariable.asObservable().subscribe {[weak self] (event) in
            switch event {
            case .next(let h):
                self?.showChildViewControler(h)
            default: break
            }
            }.disposed(by: bag)
        
        self.contentViewController.finishedSubject.bind(to: self.finishedSubject).disposed(by: bag)
    }
    
    @objc func tap(_ gesture: UITapGestureRecognizer) {
        self.hideChildViewControler()
    }
    
    open func finished(_ items: [Model]) {
        
        print(items)
        self.hideChildViewControler()
    }
    
    
    public func showChildViewControler(_ height: Float) {
        let h = min(UIScreen.main.bounds.height - 150.0, CGFloat(height + 44.0))
        navController.view.snp.remakeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(bottomLayoutGuide.snp.bottom)
            maker.height.equalTo(h)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    public func hideChildViewControler() {
        navController.view.snp.remakeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(maskView.snp_bottomMargin)
            maker.height.equalTo(44.0)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { [weak self](success) in
            self?.dismiss(animated: false, completion: nil)
        }
    }
}


//class crudeurkapIckercontroller<Model:Equatable>:CRUDPickerContainerController<Model,CRUDValuePickerController<Model>>,TypedRowControllerType {
//
//    /// The row that pushed or presented this controller
//    var row: RowOf<Model>!
//
//     override open func finished(_ items: [Model]) {
//        super.finished(items)
//        print(items)
//    }
//}
//
//class CRUDEurkaPickerController<Model: Equatable>: CRUDPickerContainerController<Model, CRUDValuePickerController<Model>>,TypedRowControllerType {
//
//    var onDismissCallback: ((UIViewController) -> Void)?
//
//    var row: RowOf<Model>!
//
//    override open func finished(_ items: [Model]) {
//        if items.count == 0 {
//            row.value = nil
//        }else {
//            row.value = items[0]
//        }
//        self.hideChildViewControler()
//        guard let callback = onDismissCallback else { return }
//        callback(self)
//    }
//
//
//}

//open class CRUDValuePickerController<Model: Equatable,Codable>: PGTableViewController<PGListViewModel<Model>>,CRUDPickerContentViewController {
//
//    public var heightVariable: PublishSubject<Float>  = PublishSubject<Float>()
//
//    public var finishedSubject: PublishSubject<[Model]> = PublishSubject<[Model]>()
//
//    init(items: [Model], selectedItems: [Model]) {
//        let viewModel = PGListViewModel(items)
//        viewModel.selectedItems.value = selectedItems
//        super.init(viewModel: viewModel)
//
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
//        self.viewModel.items.asObservable().bind(to: self.tableView.rx.items(cellIdentifier: UITableViewCell.identifier, cellType: UITableViewCell.self)) { [weak self] index,item,cell in
//            self?.cellFor(item: item, index: index, cell: cell)
//            }.disposed(by: bag)
//
//        // 点击
//        self.tableView.rx.itemSelected.subscribe {[weak self] (event) in
//            guard let indexPath = event.element,
//                let item = self?.viewModel.items.value[indexPath.row] else { return }
//            self?.didSelect(item, index: indexPath.row)
//            }.disposed(by: bag)
//
//    }
//
//
//    func cellFor(item: Model, index: Int, cell: UITableViewCell) {
//        cell.textLabel?.text = "\(self.viewModel[index])"
//
//        let isSelected = self.viewModel.selectedItems.value.first { (it) -> Bool in
//            return item == it
//            } != nil
//
//        cell.selectionStyle = .none
//        cell.accessoryType = isSelected ? .checkmark : .none
//    }
//
//    func didSelect(_ item: Model, index: Int) {
//
//        let isSelected = self.viewModel.selectedItems.value.first { (it) -> Bool in
//            return item == it
//            } != nil
//
//
//        if isSelected {
//            self.viewModel.selectedItems.value.removeAll { (it) -> Bool in
//                return item == it
//            }
//            // 通知外部选择变化
//            self.finishedSubject.onNext([])
//        }else {
//            self.viewModel.select(index)
//            // 通知外部选择变化
//            self.finishedSubject.onNext(self.viewModel.selectedItems.value)
//        }
//
////        if let indexPath = self.tableView.indexPathForSelectedRow {
////            indexPaths.append(indexPath)
////        }
//        self.tableView.reloadData()
//
//        // TODO: 此处怎么样小批量更新还需要再考虑
////        self.tableView.reloadRows(at: indexPaths, with: .automatic)
//    }
//
//    open override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//
//        self.heightVariable.onNext(Float(self.viewModel.count) * 44.0)
//    }
//}


open class CRUDModelPickerController<Model: CRUDModelType>: CRUDListViewController<Model, CRUDListViewModel<Model>>,CRUDPickerContentViewController {
    public typealias ContentModel = Model
    
    public var heightVariable: PublishSubject<Float>  = PublishSubject<Float>()
    
    public var finishedSubject: PublishSubject<[Model]> = PublishSubject<[Model]>()
    
    init(items: [Model], selectedItems: [Model]) {
        let viewModel = CRUDListViewModel<Model>()
        viewModel.selectedItems.value = selectedItems
        super.init(viewModel: viewModel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        self.viewModel.items.asObservable().subscribe {[weak self] (event) in
            guard let count = self?.viewModel.count else { return }
            self?.heightVariable.onNext(Float(count) * 44.0)
        }.disposed(by: bag)
        
    }
    
    
    func cellFor(item: Model, index: Int, cell: UITableViewCell) {
        
        cell.textLabel?.text = "\(self.viewModel[index])"
        
        let isSelected = self.viewModel.selectedItems.value.first { (it) -> Bool in
            return item == it
            } != nil
        
        cell.selectionStyle = .none
        cell.accessoryType = isSelected ? .checkmark : .disclosureIndicator
    }
    
    func didSelect(_ item: Model, index: Int) {
        
        let isSelected = self.viewModel.selectedItems.value.first { (it) -> Bool in
            return item == it
            } != nil
        
        
        if isSelected {
            self.viewModel.selectedItems.value.removeAll { (it) -> Bool in
                return item == it
            }
            // 通知外部选择变化
            self.finishedSubject.onNext([])
        }else {
            self.viewModel.select(index)
            // 通知外部选择变化
            self.finishedSubject.onNext(self.viewModel.selectedItems.value)
        }
        
        //        if let indexPath = self.tableView.indexPathForSelectedRow {
        //            indexPaths.append(indexPath)
        //        }
        self.tableView.reloadData()
        
        // TODO: 此处怎么样小批量更新还需要再考虑
        //        self.tableView.reloadRows(at: indexPaths, with: .automatic)
    }

}

class CRUDPickerAreaViewModel: CRUDListViewModel<Area> {
    
    var countSubject: PublishSubject<Int> = PublishSubject<Int>()
    
    func adsf(_ area: Area) {
        let filter = CRUDFilter(field: "parentCode", op: .EQUALS, value: area.code)
        
        let action = CRUDAction<Area>.count(obj: nil, filters: [filter], search: nil, parameters: nil)
        self.provider.request(action, result: Int.self).subscribe(onSuccess: {[weak self] (response) in
            self?.countSubject.onNext(response.result)
        }, onError: { [weak self](error) in
            self?.countSubject.onNext(0)
        }).disposed(by: bag)
    }
    
}


public class CRUDAreaPickerViewController: CRUDModelPickerController<Area> {

    private var parentArea: Area?
    
    var checkViewModel: CRUDPickerAreaViewModel = CRUDPickerAreaViewModel()

    public init(parent: Area?) {
        super.init(items: [], selectedItems: [])
        self.parentArea = parent
        self.viewModel.isMutliSelect = false
        if let area = self.parentArea {
            self.viewModel.filters.value.append(CRUDFilter(field: "parentCode", op: .EQUALS, value: area.code))
        }else {
            self.viewModel.filters.value.append(CRUDFilter(field: "parentCode", op: .EQUALS, value: "100000000000"))
        }
        
        self.checkViewModel.countSubject.subscribe {[weak self] (event) in
            switch event {
            case .next(let count):
                if count > 0 {
                    self?.showSelectedItemController()
                }else {
                    self?.choosed()
                }
            default: break
            }
        }.disposed(by: bag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        var items:[UIBarButtonItem] = []
        for viewController in self.navigationController?.viewControllers ?? [] {
            if let vc = viewController as? CRUDAreaPickerViewController {
                let item = UIBarButtonItem(title: vc.parentArea?.name ?? "中国", style: .done, target: nil, action: nil)
                item.rx.tap.subscribe {[weak self, weak vc] (event) in
                    switch event {
                    case .next(_):
                        self?.navigationController?.popToViewController(vc!, animated: true)
                    default: break
                    }
                    }.disposed(by: bag)
                items.append(item)
            }
        }
        self.navigationItem.leftBarButtonItems = items
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.viewModel.selectedItems.value.count > 0 {
            self.viewModel.unselectAll()
            self.tableView.reloadData()
        }
    }
    
    
    private func checkCurrentAreaChildren() {
        let items = self.viewModel.selectedItems.value
        guard items.count > 0 else {
            return
        }
        self.checkViewModel.adsf(items[0])
    }
    
    private func showSelectedItemController() {
        let items = self.viewModel.selectedItems.value
        guard items.count > 0 else {
            return
        }
        let viewController = CRUDAreaPickerViewController(parent: items[0])
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func choosed() {
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        guard let vc = viewControllers[0] as? CRUDAreaPickerViewController else { return }
        
        var items: [Area] = []
        for viewController in viewControllers {
            guard let vc = viewController as? CRUDAreaPickerViewController,
            let item = vc.selectedArea else { continue }
            
            items.append(item)
        }
        vc.finishedSubject.onNext(items)
    }
    
    public var selectedArea: Area? {
        let items = self.viewModel.selectedItems.value
        guard items.count > 0 else {
            return nil
        }
        return items[0]
    }
    
    override func didSelect(_ item: Area, index: Int) {
        let isSelected = self.viewModel.selectedItems.value.first { (it) -> Bool in
            return item == it
            } != nil
        
        
        if isSelected {
            self.viewModel.selectedItems.value.removeAll { (it) -> Bool in
                return item == it
            }
        }else {
            self.viewModel.select(index)
            checkCurrentAreaChildren()
//            // 通知外部选择变化
//
        }
        
        //        if let indexPath = self.tableView.indexPathForSelectedRow {
        //            indexPaths.append(indexPath)
        //        }
        self.tableView.reloadData()
    }
}
