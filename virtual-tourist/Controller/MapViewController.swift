//
//  MapViewController.swift
//  virtual-tourist
//
//  Created by Ischuk Alexander on 01.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pins = [Pin]()
    var pinSelected: Pin?
    
    var dataController: DataController {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.dataController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! PhotosViewController
        controller.pin = pinSelected
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPins()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        gestureRecognizer.minimumPressDuration = 2.0
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func loadPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if (result.count > 0) {
                
                pins = result
                
                var annotations = [MKPointAnnotation]()
                for pin in result {
                    let lat = CLLocationDegrees(pin.latitude)
                    let long = CLLocationDegrees(pin.longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    annotation.title = pin.id
                    annotations.append(annotation)
                }
                
                DispatchQueue.main.async {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.addAnnotations(annotations)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.tintColor = .green
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        pinSelected = pins.first(where: { (pin) -> Bool in
            pin.id == view.annotation?.title
        })
        performSegue(withIdentifier: "showAlbum", sender: self)
    }
    
    @objc func longPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint: CGPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let pin = Pin(context: dataController.viewContext)
        pin.id = "\(touchMapCoord.latitude)_\(touchMapCoord.longitude)" //
        pin.latitude = touchMapCoord.latitude
        pin.longitude = touchMapCoord.longitude
        try? dataController.viewContext.save()
        
        pins.append(pin)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoord
        annotation.title = pin.id
        mapView.addAnnotation(annotation)
    }
}
