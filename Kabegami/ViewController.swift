//
//  ViewController.swift
//  Kabegami
//
//  Created by Victor Gama on 29/11/21.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func buttonDidClick(_ sender: Any) {
        let g = Generator()
        imageView.image = g.makeImage()
    }
    
}

