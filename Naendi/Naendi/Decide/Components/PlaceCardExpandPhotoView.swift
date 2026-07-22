//
//  PlaceCardExpandPhotoView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 15/07/26.
//

import SwiftUI

struct PlaceCardExpandPhotoView: View {
    
    let isComparing: Bool
    let isSelected: Bool
    let isCheckDisabled: Bool
    let place: Place
    let viewModel: DecideViewModel
    let isDetail: Bool
    let onReport: () -> Void
    @Binding var selectedImageURL: URL?
    
    init(
        isComparing: Bool,
        isSelected: Bool,
        isCheckDisabled: Bool,
        place: Place,
        viewModel: DecideViewModel,
        isDetail: Bool = false,
        onReport: @escaping () -> Void = {},
        selectedImageURL: Binding<URL?>
    ) {
        self.isComparing = isComparing
        self.isSelected = isSelected
        self.isCheckDisabled = isCheckDisabled
        self.place = place
        self.viewModel = viewModel
        self.isDetail = isDetail
        self.onReport = onReport
        self._selectedImageURL = selectedImageURL
    }
    
    private var imageGallery: [String] {
        let urls = place.parsedImageUrls
        
        if !urls.isEmpty {
            return urls
        }
        
        // (Opsional) Fallback: Jika tempat tersebut sama sekali tidak punya gambar di JSON
        // Gunakan 1 atau 2 gambar default agar layout grid di UI tidak rusak/kosong
        return [
            "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1559925393-8be0ec4767c8?q=80&w=800&auto=format&fit=crop"
        ]
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.horizontal, showsIndicators: false) {
                // 1. Set spacing LazyHStack ke 12, dan beri padding horizontal 12
                LazyHStack(spacing: 12) {
                    ForEach(Array(imageGallery.enumerated()), id: \.offset) { index, urlString in
                        
                        // POLA 1: FULL IMAGE (Indeks 0, 3, 6, ...)
                        if index % 3 == 0 {
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } else {
                                        Color.gray.opacity(0.3)
                                    }
                                }
                                .frame(width: 290, height: 220)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) 
                                .onTapGesture {
                                    selectedImageURL = url
                                }
                            }
                        }
                        // POLA 2: TUMPUK ATAS BAWAH (Mulai di Indeks 1, 4, 7, ...)
                        else if index % 3 == 1 {
                            // 2. Set spacing VStack ke 12
                            VStack(spacing: 12) {
                                // Gambar Atas (Indeks saat ini)
                                if let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.gray.opacity(0.3)
                                        }
                                    }
                                    // 3. Set tinggi menjadi 104 agar total tinggi + spacing pas 220 (104 + 12 + 104)
                                    .frame(width: 160, height: 104)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .onTapGesture {
                                        selectedImageURL = url
                                    }
                                }
                                
                                // Gambar Bawah (Ambil indeks + 1 jika ada)
                                if index + 1 < imageGallery.count, let nextUrl = URL(string: imageGallery[index + 1]) {
                                    AsyncImage(url: nextUrl) { phase in
                                        if let image = phase.image {
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.gray.opacity(0.3)
                                        }
                                    }
                                    .frame(width: 160, height: 104)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .onTapGesture {
                                        selectedImageURL = nextUrl
                                    }
                                }
                            }
                        }
                        // Indeks 2, 5, 8... diabaikan karena sudah dirender di atas
                    }
                }
                .padding(.horizontal, 12) // Padding kiri dan kanan ujung galeri
                .padding(.vertical, 10)   // Penyeimbang sisa tinggi frame kontainer (240 - 220) / 2
            }
            .frame(height: 240)
            
            // --- Overlay: Pill Jarak dan Checkbox Kanan ---
            DistanceCheckmarkView(
                isComparing: isComparing,
                isSelected: isSelected,
                isCheckDisabled: isCheckDisabled,
                place: place,
                viewModel: viewModel,
                distancePillColor: Color("color_green"),
                isTagVisible: false,
                isDetail: isDetail,
                onReport: onReport
            )
        }
        .frame(height: 240)
        .clipped()
    }
}
