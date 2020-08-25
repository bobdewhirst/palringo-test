//
//  CommentsViewController.swift
//  PalringoPhotos
//
//  Created by Bobby Dev on 25/08/2020.
//  Copyright © 2020 Palringo. All rights reserved.
//

import Foundation
import UIKit

final class CommentsViewController: UIViewController {
    
    static let commentsViewControllerSegue: String = "showCommentsSegue"
    var photo: Photo?
    private var flickrFetcher: FlickrFetcher = FlickrFetcher()
    private var fetchTask: URLSessionTask? {
        willSet {
            fetchTask?.cancel()
        }
    }
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak var commentsDisplay: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let photo = photo {
            title = photo.name
            
            fetchTask = CachedRequest.request(url: photo.url) { [weak self] data, isCached in
                guard data != nil else { return }
                let img = UIImage(data: data!)
                if isCached {
                    self?.imageView.image = img
                } else if self?.photo == photo {
                    self?.imageView.image = img
                }
            }
            
            flickrFetcher.getPhotoComments(for: photo) { [weak self] (comments: [PhotoComment]) in
                self?.display(comments: comments)
            }
        }
    }
    
    private func display(comments: [PhotoComment]) {
        var text: String = ""
        for comment in comments {
            text.append("\(comment.author) - \(comment.comment)\n\n")
        }
        commentsDisplay.text = text
    }
}
