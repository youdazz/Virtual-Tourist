//
//  Pin+Extensions.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import Foundation
import CoreData
import MapKit

extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}
