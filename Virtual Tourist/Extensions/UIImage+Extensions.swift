//
//  UIImage+Extensions.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import UIKit
extension UIImage {
    
    func resizeImage(newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resizedImage
    }
}
