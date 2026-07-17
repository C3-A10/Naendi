//
//  PlaceCardNormalView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import SwiftUI

struct PlaceCardNormalView: View {
    let place: Place
    let isDetail: Bool
    let isReported: Bool=false
    @Binding var isExpanded: Bool
    @Binding var isComparing: Bool
    @State var viewModel: DecideViewModel
    
    init(place: Place, isDetail: Bool, isExpanded: Binding<Bool>, isComparing: Binding<Bool>, viewModel: DecideViewModel) {
        self.place = place
        self.isDetail = isDetail
        self._isExpanded = isExpanded
        self._isComparing = isComparing
        self._viewModel = State(initialValue: viewModel)
    }
    
    var isSelected: Bool { viewModel.isSelected(place) }
    var isCheckDisabled: Bool { viewModel.isCompareLimitReached && !isSelected }
    private var cardHeight: CGFloat { isDetail ? 400 : 240 }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Gambar
            if let urlString = place.imgUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                        
                    case .success(let image):
                        GeometryReader { geo in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        }
                        .frame(height: cardHeight)
                        
                    case .failure, .empty:
                        Color.gray.opacity(0.3)
                            .frame(height: cardHeight)
                            .overlay {
                                ProgressView()
                            }
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                .overlay(alignment: .topTrailing) {
                    // Tombol report
                    if isDetail {
                        
                        Image(systemName: isReported ? "exclamationmark.bubble.fill" : "exclamationmark.bubble")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(12)
                            .clipShape(Circle())
                            .padding(12)
                        
                    }
                }
            } else {
                Color.gray.opacity(0.3)
                    .frame(height: cardHeight)
                    .overlay { Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray) }
                    .overlay(alignment: .topTrailing) {
                        if isDetail {
                            Image(systemName: "exclamationmark.bubble.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                                .padding(12)
                        }
                    }
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
        .frame(height: cardHeight)
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
            isDetail: true,
            isExpanded: .constant(false),
            isComparing: .constant(true),
            viewModel: DecideViewModel()
        )
        .padding()
    }
}
