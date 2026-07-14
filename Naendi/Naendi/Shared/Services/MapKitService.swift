//
//  MapKitService.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import Foundation
import MapKit
import Combine

class MapKitService: NSObject {
    
    /// Open Apple Maps with navigation from origin to destination
    func openAppleMapsRoute(from origin:CLLocationCoordinate2D, to destination:CLLocationCoordinate2D) {
        // TODO: Implement Apple Maps navigation
        
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
        destinationItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
