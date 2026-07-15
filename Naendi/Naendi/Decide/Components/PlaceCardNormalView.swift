//
//  PlaceCardNormalView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 15/07/26.
//

import SwiftUI

struct PlaceCardNormalView: View {
    let place: Place
    @Binding var isExpanded: Bool
    @Binding var isComparing: Bool
    var viewModel: DecideViewModel
    
    private var isSelected: Bool { viewModel.isSelected(place) }
    private var isCheckDisabled: Bool { viewModel.isCompareLimitReached && !isSelected }

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
                .frame(height: 240)
                .clipped()
            } else {
                Color.gray.opacity(0.3)
                    .frame(height: 240)
                    .overlay { Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray) }
            }
            
            HStack(alignment: .top) {
                // 1. Badge Jarak (Kiri)
                Text("0.5 km")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color("color_green"))
                    .clipShape(Capsule())
                
                Spacer() // Mendorong Checkbox ke kanan
                
                // 2. Checkbox (Kanan)
                if isComparing {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleSelection(for: place)
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(isSelected ? Color("color_green") : (isCheckDisabled ? Color.black.opacity(0.2) : Color.black.opacity(0.5)))
                                .frame(width: 32, height: 32)
                                .overlay(Circle().stroke(isCheckDisabled ? Color.white.opacity(0.3) : Color.white, lineWidth: 2))
                            
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isCheckDisabled)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(16)
            
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
        .frame(height: 240)
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
            isExpanded: .constant(false),
            isComparing: .constant(true),
            viewModel: DecideViewModel() // Inisialisasi ViewModel kosong untuk preview
        )
        .padding()
    }
}

