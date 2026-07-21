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
    func openAppleMapsRoute(to place: Place) {
                let location = CLLocation(
                    latitude: place.latitude,
                    longitude: place.longitude
                )

                let destination = MKMapItem(
                    location: location,
                    address: nil
                )

                destination.name = place.nama

                destination.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            }
}
