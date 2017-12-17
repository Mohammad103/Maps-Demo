//
//  MapsViewController.swift
//  Maps Demo
//
//  Created by Mohammad Shaker on 12/17/17.
//  Copyright © 2017 Mohammad Shaker. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import NitroUIColorCategories


enum LocationType {
    case None
    case Source
    case Destination
}


class MapsViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!

    var sourcePlace: GMSPlace?
    var destinationPlace: GMSPlace?
    var selectedLocationType: LocationType = .None
    
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.setNavigationBarStyles()
        self.initMapView()
        
        sourceTextField.addTarget(self, action: #selector(sourceTextFieldActive), for: .editingDidBegin)
        destinationTextField.addTarget(self, action: #selector(destinationTextFieldActive), for: .editingDidBegin)
    }
    
    
    func setNavigationBarStyles()
    {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    func initMapView()
    {
        mapView.camera = GMSCameraPosition.camera(withLatitude: 30.0444, longitude: 31.2357, zoom: 8.0)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    
    func loadAutoSearchView()
    {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    @objc func sourceTextFieldActive()
    {
        selectedLocationType = .Source
        loadAutoSearchView()
    }
    
    
    @objc func destinationTextFieldActive()
    {
        selectedLocationType = .Destination
        loadAutoSearchView()
    }
    
    
    func showPath(polyStr: String)
    {
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor(fromARGBHexString: "40A085")
        polyline.strokeWidth = 2.0
        polyline.map = mapView
        
        let mapBounds = GMSCoordinateBounds(path: path!)
        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
        mapView.animate(with: cameraUpdate)
    }
    
    
    // Request to get path points to draw route between 2 locations
    func getPolylineRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D)
    {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "http://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }else{
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]{
                        
                        let routes = json["routes"] as? [Any]
                        let routersFirstObj = routes?[0] as? [String:Any]
                        let overviewPolyline = routersFirstObj?["overview_polyline"] as? [String:Any]
                        let polyString = overviewPolyline?["points"] as? String
                        
                        //Call this method to draw path on map
                        DispatchQueue.main.async() {
                            self.showPath(polyStr: polyString!)
                        }
                    }
                    
                }catch{
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    
    func drawRoute()
    {
        if (sourcePlace == nil || destinationPlace == nil) {
            return
        }
        getPolylineRoute(from: (sourcePlace?.coordinate)!, to: (destinationPlace?.coordinate)!)
    }
}


// =====================================================================
// ====================== Auto Complete Search =========================
// =====================================================================


extension MapsViewController: GMSAutocompleteViewControllerDelegate
{
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        switch selectedLocationType {
        case .Source:
            sourcePlace = place
            sourceTextField.text = place.formattedAddress
            break
        case .Destination:
            destinationPlace = place
            destinationTextField.text = place.formattedAddress
            break
        case .None:
            break
        }
        
        dismiss(animated: true) {
            self.drawRoute()
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


// =====================================================================
// ====================== Update User Location =========================
// =====================================================================


extension MapsViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 8.0)
        self.mapView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
}
