//
//  ImageCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: "placeholder")
    }
    
}
