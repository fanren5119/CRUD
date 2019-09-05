//
//  CRUDTableViewCell.swift
//  CRUDExample
//
//  Created by hong tianjun on 2019/1/20.
//  Copyright © 2019 hong tianjun. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    public class var identifier: String {
        let name = class_getName(self)
        return String(cString: name)
    }
}


extension UICollectionViewCell {
    
    public class var identifier: String {
        let name = class_getName(self)
        return String(cString: name)
    }
}

open class PGTableViewCell: UITableViewCell {

    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
