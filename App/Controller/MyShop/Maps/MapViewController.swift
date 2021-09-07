//
//  MapViewController.swift
//  App
//
//  Created by Rahul Guni on 9/7/21.
//

import UIKit
import MapKit
import Parse

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private var coordinates : CLLocationCoordinate2D?
    private var currShop: Shop?
    private var currProfile: User?
    private var pin: AnnotationPin!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        setMap()
    }
    
    @IBAction func exitClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


//MARK:- Regular Functions
extension MapViewController {
    func setLocation(coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
    }
    
    func setShop(shop: Shop?) {
        self.currShop = shop
    }
    
    func setCurrProfile(user: User) {
        self.currProfile = user
    }
    
    func setMap() {
        let region = MKCoordinateRegion(center: self.coordinates!, latitudinalMeters: 1000, longitudinalMeters: 1000)
        if let currShop = currShop {
            pin = AnnotationPin(title: currShop.getShopTitle(), coordinates: self.coordinates!)
        }
        else if let currProfile = currProfile {
            pin = AnnotationPin(title: currProfile.getName(), coordinates: self.coordinates!)
        }
        
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(pin)
    }
}

//MARK:- MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        guard let annotation = annotation as? AnnotationPin else {
            return nil
        }
        // 3
        let identifier = "artwork"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //Decode the location
        // Add below code to get address for touch coordinates.
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: self.coordinates!.latitude, longitude: self.coordinates!.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler:{placemarks, error -> Void in
                                            guard let placeMark = placemarks?.first else {return }
            
            var title: String?
            if let currShop = self.currShop {
                title = currShop.getShopTitle()
            }
            else {
                title = self.currProfile!.getName()
            }
            let location = placeMark.name! + ", " + placeMark.locality! + ", " + placeMark.administrativeArea! + ", " + placeMark.postalCode!
            
            let alert = customNetworkAlert(title: title!, errorString: location)
            self.present(alert, animated: true, completion: nil)
        })
    }
}

//MARK:- AnnotationPin
class AnnotationPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(title: String, coordinates: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinates
    }
    
}
