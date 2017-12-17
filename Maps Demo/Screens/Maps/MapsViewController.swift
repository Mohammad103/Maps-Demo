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
    
    
    func drawRoute()
    {
        
    }
}


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


extension MapsViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        self.mapView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
}
