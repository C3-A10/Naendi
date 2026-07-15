//
//  Detail.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 15/07/26.
//

import SwiftUI
import MapKit

struct DetailPlaceView: View {
    let place: Place
    
    var body: some View {
        VStack {
            Button {
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
                    latitude: place.latitude,
                    longitude: place.longitude
                )))
                
                destination.name = place.nama
                
                // Membuka Maps dengan mode 'driving' (bisa diganti .walking atau .transit)
                destination.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            } label: {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Buka di Maps")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.black)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color("color_green"))
                .clipShape(Capsule())
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
        }
        .navigationTitle(Text(place.nama))
    }
}

#Preview {
    //DetailPlaceView()
}
