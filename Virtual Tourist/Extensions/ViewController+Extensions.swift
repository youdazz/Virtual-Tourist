//
//  ViewController+Extensions.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import UIKit
extension UIViewController {
    func showAlertController(title: String, message: String, actions: [UIAlertAction]) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertVC.addAction(action)
        }
        self.present(alertVC, animated: true)
    }
}
