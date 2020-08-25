//
//  PhotoCollectionViewController.swift
//  PalringoPhotos
//
//  Created by Benjamin Briggs on 14/10/2016.
//  Copyright © 2016 Palringo. All rights reserved.
//

import UIKit

class PhotoCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "PhotoCell"
    private var photos: [[Photo]] = []
    private var isFetchingPhotos = false
    private var photographerImageView: UIImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
    var selectedPhotographer: Photographers?
    
    @IBOutlet private var loadingView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = selectedPhotographer?.displayName
        addPhotographerImage()
        fetchNextPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        photographerImageView.removeFromSuperview()
    }
    
    private func addPhotographerImage() {
        if let navigationController = navigationController, let selectedPhotographer = selectedPhotographer {
            let imageURL: URL = selectedPhotographer.imageURL
            if let data = try? Data(contentsOf: imageURL) {
                photographerImageView.image = UIImage(data: data)
            }
            navigationController.navigationBar.addSubview(photographerImageView)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CommentsViewController, let selectedPhoto = sender as? Photo {
            destination.photo = selectedPhoto
        }
    }
       
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.collectionView?.collectionViewLayout.invalidateLayout()
        }, completion: nil)
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func photo(forIndexPath indexPath: IndexPath) -> Photo {
        if indexPath.section == photos.count - 1 { fetchNextPage() }
        return self.photos[indexPath.section][indexPath.item]
    }
    
    func loadingCenter() -> CGPoint {
        let y: CGFloat
        if (photos.count > 0) {
            y = (self.collectionView?.bounds.maxY ?? 0) - 60
        } else {
            y = (self.collectionView?.bounds.midY ?? 0)
        }

        return CGPoint(
            x: (self.collectionView?.bounds.midX ?? 0),
            y: y
        )
    }
    
    private func fetchNextPage() {
        
        guard let selectedPhotographer = selectedPhotographer else {
            return
        }
        
        if isFetchingPhotos { return }
        isFetchingPhotos = true
        
        if let loadingView = loadingView, let collectionView = collectionView?.superview {
            collectionView.addSubview(loadingView)
            loadingView.layer.cornerRadius = 5
            loadingView.sizeToFit()
            loadingView.center = loadingCenter()
        }
        
        let currentPage = photos.count
        FlickrFetcher().getPhotosUrls(forPhotographer: selectedPhotographer, forPage: currentPage+1) { [weak self] in
            if $0.count > 0 {
                self?.photos.append($0)
                self?.collectionView?.insertSections(IndexSet(integer: currentPage))
                self?.isFetchingPhotos = false
            }
        
            self?.loadingView?.removeFromSuperview()
        }
    }


    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 200)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell

        let photo = self.photo(forIndexPath: indexPath)
        cell.photo = photo

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPhoto: Photo = photo(forIndexPath: indexPath)
        performSegue(withIdentifier: CommentsViewController.commentsViewControllerSegue, sender: selectedPhoto)
    }
}
