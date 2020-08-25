//
//  CachedRequest.swift
//  PalringoPhotos
//
//  Created by Benjamin Briggs on 14/10/2016.
//  Copyright © 2016 Palringo. All rights reserved.
//

import Foundation

class CachedRequest {

    static let cache = URLCache(memoryCapacity: 40 * 1024 * 1024,
                                diskCapacity: 512 * 1024 * 1024,
                                diskPath: "urlCache")

   static func request(url: URL, completion: @escaping (Data?, Bool)->() ) -> URLSessionTask? {
        let request = URLRequest(url: url,
                                 cachePolicy: .returnCacheDataElseLoad,
                                 timeoutInterval: 100)

        if let cacheResponse = cache.cachedResponse(for: request) {
            completion(cacheResponse.data, true)
            return nil
        } else {
            let config = URLSessionConfiguration.default

            config.urlCache = cache
            
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request,
                                        completionHandler: { data, response, error in
                
                if let response = response, let data = data {
                    let cacheResponse = CachedURLResponse(response: response,
                                                          data: data)
                    URLCache.shared.storeCachedResponse(cacheResponse,
                                                        for: request)
                }
                
                completion(data, false)
            })
            task.resume()
            return task
        }
    }
}
