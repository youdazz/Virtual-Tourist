//
//  Photo+Extensions.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import Foundation

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
