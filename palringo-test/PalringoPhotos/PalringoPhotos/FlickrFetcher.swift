//
//  FlickrFetcher.swift
//  PalringoPhotos
//
//  Created by Benjamin Briggs on 14/10/2016.
//  Copyright © 2016 Palringo. All rights reserved.
//

import UIKit

enum Photographers: String {
    case dersascha
    case alfredoliverani
    case photographybytosh

    var displayName: String {
        switch self {
        case .dersascha:
            return "Sascha Gebhardt"
        case .alfredoliverani:
            return "Alfredo Liverani"
        case .photographybytosh:
            return "Martin Tosh"
        }
    }

    var imageURL: URL {
        switch self {
        case .dersascha:
            return URL(string: "http://farm6.staticflickr.com/5489/buddyicons/26383637@N06_r.jpg")!
        case .alfredoliverani:
            return URL(string: "http://farm4.staticflickr.com/3796/buddyicons/41569704@N00_l.jpg")!
        case .photographybytosh:
            return URL(string: "http://farm9.staticflickr.com/8756/buddyicons/125551752@N05_r.jpg")!
        }
    }
}

private let apiKey = "409c210c52dc34ed07fcc512b82e859b"

fileprivate extension Photo {
    init?(dictionary: NSDictionary) {
        guard
        let idString = dictionary.value(forKeyPath:"id") as? String,
        let nameString = dictionary.value(forKeyPath:"title") as? String,
        let originalString =
            dictionary.value(forKeyPath:"url_z") as? String ??
            dictionary.value(forKeyPath:"url_-") as? String,
        let url = URL(string: originalString)
        else {return nil}
        
        self.id = idString
        self.name = nameString
        self.url = url
    }
}

fileprivate extension PhotoComment {
    init?(dictionary: NSDictionary) {
        guard
            let idString = dictionary.value(forKeyPath:"id") as? String,
            let authorString = dictionary.value(forKeyPath:"authorname") as? String,
            let commentString = dictionary.value(forKeyPath:"_content") as? String
            else { return nil }

        self.id = idString
        self.author = authorString
        self.comment = commentString
    }
}

class FlickrFetcher {
    
    func getPhotosUrls(forPhotographer photographer: Photographers, forPage page: Int = 1,
                       completion: @escaping ([Photo])->()) {

        let properties = [
            "&user_id=\(photographer.rawValue)",
            "&page=\(page)",
            "&per_page=20",
            "&extras=url_-,url_z"
        ]

        request(method: "flickr.people.getPhotos",
                properties: properties) { object in
            DispatchQueue.global().async {
                let photos = object.value(forKeyPath: "photos.photo") as? [NSDictionary]
                let returnPhotos = photos?
                    .map({ Photo(dictionary: $0) })
                    .filter({ $0 != nil })
                    as? [Photo] ?? []
                
                DispatchQueue.main.async {
                    completion(returnPhotos)
                }
            }
        }
    }

    func getPhotoComments(for photo: Photo,
                       completion: @escaping ([PhotoComment])->()) {

        let properties = ["&photo_id=\(photo.id)"]

        request(method: "flickr.photos.comments.getList",
                properties: properties) { object in
                    DispatchQueue.global().async {
                        let comments = object.value(forKeyPath: "comments.comment") as? [NSDictionary]
                        let returnComments = comments?
                            .map({ PhotoComment(dictionary: $0) })
                            .filter({ $0 != nil })
                            as? [PhotoComment] ?? []

                        DispatchQueue.main.async {
                            completion(returnComments)
                        }
                    }
        }
    }

    private func request(method: String,
                         properties: [String],
                         completion: @escaping (NSDictionary)->()) {

        let baseURL = "https://api.flickr.com/services/rest/?"
        let methodString = "&method=\(method)"
        let apiString = "&api_key=\(apiKey)"
        let formatString = "&format=json"
        let paramitorString = properties.reduce("", { $0 + $1})
        
        let urlString =
            baseURL +
            methodString +
            apiString +
            formatString +
            paramitorString

        guard let requestURL = URL(string: urlString) else {return}
        
        _ = CachedRequest.request(url: requestURL) { data, isCached in
            if let jsonDictionary = self.processJSON(data: data!) {
                completion(jsonDictionary)
            }
        }
    }
    
    private func processJSON(data: Data) -> NSDictionary? {
        let dataString = String(data: data, encoding: String.Encoding.utf8)
        
        let jsonString = dataString?
            .replacingOccurrences(of: "jsonFlickrApi(", with: "")
            .replacingOccurrences(of: ")", with: "").data(using: .utf8)
        
        do {
            let result = try JSONSerialization.jsonObject(with: jsonString!,
                                                          options: .mutableContainers)
            return result as? NSDictionary
        } catch {print(error)}
        
        return nil
    }
    
    
}
