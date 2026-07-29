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
    let isReported: Bool
    let onReport: () -> Void
    let onSelectImageIndex: (Int) -> Void

    init(
        isComparing: Bool,
        isSelected: Bool,
        isCheckDisabled: Bool,
        place: Place,
        viewModel: DecideViewModel,
        isDetail: Bool = false,
        isReported: Bool = false,
        onReport: @escaping () -> Void = {},
        onSelectImageIndex: @escaping (Int) -> Void,
    ) {
        self.isComparing = isComparing
        self.isSelected = isSelected
        self.isCheckDisabled = isCheckDisabled
        self.place = place
        self.viewModel = viewModel
        self.isDetail = isDetail
        self.isReported = isReported
        self.onReport = onReport
        self.onSelectImageIndex = onSelectImageIndex
    }

    private var imageGallery: [String] {
        let urls = place.parsedImageUrls

        if !urls.isEmpty {
            return urls
        }
        return []
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.horizontal, showsIndicators: false) {
                // 1. Set spacing LazyHStack ke 12, dan beri padding horizontal 12
                LazyHStack(spacing: 12) {
                    ForEach(Array(imageGallery.enumerated()), id: \.offset) { index, urlString in

                        // POLA 1: FULL IMAGE (Indeks 0, 3, 6, ...)
                        if index % 3 == 0 {
                            galleryImageButton(
                                urlString: urlString,
                                index: index,
                                width: 290,
                                height: 220,
                                hidesOfflineCaption: false
                            )
                        }
                        // POLA 2: TUMPUK ATAS BAWAH (Mulai di Indeks 1, 4, 7, ...)
                        else if index % 3 == 1 {
                            // 2. Set spacing VStack ke 12
                            VStack(spacing: 12) {
                                // Gambar Atas (Indeks saat ini)
                                galleryImageButton(
                                    urlString: urlString,
                                    index: index,
                                    width: 160,
                                    height: 104,
                                    hidesOfflineCaption: true
                                )

                                // Gambar Bawah (Ambil indeks + 1 jika ada)
                                if index + 1 < imageGallery.count {
                                    galleryImageButton(
                                        urlString: imageGallery[index + 1],
                                        index: index + 1,
                                        width: 160,
                                        height: 104,
                                        hidesOfflineCaption: true
                                    )
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
                isReported: isReported,
                onReport: onReport
            )
        }
        .frame(height: 240)
        .clipped()
    }

    @ViewBuilder
    private func galleryImageButton(
        urlString: String,
        index: Int,
        width: CGFloat,
        height: CGFloat,
        hidesOfflineCaption: Bool
    ) -> some View {
        if let url = URL(string: urlString) {
            Button {
                onSelectImageIndex(index)
            } label: {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if !viewModel.isNetworkConnected {
                        NoInternetPlaceholder(isCaptionHidden: hidesOfflineCaption)
                    } else {
                        ZStack {
                            Color.gray.opacity(0.1)
                            ProgressView()
                                .scaleEffect(0.7)
                        }
                    }
                }
                .frame(width: width, height: height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                Text("Photo \(index + 1) of \(imageGallery.count), \(place.nama)")
            )
            .accessibilityHint("Double-tap to open the full-screen image.")
        }
    }
}
