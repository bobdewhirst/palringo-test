//
//  PhotoCell.swift
//  PalringoPhotos
//
//  Created by Benjamin Briggs on 14/10/2016.
//  Copyright © 2016 Palringo. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    private var fetchTask: URLSessionTask? {
        willSet {
            fetchTask?.cancel()
        }
    }

    var photo: Photo? {
        didSet {
            nameLabel?.text = photo?.name ?? ""

            if let photo = photo {

                self.fetchTask = CachedRequest.request(url: photo.url) { data, isCached in
                        guard data != nil else { return }
                    let img = UIImage(data: data!)
                    if isCached {
                        self.imageView?.image = img
                    } else if self.photo == photo {
                        DispatchQueue.main.async {
                            UIView.transition(with: self, duration: 1, options: .transitionCrossDissolve, animations: {
                                self.imageView?.image = img
                            }, completion: nil)
                        }
                    }
                }
            }

        }
    }

    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?

    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel?.text = nil
        self.imageView?.image = nil
    }
}
