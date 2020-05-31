//
//  PhotosResponse.swift
//  virtual-tourist
//
//  Created by Ischuk Alexander on 01.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    let photos: PhotoNode
}

struct PhotoNode: Codable {
    let photo: [PhotoResponse]
    let pages: Int
}

struct PhotoResponse: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
}

struct PhotosWithPagesCount {
    let pages: Int
    let photos: [Photo]
}
