//
//  PlaceCardNormalView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import SwiftUI


struct PlaceCardNormalView: View {
    let place: Place
    var mode: PlaceCardMode = .landing
    let isReported: Bool=false
    @Binding var isExpanded: Bool
    @Binding var isComparing: Bool
    @State var viewModel: DecideViewModel
    
    var isSelected: Bool { viewModel.isSelected(place) }
    var isCheckDisabled: Bool { viewModel.isCompareLimitReached && !isSelected }

    var body: some View {
        if mode == .result {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 240)
                    .overlay {
                        if let urlString = place.imgUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    Color.gray.opacity(0.3)
                                }
                            }
                        } else {
                            Color.gray.opacity(0.3)
                                .overlay { Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray) }
                        }
                    }
                    .clipped()
                
                DistanceCheckmarkView(
                    isComparing: isComparing,
                    isSelected: isSelected,
                    isCheckDisabled: isCheckDisabled,
                    place: place,
                    viewModel: viewModel,
                    distancePillColor: Color("color_green")
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
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
            
        } else if mode == .landing {
            ZStack (alignment: .bottom) {
                VStack(spacing: 0) {
                    // MARK: - 2. KARTU DALAM (GAMBAR & FOLDER PUTIH)
                    ZStack(alignment: .bottom) {
                            Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 240)
                            .overlay {
                                if let urlString = place.imgUrl, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.gray.opacity(0.3)
                                        }
                                    }
                                } else {
                                    Color.gray.opacity(0.3)
                                        .overlay { Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray) }
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .padding(.horizontal, 12)
                            .padding(.bottom, 25)
                        
                        DistanceCheckmarkView(
                            isComparing: false,
                            isSelected: false,
                            isCheckDisabled: true,
                            place: place,
                            viewModel: viewModel,
                            distancePillColor: .white
                        )
                        .padding(.top, 4)
                        .padding(.horizontal, 2)

                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 4) {
                                TagView(text: place.typeTempat, backgroundColor: Color.orange.opacity(0.15), textColor: Color(red: 0.90, green: 0.45, blue: 0.10))

                                TagView(text: place.vibe, backgroundColor: Color.blue.opacity(0.15), textColor: Color(red: 0.10, green: 0.45, blue: 0.90))
                                
                                if place.isHalalConfirmed {
                                    TagView(text: "Halal", backgroundColor: Color.green.opacity(0.15), textColor: Color(red: 0.15, green: 0.65, blue: 0.30))
                                }
                                Spacer()
                            }
                            .frame(height: 10)
                            
                            // Button Expand
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
                                .padding(12)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .frame(height: 130)
                        .background(
                            FolderTabShape(
                                tabWidth: 190,
                                slopeWidth: 40,
                                leftTabHeight: 135,
                                rightTabHeight: 101,
                                leftCornerRadius: 20,
                                rightCornerRadius: 20
                            )
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)

                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 278)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemGray6).ignoresSafeArea()
        
        PlaceCardNormalView(
            place: Place.dummyData[0],
            mode: .landing,
            isExpanded: .constant(false),
            isComparing: .constant(true),
            viewModel: DecideViewModel()
        )
        .padding()
    }
}
