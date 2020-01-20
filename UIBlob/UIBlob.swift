//
//  UIBlob.swift
//  UIBlob
//
//  Created by Daniel Eke on 20/01/2020.
//  Copyright © 2020 Daniel Eke. All rights reserved.
//

import UIKit

class UIBlob: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = .red
    }
    
}
