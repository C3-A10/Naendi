//
//  LandingView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 16/07/26.
//

import SwiftUI
import SwiftData

struct LandingView: View {
    @Environment(\.modelContext) private var modelContext
    @State var viewModel: DecideViewModel
    @State private var isComparing: Bool = false
    @State private var selectedPlace: Place? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var isShowingEditPreference = false
    @State private var imgStartIndex: Int = 0
    @State private var selectedPlaceForImage: Place?

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - ZSTACK UTAMA: Memisahkan Latar Belakang (Hero) & Konten (Scroll)
            ZStack(alignment: .top) {
                ZStack(alignment: .bottom) {
                    // Gambar Hero & Teks
                    ZStack(alignment: .top) {
                        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=1000&auto=format&fit=crop")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width, height: 420)
                                    .clipped()
                            } else {
                                Color(UIColor.darkGray)
                                    .frame(width: UIScreen.main.bounds.width, height: 420)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 420)
                        .clipped()
                        .accessibilityHidden(true)

                        // Maskot di Kiri dan Kanan
                        HStack(spacing: 0) {
                            Image("asset_bicycle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .offset(x: -50)
                                .offset(y: 30)

                            Spacer()

                            Image("asset_rabbit")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 250)
                                .offset(x: 50)
                                .offset(y: -40)
                        }
                        .frame(maxWidth: .infinity) // Memaksa HStack membentang selebar mungkin
                        .padding(.horizontal, 0) // Memastikan tidak ada jarak/margin bawaan dari sistem
                        .padding(.top, 100)
                        .accessibilityHidden(true)

                        Text("Discover somewhere new")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                            .padding(.top, 64)
                            .accessibilityAddTraits(.isHeader)

                        // Gradient Transisi ke Putih (Agar menyatu dengan latar belakang aplikasi)
                        VStack {
                            Spacer()
                            LinearGradient(
                                colors: [Color(.systemBackground).opacity(0.0), Color(.systemBackground).opacity(0.8), Color(.systemBackground)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 140)
                            .accessibilityHidden(true)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 420)
                }
                .frame(width: UIScreen.main.bounds.width, height: 420)
                .blur(radius: calculateBlur())
                .opacity(calculateOpacity())
                .offset(y: scrollOffset < 0 ? (scrollOffset / 2) : 0) // Efek paralaks naik perlahan
                .ignoresSafeArea(edges: .top)

                ScrollView {
                    VStack(spacing: 0) {
                        GeometryReader { proxy -> Color in
                            let minY = proxy.frame(in: .named("scroll_space")).minY
                            DispatchQueue.main.async {
                                self.scrollOffset = minY
                            }
                            return Color.clear
                        }
                        .frame(height: 0)


                        VStack {
                            Spacer()

                            // Tombol Hijau ("Select Your Preferences") - Berada di atas gambar
                            CustomActionButton(
                                text: "Select Your Preferences",
                                backgroundColor: Color("color_green"),
                                textColor: Color(red: 0.15, green: 0.25, blue: 0.05)
                            ) {
                                isShowingEditPreference = true
                            }
                            .frame(width: 250)
                            .padding(.bottom, 20)
                        }
                        .frame(height: 340)

                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.landingPagePlaces) { place in

                                PlaceCardView(
                                    place: place,
                                    mode: .landing,
                                    isChooseThisLocationBtnVisible: true,
                                    isTagVisible: true,
                                    isReportVisible: false,
                                    viewModel: viewModel,
                                    isComparing: $isComparing,
                                    onSelectImageIndex: { index in
                                        imgStartIndex = index
                                        selectedPlaceForImage = place
                                    },
                                    selectedPlace: $selectedPlace
                                )

                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 16)
                        .padding(.bottom, viewModel.isCompareLimitReached ? 80 : 16)
                    }
                    .frame(width: UIScreen.main.bounds.width)
                }
                .coordinateSpace(name: "scroll_space")

            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.clearSelectedPlaces()
            isComparing = false
        }
        .navigationTitle(Text("Discover"))
        .fullScreenCover(item: $selectedPlaceForImage) { place in
            NavigationStack {
                FullImageDetailView(imageUrls: place.parsedImageUrls, startIndex: imgStartIndex)
            }
        }
        .fullScreenCover(item: $selectedPlace) { place in
            NavigationStack {
                DetailPlaceView(place: place)
            }
        }
        .fullScreenCover(isPresented: $isShowingEditPreference) {
            EditPreferenceView(criteria: viewModel.criteria) { criteria in
                Task {
                    await viewModel.applyPreferences(
                        criteria,
                        store: AppServices.preferenceStore(context: modelContext),
                        provider: AppServices.placeProvider(context: modelContext)
                    )
                }
            }
        }
    }

    // MARK: - Rumus Hitung Efek Blur & Fade Out

    // Menghitung intensitas blur: Semakin ke bawah di-scroll, semakin blur (maksimal radius 15)
    private func calculateBlur() -> CGFloat {
        if scrollOffset >= 0 {
            return 0
        } else {
            let progress = abs(scrollOffset) / 200.0
            return min(CGFloat(progress * 15.0), 15.0)
        }
    }

    // Menghitung opasitas: Gambar memudar perlahan agar tidak mengganggu keterbacaan kartu
    private func calculateOpacity() -> Double {
        if scrollOffset >= 0 {
            return 1.0
        } else {
            let progress = abs(scrollOffset) / 280.0
            return max(0.0, 1.0 - progress)
        }
    }
}

#Preview {
    LandingView(viewModel: DecideViewModel())
}
