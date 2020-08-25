//
//  SelectPhotographerViewController.swift
//  PalringoPhotos
//
//  Created by Bobby Dev on 25/08/2020.
//  Copyright © 2020 Palringo. All rights reserved.
//

import Foundation
import UIKit

final class SelectPhotographerViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PhotoCollectionViewController, let selectedPhotographer = sender as? Photographers {
            destination.selectedPhotographer = selectedPhotographer
        }
    }
    
    private func getPhotographer(index: Int) -> Photographers? {
        switch index {
        case 0:
            return Photographers.dersascha
        case 1:
            return Photographers.alfredoliverani
        case 2:
            return Photographers.photographybytosh
        default:
            return nil
        }
    }
}

extension SelectPhotographerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedPhotographer = getPhotographer(index: indexPath.row) {
            performSegue(withIdentifier: "showPhotographerSegue", sender: selectedPhotographer)
        }
    }
}

extension SelectPhotographerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell: UITableViewCell = UITableViewCell()
        tableCell.accessoryType = .disclosureIndicator
        
        if let selectedPhotographer: Photographers = getPhotographer(index: indexPath.row) {
            tableCell.textLabel?.text = selectedPhotographer.displayName
        }
        
        return tableCell
    }
}
