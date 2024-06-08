//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var selectedPin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
        
        setupFetchedResultsController()
        updateMapPins()
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let pin = saveNewPin(coordinate)
            // Crea un nuevo pin y agrega la coordenada al mapa
            let annotation = pin
            mapView.addAnnotation(annotation)
        }
    }
    
    func saveNewPin(_ coordinate: CLLocationCoordinate2D) -> Pin{
        let pin = Pin(context: DataController.shared.viewContext)
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        try? DataController.shared.viewContext.save()
        return pin
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = .init(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "pin")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError()
        }
    }
    
    deinit {
        fetchedResultsController = nil
    }
    
    func updateMapPins() {
        let pins = fetchedResultsController.fetchedObjects ?? []
        for pin in pins {
            addNewAnnotation(pin)
        }
    }
    
    func addNewAnnotation(_ pin: Pin) {
        let annotation = pin
        mapView.addAnnotation(annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navigateToAlbum" {
            guard let destination = segue.destination as? PhotoAlbumCollectionViewController else { return }
            destination.pin = selectedPin!
        }
    }
}

extension TravelLocationsViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Pin else {
            return nil
        }
        
        let identifier = "Pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
        guard let annotation = annotation as? Pin else { return }
        selectedPin = annotation
        performSegue(withIdentifier: "navigateToAlbum", sender: nil)
    }
}

extension TravelLocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert, let travelLocation = anObject as? Pin{
            addNewAnnotation(travelLocation)
        }
    }
}

