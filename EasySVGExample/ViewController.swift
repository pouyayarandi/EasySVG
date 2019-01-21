//
//  ViewController.swift
//  EasySVGExample
//
//  Created by Pouya on 1/21/19.
//  Copyright © 2019 pouya yarandi. All rights reserved.
//

import UIKit
import EasySVG

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView1.setSVG("female")
        
        imageView2.setSVG("crown", withColor: .red)
        
        if let url = Bundle.main.url(forResource: "like", withExtension: "svg") {
            imageView3.setSVG(url)
        }
    }
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
}

class ChooseColorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func setColor(_ sender: UIButton) {
        imageView.setColorOfSVG(sender.backgroundColor)
    }
    
}

