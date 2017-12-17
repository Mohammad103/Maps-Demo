//
//  MapsViewController.swift
//  Maps Demo
//
//  Created by Mohammad Shaker on 12/17/17.
//  Copyright © 2017 Mohammad Shaker. All rights reserved.
//

import UIKit
import GoogleMaps

class MapsViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.setNavigationBarStyles()
        self.initMapView()
    }
    
    
    func setNavigationBarStyles()
    {
        self.navigationController?.navigationBar.isTranslucent = false
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
