//
//  CompareView.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import SwiftUI

struct CompareView: View {
    let places: [Place]
    
    var body: some View {
        List {
            ForEach(places) { place in
                VStack(alignment: .leading) {
                    Text(place.nama).font(.headline)
                    Text("Rating: \(place.rating, specifier: "%.1f")")
                }
            }
        }
        .navigationTitle(Text("Compare"))
    }
}

#Preview {
    // CompareView()
}
