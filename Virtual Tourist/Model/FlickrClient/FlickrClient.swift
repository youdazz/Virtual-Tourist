//
//  FlikrClient.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import UIKit

class FlickrClient{
    
    struct Auth {
        static let apiKey = "9a9ca8bee7a34208797a30e4b3fc2ce9"
    }
    
    enum Endpoints {
        case searchPhotos
        case downloadImage(Photo)
        
        var stringValue: String {
            switch self {
            case .searchPhotos: return "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(Auth.apiKey)&page=\(Int.random(in: 0..<10))&format=json&nojsoncallback=1"
            case .downloadImage(let photo):
                return "https://farm\(photo.farm).staticflickr.com/\(photo.server ?? "")/\(photo.flickerId ?? "")_\(photo.secret ?? "").jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask{
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func searchPhoto(completion: @escaping ([PhotoInfo], Error?) -> Void) {
        let url = Endpoints.searchPhotos.url
        taskForGETRequest(url: url, responseType: SearchPhotoResponse.self) { result, error in
            if let result = result {
                completion(result.photos.photo, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func downloadImage(photo: Photo, completion: @escaping (UIImage?, Error?) -> Void) {
        let url = Endpoints.downloadImage(photo).url
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(image, nil)
            }
        }
        task.resume()
    }


}
