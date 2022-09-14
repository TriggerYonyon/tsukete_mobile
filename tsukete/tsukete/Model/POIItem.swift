//
//  POIItem.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/12.
//

import GoogleMapsUtils

// Cluster Item Model
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    
    init(position: CLLocationCoordinate2D) {
        self.position = position
    }
}
