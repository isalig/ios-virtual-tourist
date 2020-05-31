//
//  ApiClient.swift
//  virtual-tourist
//
//  Created by Ischuk Alexander on 01.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation

class ApiClient {
    
    let dataController: DataController!
    
    init(dataController: DataController) {
        self.dataController = dataController
    }
    
    enum ApiEndpoint {
        static let baseUrl = "https://api.flickr.com/services/rest/?"
        static let apiKey = "7344c51b882809d943e3a633518bb25b"
        
        case list(latitude: Double, longitude: Double, page: Int)
        case detail(farmId: String, serverId:String, photoId: String, secret: String)
    }
    
    enum ApiError: Error {
        case networkError
        case decodingError
    }
    
    func getUrl(for endpoint: ApiEndpoint) -> String {
        switch endpoint {
        case .list(let latitude, let longitude, let page):
            return "\(ApiEndpoint.baseUrl)method=flickr.photos.search&api_key=\(ApiEndpoint.apiKey)&format=json&privacy_filter=1&lat=\(latitude)&lon=\(longitude)&nojsoncallback=1&per_page=50&page=\(page)"
        case .detail(let farmId, let serverId, let photoId, let secret):
            return "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secret)_s.jpg"
        }
    }
    
    func loadList(latitude: Double, longitude: Double, page: Int, result: @escaping (PhotosWithPagesCount?, ApiError?) -> Void) {
        makeGETRequest(endpoint: .list(latitude: latitude, longitude: longitude, page: page)) {
            (photosResponse: PhotosResponse?, error) in
            guard error == nil else {result(nil, error); return}
            let items = photosResponse!.photos.photo.map { (photoResponse) -> Photo in
                let photo = Photo(context: self.dataController.viewContext)
                photo.id = photoResponse.id
                photo.farmId = "\(photoResponse.farm)"
                photo.serverId = photoResponse.server
                photo.secret = photoResponse.secret
                return photo
            }
            try? self.dataController.viewContext.save()
            
            let photosWithPagesCount = PhotosWithPagesCount(pages: photosResponse!.photos.pages, photos: items)
            
            result(photosWithPagesCount, nil)
        }
    }
    
    func loadPhoto(photo: Photo, result: @escaping (Data?, ApiError?) -> Void) {
        
        let request = URLRequest(url: URL(string: getUrl(for: .detail(farmId: photo.farmId!, serverId: photo.serverId!, photoId: photo.id!, secret: photo.secret!)))!)
        URLSession.shared.dataTask(with: request) {data, response, error in
            if error != nil {
                result(nil, .networkError)
                return
            }
            result(data, nil)
        }.resume()
        
    }
    
    func makeGETRequest<ResponseType: Decodable>(endpoint: ApiEndpoint, result: @escaping (ResponseType?, ApiError?) -> Void) {
        let request = URLRequest(url: URL(string: getUrl(for: endpoint))!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                result(nil, .networkError)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard data != nil else {
                result(nil, .networkError)
                return
            }
            
            guard let decoded = try? decoder.decode(ResponseType.self, from: data!) else {
                result(nil, .decodingError)
                return
            }
            result(decoded, nil)
        }
        task.resume()
    }
}
