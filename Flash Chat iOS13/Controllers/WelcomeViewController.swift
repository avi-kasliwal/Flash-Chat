//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = ""
        let logoText = K.appName
        var idx = 0.0
        for char in logoText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * idx, repeats: false) { timer in
                self.titleLabel.text?.append(char)
            }
            idx += 1
        }
    }
}
