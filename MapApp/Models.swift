//
//  Models.swift
//  MapApp
//
//  Created by Eldor Makkambaev on 01.05.2018.
//  Copyright © 2018 Eldor Makkambaev. All rights reserved.
//

import UIKit
import MapKit

final class Anotation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
