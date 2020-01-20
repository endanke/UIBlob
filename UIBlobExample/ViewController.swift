//
//  ViewController.swift
//  UIBlob
//
//  Created by Daniel Eke on 20/01/2020.
//  Copyright © 2020 Daniel Eke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var blob: UIBlob!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func blobTapped(_ sender: Any) {
        blob.shake()
    }
    
}

