//
//  SearchPhotoResponse.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import Foundation
struct SearchPhotoResponse: Codable {
    let photos: ResultPage
}

struct ResultPage: Codable{
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoInfo]
}

struct PhotoInfo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }

}
