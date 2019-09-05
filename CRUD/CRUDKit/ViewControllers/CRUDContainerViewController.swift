//
//  CRUDContainerViewController.swift
//  Installer
//
//  Created by hong tianjun on 2019/4/11.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaLumberjack

public protocol CRUDContainerContentViewControllerType {
    
    var searchItems: [String] { get }
    
    var conditionItems: [CRUDOptions] { get }
    
    func conditionChange(_ search: CRUDSearch?, filters: [CRUDBaseFilter], sorts: [CRUDSort])
    
    func searchConditionChange(_ search: CRUDSearch?)
    
    func filterConditionChange(_ filters: [CRUDBaseFilter])
    
    func sortsConditionChange(_ sorts: [CRUDSort])
    
    var contentView: UIView { get }
    
    var contentScrollView: UIScrollView? { get }
}

public class ChooseButton: UIButton {
    override init(frame: CGRect) {
        super .init(frame: frame)
        setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpUI()
    }
    
    func setUpUI() {
        setImage(UIImage.init(named: "onTrange"), for: .normal)
        setImage(UIImage.init(named: "offTrange"), for: .selected)
        adjustsImageWhenHighlighted = false
        sizeToFit()
    }
    
    override public func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle((title ?? "") + " ", for: state)
        titleLabel?.textAlignment = NSTextAlignment.center
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if (titleLabel?.frame.width)! > self.frame.width {
            titleLabel?.frame.origin.x = 0
            imageView?.frame.origin.x = titleLabel!.frame.width +  (titleLabel?.frame.origin.x)!
        }
        else {
            titleLabel?.frame.origin.x =   (self.bounds.width - (titleLabel?.frame.width)! - (imageView?.frame.width)!)/2.0
            imageView?.frame.origin.x = titleLabel!.frame.width + (titleLabel?.frame.origin.x)!
        }
    }
}


public typealias CRUDContainerContentViewController = CRUDContainerContentViewControllerType & UIViewController



class CRUDPromptView: UIView {
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.tintColor
        label.font  = UIFont.systemFont(ofSize: 12.0)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        imageView.snp.makeConstraints { (maker) in
            maker.centerY.equalToSuperview()
            maker.left.equalToSuperview().offset(15)
            maker.top.equalToSuperview().offset(8)
            maker.bottom.equalToSuperview().offset(-8)
            maker.width.equalTo(24.0)
        }
        
        titleLabel.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(12)
            maker.bottom.equalToSuperview().offset(-12)
            maker.left.equalTo(imageView.snp_rightMargin).offset(10)
            maker.right.equalToSuperview().offset(-10)
        }
        super.updateConstraints()
    }
}

open class CRUDContainerController: PGViewController<PGViewModel> {
    
    public enum Status {
        case noShow
        case show(color: UIColor, image: UIImage, message: String)
    }
    
    public var contentViewController: CRUDContainerContentViewController
    
    var headerHeight = 0.0
    // 是子viewController滚动时是否隐藏导航栏
    public var isHideNavigationBarScroll: Bool = false
    // 当前打开的条件viewController 的index
    var currentIndex = Int.max
    // 当前打开的条件viewcontroller
    var currentConditionViewController: CRUDOptionsContainerViewController?
    
    private var exFilters: [String:[CRUDBaseFilter]] = [String:[CRUDBaseFilter]]()
    private var filters: [Int:[CRUDBaseFilter]] = [Int:[CRUDBaseFilter]]()
    private var sorts: [CRUDSort] = [CRUDSort]()
    
    // 输入当前状态提示
    public let promptVariable: Variable<Status> = Variable<Status>(.noShow)
    
    var chooseBtnItems: [ChooseButton] = []
    
    lazy var searchBar:UISearchBar = {
        let bar = UISearchBar()
        
        if let subView = bar.subviews.first{
            if let view = subView.subviews.first,let imgView = view as? UIImageView{
                imgView.alpha = 0.0
                bar.backgroundColor = UIColor.init(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
            }
        }
        
        bar.searchBarStyle = .default
        
        if let field = bar.value(forKey: "searchField") as? UITextField {
            field.backgroundColor = UIColor.white
            field.clipsToBounds = true
            field.layer.cornerRadius = 2
            field.frame = CGRect.init(x: 15, y: 10, width: bar.bounds.size.width - 30, height: 32)
            field.enablesReturnKeyAutomatically = false
        }
        bar.placeholder = "搜索"
        return bar
    }()
    
    lazy var promptBar: CRUDPromptView = {
        let view = CRUDPromptView()
        
        return view
    }()
    
    public var searchCondition: CRUDSearch? {
        get {
            guard let t = self.searchBar.text else { return nil }
            guard self.contentViewController.searchItems.count > 0 else { return nil }
            return CRUDSearch(t, fields: self.contentViewController.searchItems)
        }
        set {
            self.searchBar.text = newValue?.key
            self.contentViewController.searchConditionChange(newValue)
        }
    }
    
    public init(contentViewController: CRUDContainerContentViewController)  {
        self.contentViewController = contentViewController
        
        super.init(viewModel: PGViewModel())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.setupSearch()
        self.setupPrompt()
        self.setupCondition()
        // 设置内容界面
        self.setupContentViewController()
        
        if let scrollView = self.contentViewController.contentScrollView {
            
            scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.new,.old], context: nil)
        }
        
        self.promptVariable.asObservable().observeOn(MainScheduler.instance).skip(1).subscribe { [weak self](event) in
            if case .next(let st) = event {
                self?.updatePromptBar(st)
            }
        }.disposed(by: bag)
    }
    
    deinit {
        if let scrollView = self.contentViewController.contentScrollView {
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
    }
    
    @objc func menu(button: UIButton) {
       
        for btn in  self.chooseBtnItems {
            btn.isSelected = false
        }
        button.isSelected = true
        
        // 如果是点击已打开的条件viewController,不要动了，
        //        guard currentIndex != button.tag else { return }
        
        searchBar.resignFirstResponder()
        // 如果是点击已打开的条件viewController,不要动了，
        //        guard currentIndex != button.tag else { return }
        
        // 如果有其它已打开发viewController，先移除
        if currentConditionViewController != nil {
            currentConditionViewController?.removeFromParentController()
            currentConditionViewController = nil
            currentIndex = Int.max
            
        }
        
        let item = self.contentViewController.conditionItems[button.tag]
        guard let viewController = item.conditionViewController() else { return }
        currentConditionViewController = CRUDOptionsContainerViewController(viewController)
        
        
        currentConditionViewController?.addToParentController(self)
        currentConditionViewController?.view.snp.makeConstraints({ (maker) in
            maker.edges.equalTo(contentViewController.view)
        })
    }
    
    public func switchContent(viewController: CRUDContainerContentViewController) {
    
        contentViewController.removeFromParentController()
        self.contentViewController = viewController
        setupContentViewController()
        self.generateSorts()
        self.generateFilters()
    }
    
    
    public func setCustomFilter(_ key: String, fst: [CRUDBaseFilter]? = nil) {
        if fst == nil && (exFilters.index(forKey: key) != nil) {
            exFilters.removeValue(forKey: key)
        }
        guard let fs = fst  else { return }
        
        exFilters[key] = fs
    }
    
    public func generateFilters(fst: [CRUDBaseFilter]? = nil) {
        var fs: [CRUDBaseFilter] = []
        for (_, filters) in filters {
            fs.append(contentsOf: filters)
        }
        
        // 增加用户自定义filters,去重判断，如果自定义接口条件与实际条件重复，去除
        for (_, filters) in exFilters {
            
            let tempFs = fs

            for filter in filters {
                var isExties = false
                for fil in tempFs {
                    if fil.field == filter.field {
                        //相同
                        isExties = true
                    }
                }
                if !isExties{
                    fs.append(filter)
                }
            }
        }
        
        if let fts = fst { fs.append(contentsOf: fts) }
        
        self.contentViewController.filterConditionChange(fs)
        
        // 如果条件被触发就清理
        if currentConditionViewController != nil {
            currentConditionViewController?.removeFromParentController()
            currentConditionViewController = nil
            currentIndex = Int.max
        }
    }
    
    public func generateSorts(fst: [CRUDSort]? = nil) {
        var fs: [CRUDSort] = []
        for sort in sorts {
            fs.append(sort)
        }
        
        if let fts = fst { fs.append(contentsOf: fts) }
        
        self.contentViewController.sortsConditionChange(fs)
        
        // 如果条件被触发就清理
        if currentConditionViewController != nil {
            currentConditionViewController?.removeFromParentController()
            currentConditionViewController = nil
            currentIndex = Int.max
        }
    }
    
    lazy var searchController: UISearchController  = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = UIColor.red
        return searchController
    }()

    
    func setupSearch() {
        
//        guard  else {
//            return
//        }

        _ = self.searchBar.rx.cancelButtonClicked.subscribe {[weak self] (event) in
            self?.searchBar.text = nil
            self?.searchBar.resignFirstResponder()
            self?.contentViewController.searchConditionChange(nil)
            }.disposed(by: bag)
        _ = self.searchBar.rx.searchButtonClicked.subscribe { [weak self](event) in
            switch event {
            case .next():
               self?.searchBar.resignFirstResponder()
               self?.contentViewController.searchConditionChange(self?.searchCondition)
            default: break
            }
            }.disposed(by: bag)
        self.view.addSubview(self.searchBar)
        self.searchBar.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.left.right.equalToSuperview()
            
            if self.contentViewController.searchItems.count > 0 {
                maker.height.equalTo(52.0)
            }else {
                maker.height.equalTo(0.0)
            }
        }
        
//        headerHeight += 52.0
    }
    
    func setupPrompt() {
        
        self.promptBar.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        self.view.addSubview(self.promptBar)
        self.promptBar.snp.makeConstraints { (maker) in
            maker.top.equalTo(searchBar.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.height.equalTo(0)
        }
    }
    
    var conditionView: UIView?
    
    func setupCondition() {
        if self.contentViewController.conditionItems.count == 0 { return }
        
        chooseBtnItems.removeAll()
        for index in 0..<self.contentViewController.conditionItems.count {
            let item = self.contentViewController.conditionItems[index]
            let btn = ChooseButton()
            btn.setTitle(item.title, for: .normal)
            btn.setTitleColor(UIColor.init(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1), for: .normal)
            btn.setTitleColor(UIColor.init(red: 10/255.0, green: 63/255.0, blue: 136/255.0, alpha: 1), for: .selected)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.addTarget(self, action: #selector(menu), for: .touchUpInside)
            btn.tag = index
            chooseBtnItems.append(btn)
            
            _ = item.finished.asObservable().takeUntil(self.rx.deallocated).subscribe {[weak self] (event) in
                switch event {
                case .next(let it):
                    btn.isSelected = false
                    if let filters = it as? [CRUDBaseFilter] {
                        self?.filters[index] = filters
                        self?.generateFilters()
                        DDLogDebug("filters: \(filters)")
                    }else if let sorts = it as? [CRUDSort] {
                        self?.sorts = sorts
                        self?.generateSorts()
                        DDLogDebug("sorts: \(sorts)")
                    }
                default:
                    btn.isSelected = false
                    break;
                }
            }
        }
        let stackView = UIStackView(arrangedSubviews: self.chooseBtnItems)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { (maker) in
//            if (self.contentViewController.searchItems.count > 0) {
//                maker.top.equalTo(searchBar.snp.bottom)
//            }else {
//                maker.top.equalTo(topLayoutGuide.snp.bottom).offset(headerHeight)
//            }
            maker.top.equalTo(self.promptBar.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.height.equalTo(44)
        }
        
        self.conditionView = stackView
        
        let view = PGSeparatorView()
        view.height = 0.5
        view.backgroundColor = UIColor.lightGray
        self.view.addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(stackView)
        }
//        headerHeight += 44.0
    }
    
    func setupContentViewController() {

        contentViewController.addToParentController(self)
        contentViewController.view.snp.makeConstraints({ (maker) in
            if let view = self.conditionView {
                maker.top.equalTo(view.snp.bottom)
//            }else if self.contentViewController.searchItems.count > 0 {
//                maker.top.equalTo(searchBar.snp.bottom)
            }else {
                maker.top.equalTo(topLayoutGuide.snp.bottom)
            }
            maker.left.right.bottom.equalToSuperview()
        })
    }
    
    
    func updatePromptBar(_ status: Status) {
    
        if case .show(let color, let image, let message) = status {
            self.promptBar.backgroundColor = color.withAlphaComponent(0.1)
            self.promptBar.titleLabel.textColor = color
            self.promptBar.titleLabel.text = message
            self.promptBar.imageView.image = image
        }

        
        self.promptBar.snp.remakeConstraints { (maker) in
            maker.top.equalTo(searchBar.snp.bottom)
            maker.left.right.equalToSuperview()
            if case .noShow = status {
                maker.height.equalTo(0)
            }else {
                maker.height.equalTo(44)
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(UIScrollView.contentOffset),
            let newValue = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
            if newValue.y > 0.0 {
                
                if searchBar.isHidden == false {
                    self.searchBar.isHidden = true
                    searchBar.snp.remakeConstraints { (maker) in
                        maker.top.equalToSuperview()
                        maker.left.right.equalToSuperview()
                        maker.height.equalTo(0.0)
                    }
                }
                if isHideNavigationBarScroll, self.navigationController?.isNavigationBarHidden == false {
                    self.navigationController?.setNavigationBarHidden(true, animated: true)
                }
            }
            
            if newValue.y < 0.0 {
                
                if searchBar.isHidden == true {
                    self.searchBar.isHidden = false
                    searchBar.snp.remakeConstraints { (maker) in
                        maker.top.equalToSuperview()
                        maker.left.right.equalToSuperview()
                        maker.height.equalTo(52.0)
                    }
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                }
                if isHideNavigationBarScroll, self.navigationController?.isNavigationBarHidden ?? true {
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                }
            }
            
        }
    }
}
