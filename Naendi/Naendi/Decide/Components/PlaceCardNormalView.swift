//
//  PlaceCardNormalView.swift
//  C3Satriya
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import SwiftUI

struct PlaceCardNormalView: View {
    let place: Place
    let frameHeight: CGFloat
    @Binding var isExpanded: Bool
    @Binding var isComparing: Bool
    @State var viewModel: DecideViewModel
    
    var isSelected: Bool { viewModel.isSelected(place) }
    var isCheckDisabled: Bool { viewModel.isCompareLimitReached && !isSelected }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Gambar
            if let urlString = place.imgUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(height: frameHeight)
                .clipped()
            } else {
                Color.gray.opacity(0.3)
                    .frame(height: frameHeight)
                    .overlay { Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray) }
            }
            
            DistanceCheckmarkView(
                isComparing: isComparing,
                isSelected: isSelected,
                isCheckDisabled: isCheckDisabled,
                place: place,
                viewModel: viewModel
            )
            
            // Tombol Expand
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(place.nama).font(.system(size: 22, weight: .bold)).foregroundColor(.black).lineLimit(1)
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 15))
                            Text("\(place.rating, specifier: "%.1f")").font(.system(size: 15, weight: .semibold)).foregroundColor(.black)
                            Text("•").foregroundColor(.secondary)
                            Text("(\(place.jumlahReview))").font(.system(size: 14)).foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.down").font(.system(size: 18, weight: .bold)).foregroundColor(.black)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(12)
            }
            .buttonStyle(.plain)
        }
        .frame(height: frameHeight)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemGray6).ignoresSafeArea()
        
        PlaceCardNormalView(
            place: Place.dummyData[0],
            frameHeight: 400,
            isExpanded: .constant(false),
            isComparing: .constant(true),
            viewModel: DecideViewModel() 
        )
        .padding()
    }
}
