//
//  AddressOptions.swift
//  fec-inspect-config-ios
//
//  Created by hong tianjun on 2019/4/22.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import RxSwift
import RxCocoa
import CocoaLumberjack

public struct Area: CRUDModelType,CustomStringConvertible {
    public var id: String?
    
    public var st: Status?
    
    public var status: Int16?
    
    public var ct: Float?
    
    public var mt: Float?
    
    public let name: String
    
    public let code: String
    
    public let pinyin: String?
    
    public let parent: String?
    
    public static func superModel() -> String {
        return CRUDModule.Name.sys.rawValue
    }
    
    public static func properties() -> [CRUDProperty] {
        return []
    }

    
    public  var description: String {
        return self.name
    }

}

public class CRUDAreaOptions: CRUDModelFilterOptions<Area>  {
   
    
    public init(_ title:String, selected: [Area] = []) {
        super.init(title, name: "area", selected: selected)
    }
    
    public override func conditionViewController() -> CRUDOptionViewController? {
        let viewController = CRUDAreaOptionsViewController(options: self)
        viewController.isMutliSelect = self.isMutliSelect
        return viewController
    }
    
    override public func didFinished(for items: [Area]) -> [CRUDConditionType] {
        if items.count == 0 {
            self.displayTitle = nil
            return []
        }
        
        
        self.displayTitle = items.last?.name
        if isMutliSelect {
            // 此处应该是选中的多个项
            return []
        }else {
            var fs: [CRUDBaseFilter] = []
            for i in 0 ..< items.count {
                if i == 0 { fs.append(CRUDFilter(field: "province", op: .EQUALS, value: items[i].code))}
                if i == 1 { fs.append(CRUDFilter(field: "city", op: .EQUALS, value: items[i].code))}
                if i == 2 { fs.append(CRUDFilter(field: "county", op: .EQUALS, value: items[i].code))}
                if i == 3 { fs.append(CRUDFilter(field: "street", op: .EQUALS, value: items[i].code))}
            }
            return fs
        }

    }
}


public class CRUDAreaOptionsViewController: PGNavigationController, CRUDOptionsViewControllerType {
    public var containerController: CRUDOptionsContainerViewController?
    
    public var isMutliSelect: Bool = false
    
    public func clear() {}
    
    public func selectAll() {}
    
    public func finishedSelection() {
        self.options?.selectedItem.value = selectedItems
    }
    
    private var items: [UIBarButtonItem] = []
    
    private var viewModel: CRUDListViewModel<Area> = CRUDListViewModel<Area>()
    
    private var selectedItems: [Area] = []
    
    private var currentArea: Area?
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    private var options: CRUDAreaOptions?
    public convenience init(options: CRUDAreaOptions) {
        self.init(nibName: nil, bundle: nil)
        self.options = options
        
        
        _ = viewModel.items.asObservable().filter({[weak self] (areas) -> Bool in
            guard let p = self?.viewModel.page.ts else { return false }
            return (p != 0 && areas.count == 0) ? false : true
        }).subscribe { [weak self](event) in
            switch event {
            case .next(let areas):
                self?.validateCurrentAreaChildren(areas)
            case .error(let error):
                print(error)
            case .completed: break
            }
        }.disposed(by: bag)
    }
    
    private func checkCurrentAreaChildren() {
        let code = currentArea?.code ?? "0"
        self.viewModel.filters.value = [CRUDFilter(field: "parentCode", op: .EQUALS, value: code)]
        self.viewModel.loadFirst()
    }
    
    private func validateCurrentAreaChildren(_ areas: [Area]) {
        // 没有数据怎么处理
        if areas.count == 0 {
            // 整理数据选择完成
            self.generateSelectedItems(all: false)
            self.finishedSelection()
            return
        }
        
        // 有数据，打开相应子viewController
        
        let area = currentArea ?? areas[0]
        let viewController = CRUDAreaViewController(parent: area)
        viewController.choosedItem.subscribe {[weak self] (event) in
            guard let seletion = event.element else { return }
            switch seletion {
            case .all:
                // 整理数据选择完成
                self?.generateSelectedItems(all: true)
                self?.finishedSelection()
            case .one(let item):
                self?.currentArea = item
                self?.checkCurrentAreaChildren()
            default: break
            }
            }.disposed(by: bag)
        self.pushViewController(viewController, animated: true)
    }
    
    private func generateSelectedItems(all: Bool) {
        
        var items:[Area] = []
        for i in 1..<self.viewControllers.count {
            let viewController = self.viewControllers[i]
            if let vc = viewController as? CRUDAreaViewController {
                print(vc.parentArea.name)
                items.append(vc.parentArea)
            }
        }
        if all {} else {
            items.append(currentArea!)
        }
        self.selectedItems = items
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.tintColor = UIColor.black
        self.navigationBar.barTintColor = UIColor.white

        self.checkCurrentAreaChildren()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.containerController?.reset(height: CGFloat(500))
    }
}


public enum Selection<Item> {
    /// 单选
    case one(Item)
    /// 多选
    case mutli([Item])
    // 清空
    case clear
    // 全选
    case all
    
}

public class CRUDAreaViewController: CRUDListViewController<Area, CRUDListViewModel<Area>> {

    
    public var choosedItem: PublishSubject<Selection<Area>> = PublishSubject()
    
    public var parentArea: Area
    
    public init(parent: Area) {
        self.parentArea = parent
        super.init(viewModel: CRUDListViewModel())
        self.viewModel.isMutliSelect = false
        self.viewModel.filters.value.append(CRUDFilter(field: "parentCode", op: .EQUALS, value: parent.code))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        var items:[UIBarButtonItem] = []
        for viewController in self.navigationController?.viewControllers ?? [] {
            if let vc = viewController as? CRUDAreaViewController {
                let item = UIBarButtonItem(title: vc.parentArea.name, style: .done, target: nil, action: nil)
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
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        
        self.viewModel.items.asObservable().subscribe { (event) in
            self.tableView.reloadData()
        }.disposed(by: bag)
    }
}

extension CRUDAreaViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.choosedItem.onNext(.all)
        }else {
            let item = self.viewModel[indexPath.row]
            self.viewModel.select(indexPath.row)
            self.choosedItem.onNext(.one(item))
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  section == 0 ? 1 : self.viewModel.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        
        if indexPath.section == 0 {
            
            cell.textLabel?.text = "全部"
            cell.accessoryType =  .disclosureIndicator
        }else {
            let item = self.viewModel[indexPath.row]
            cell.textLabel?.text = "\(item.name)"
            
            cell.accessoryType = self.viewModel.isSelected(item) ? .checkmark : .disclosureIndicator
        }
        return cell
    }
}
