//
//  ECSPExceptionView.swift
//  RealmTest
//
//  Created by XUEYING FANG on 2019/2/12.
//  Copyright © 2019 XUEYING FANG. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ECSPExceptionView: UIView {
    
    var _tittle: String?
    var _subtitle: String?
    var _image: UIImage?
    let bag = DisposeBag()
    
    var tittle: String?{
        set{
            _tittle = newValue
            self.titleLabel.text = _tittle
        }
        get{
            return _tittle
        }
    }
    
    var subtitle: String?{
        set{
            _subtitle = newValue
            self.subTitleLabel.text = _subtitle
        }
        get{
            return _subtitle
        }
    }
    
    var image: UIImage?{
        set{
            _image = newValue
            self.imageView.image = _image
        }
        get{
            return _image
        }
    }
    
    lazy var titleLabel:UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.gray
        return label
    }()
    
    lazy var subTitleLabel:UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        label.textColor = UIColor.gray
        return label
    }()
    
    lazy var imageView:UIImageView = {
        var imageView = UIImageView()
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(red: 238.0/255, green: 238.0/255, blue: 242.0/255, alpha: 1);
        self.addSubview(imageView);
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(124)
        }
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(15)
        }
        
        self.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
