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

    //IBOutlet Elements
    @IBOutlet weak var mapView: MKMapView!
    
    //Controller Parameters
    private var coordinates : CLLocationCoordinate2D? //current Coordinates of location, passed on from MyStoreViewController
    private var currShop: Shop?                       //current Shop
    private var currProfile: User?                    //current User
    private var pin: AnnotationPin!                   //Annotation Pin to mark location in the map
    private var locationManager: CLLocationManager!   //Location Manager
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        setMap()
    }
}


//MARK:- General Functions
extension MapViewController {
    
    //Setter function to set up current Shop's location, passed on from previous view controller (MyStoreViewController)
    func setLocation(coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
    }
    
    //Setter function to set up current Shop, passed on from previous view controller (MyStoreViewController)
    func setShop(shop: Shop?) {
        self.currShop = shop
    }
    
    //Setter function to set up the user, passed on from previous view controller (MyStoreViewController)
    func setCurrProfile(user: User) {
        self.currProfile = user
    }
    
    /**/
    /*
    private func setMap

    NAME

            setMap -  Function to focus the shop on Shop/User location.

    DESCRIPTION

            This function zooms into the shop/user location in the map.

    RETURNS

            Void

    AUTHOR

            Rahul Guni

    DATE

            09/07/2021

    */
    /**/
    
    private func setMap() {
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
    /* private func setMap() */
    
    //function to determine current location
    private func determineCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

}

//MARK:- IBOutlet Functions
extension MapViewController {
    
    //Action after exit button click
    @IBAction func exitClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Action after current location button click
    @IBAction func myLocationClicked(_ sender: Any) {
        determineCurrentLocation()
    }
}

//MARK:- CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation: CLLocation = locations[0] as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = "Current Location"
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 100)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(annotation)
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = customNetworkAlert(title: "\(error.localizedDescription)", errorString: "Please check your internet connection and ensure location services are available.")
        self.present(alert, animated: true, completion: nil)
    }

}

//MARK:- MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? AnnotationPin else {
            return nil
        }

        let identifier = "annotation"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //Decode the location
        //Get address for touch coordinates.
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
