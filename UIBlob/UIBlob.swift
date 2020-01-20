//
//  UIBlob.swift
//  UIBlob
//
//  Created by Daniel Eke on 20/01/2020.
//  Copyright © 2020 Daniel Eke. All rights reserved.
//

import UIKit

open class UIBlob: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public func commonInit() {
        self.backgroundColor = .red
    }
    
}
