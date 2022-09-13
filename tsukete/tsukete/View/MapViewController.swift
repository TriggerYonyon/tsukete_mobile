//
//  MapViewController.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/12.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Google 地図表示
        // Create a Google Camera Position
        let camera = GMSCameraPosition.camera(withLatitude: 37.566508, longitude: 126.977945, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)

        // Google Marker 表示
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.566508, longitude: 126.977945)
        marker.title = "Sydney"
        marker.snippet = "Japan"
        marker.map = mapView
    }

}
