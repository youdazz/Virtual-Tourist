//
//  PhotoAlbumCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import UIKit
import CoreData

private let reuseIdentifier = "PhotoCell"

class PhotoAlbumCollectionViewController: UICollectionViewController {

    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var photoInfos: [PhotoInfo] = []
    var isSingleDelete = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        let count = pin.photos?.allObjects.count ?? 0
        if count <= 0 {
            fetchNewPhotos()
        }
    }
    
    func fetchNewPhotos() {
        FlickrClient.searchPhoto(completion: handleSearchPhotoResponse(photos:error:))
    }
    
    func handleSearchPhotoResponse(photos: [PhotoInfo], error: Error?) {
        guard error == nil else {
            showAlertController(title: "Error", message: error!.localizedDescription, actions: [
                .init(title: "Ok", style: .default)
            ])
            return
        }
        deletePhotos()
        saveNewPhotos(photos)
    }
    
    func deletePhotos() {
        if let photos = pin.photos?.allObjects as? [Photo] {
            for photo in photos {
                pin.removeFromPhotos(photo)
                DataController.shared.viewContext.delete(photo)
            }
        }
        do {
            try DataController.shared.viewContext.save()
        } catch {
            print("Error al guardar los cambios en CoreData: \(error.localizedDescription)")
        }
        collectionView.reloadData()
    }
    
    func saveNewPhotos(_ photos: [PhotoInfo]) {
        for photo in photos {
            let newPhoto = Photo(context: DataController.shared.viewContext)
            newPhoto.pin = pin
            newPhoto.flickerId = photo.id
            newPhoto.farm = Int16(photo.farm)
            newPhoto.server = photo.server
            newPhoto.secret = photo.secret
        }
        try? DataController.shared.viewContext.save()
        collectionView.reloadData()
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "flickerId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = .init(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError()
        }
    }
    
    func deletePhoto(photo: Photo) {
        isSingleDelete = true
        DataController.shared.viewContext.delete(photo)
        try? DataController.shared.viewContext.save()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        if let data = photo.data {
            cell.imageView.image = UIImage(data: data)
        } else {
            FlickrClient.downloadImage(photo: photo) { image, error in
                cell.imageView.image = image
                if let error = error {
                    self.showAlertController(title: "Error", message: error.localizedDescription, actions: [
                        .init(title: "OK", style: .default)
                    ])
                }
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        deletePhoto(photo: photo)
    }

    @IBAction func reloadPhotos(_ barButton: UIBarButtonItem) {
        fetchNewPhotos()
    }
}

extension PhotoAlbumCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .delete && isSingleDelete, let indexPath = indexPath {
            isSingleDelete = false
            self.collectionView.deleteItems(at: [indexPath])
        }
        
    }
}
