//
//  PlaceCardExpandView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 15/07/26.
//

import SwiftUI
import Combine

struct PlaceCardExpandView: View {
    let place: Place
    @Binding var isExpanded: Bool
    @Binding var isComparing: Bool
    var viewModel: DecideViewModel
    
    // Helper status
    private var isSelected: Bool { viewModel.isSelected(place) }
    private var isCheckDisabled: Bool { viewModel.isCompareLimitReached && !isSelected }
    
    @State private var selectedReviewIndex = 0
    private let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    private var imageGallery: [String] {
        var images: [String] = []
        if let mainImg = place.imgUrl {
            images.append(mainImg)
        }
        images.append("https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=800&auto=format&fit=crop")
        images.append("https://images.unsplash.com/photo-1559925393-8be0ec4767c8?q=80&w=800&auto=format&fit=crop")
        return images
    }
    
    private var reviewItems: [(title: String, text: String, isPositive: Bool)] {
        var items: [(String, String, Bool)] = []
        items.append(("What People Love", place.reviewPositif, true))
        items.append(("Things to Consider", place.reviewNegatif, false))
        return items
    }
    
    @State private var selectedImageURL: URL? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 1. BAGIAN FOTO (HORIZONTAL SCROLL)
            ZStack(alignment: .top) { // Align top agar overlay menempel di atas
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(imageGallery, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } else {
                                        Color.gray.opacity(0.3)
                                    }
                                }
                                .frame(width: 290, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .onTapGesture {
                                    selectedImageURL = url
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
                .frame(height: 240)
                
                // --- Overlay: Pill Kiri dan Checkbox Kanan ---
                HStack(alignment: .top) {
                    // Pill Jarak (Kiri Atas)
                    Text("0.5 km")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color("color_green"))
                        .clipShape(Capsule())
                    
                    Spacer() // Mendorong Checkbox ke kanan
                    
                    // Checkbox (Kanan Atas)
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
                                    .overlay(
                                        Circle()
                                            .stroke(isCheckDisabled ? Color.white.opacity(0.3) : Color.white, lineWidth: 2)
                                    )
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
                .padding(.horizontal, 12)
                .padding(.vertical, 12)// Padding agar tidak terlalu menempel ke tepi
            }
            
            // MARK: - 2. BAGIAN INFORMASI & DETAIL
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.nama)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 14))
                            
                            Text("\(place.rating, specifier: "%.1f")")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text("•").foregroundColor(.secondary)
                            Text("(\(place.jumlahReview))").font(.system(size: 13)).foregroundColor(.secondary)
                            Text("•").foregroundColor(.secondary)
                            Text(place.rangeHarga ?? "Harga N/A").font(.system(size: 13, weight: .regular)).foregroundColor(.secondary).lineLimit(1)
                        }
                    }
                    
                    Spacer(minLength: 4)
                    
                    Button {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            isExpanded = false
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                }
                
                // Badges
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        Text(place.typeTempat)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 0.90, green: 0.45, blue: 0.10))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                        
                      
                        Text(place.vibe)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.90))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(Capsule())
                        
                        
                        if place.isHalalConfirmed {
                            Text("Halal")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 0.15, green: 0.65, blue: 0.30))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                }
                
                // Alamat Lengkap
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                    
                    Text(place.alamat)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Operational Hours
                HStack(alignment: .center, spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    
                    Text(place.statusJamBukaFormatted)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Divider()
                    .padding(.vertical, 2)
                
                // AI Reviews Summary Section
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.indigo)
                        
                        Text("AI Reviews Summary")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    if !reviewItems.isEmpty {
                        TabView(selection: $selectedReviewIndex) {
                            ForEach(0..<reviewItems.count, id: \.self) { index in
                                let item = reviewItems[index]
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 6) {
                                        Image(systemName: item.isPositive ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                                            .foregroundColor(item.isPositive ? .green : .red)
                                            .font(.system(size: 13))
                                        
                                        Text(item.title)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(item.isPositive ? .green : .red)
                                        
                                        Spacer()
                                        
                                        Text("\(index + 1)/\(reviewItems.count)")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(item.text)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color(UIColor.darkGray))
                                        .lineSpacing(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                                )
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 130)
                        .onReceive(timer) { _ in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                selectedReviewIndex = (selectedReviewIndex + 1) % reviewItems.count
                            }
                        }
                    }
                }
            }
            .padding(12)
        }
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        .transition(.identity)
//        .fullScreenCover(item: $selectedImageURL) { url in
//            FullImageDetailView(url: url)
//        }
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemGray6)
            .ignoresSafeArea()
        
        ScrollView {
            PlaceCardExpandView(
                place: Place.dummyData[0],
                isExpanded: .constant(false),
                isComparing: .constant(true),
                viewModel: DecideViewModel()
            )
            .padding(.horizontal)
            .padding(.vertical)
        }
    }
}
