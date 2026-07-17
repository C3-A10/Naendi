//
//  PlaceCardNormalView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import SwiftUI

// Asumsi enum ini didefinisikan di project-mu, pastikan memiliki case .detail tambahan
enum PlaceCardMode {
    case landing
    case result
    case detail
}

struct PlaceCardNormalView: View {
    let place: Place
    var mode: PlaceCardMode = .landing
    @Binding var isExpanded: Bool
    @Binding var isComparing: Bool
    @State var viewModel: DecideViewModel
    
    // Custom initializer digabung agar aman dengan @State viewModel dari kedua versi
    init(place: Place, mode: PlaceCardMode = .landing, isExpanded: Binding<Bool>, isComparing: Binding<Bool>, viewModel: DecideViewModel) {
        self.place = place
        self.mode = mode
        self._isExpanded = isExpanded
        self._isComparing = isComparing
        self._viewModel = State(initialValue: viewModel)
    }
    
    var isSelected: Bool { viewModel.isSelected(place) }
    var isCheckDisabled: Bool { viewModel.isCompareLimitReached && !isSelected }
    
    // Diambil dari properti kode utama untuk mengatur tinggi gambar/kartu di mode non-landing
    private var cardHeight: CGFloat { mode == .detail ? 400 : 240 }

    var body: some View {
        switch mode {
        case .landing:
            // MARK: - LAYOUT LANDING (Kode yang kamu kerjakan)
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        
                        // MARK: - 1. HEADER TEKS ("People's Favourite")
                        Text("People's Favourite")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 18)
                            .padding(.bottom, 12)
                        
                        // MARK: - 2. KARTU DALAM (GAMBAR & FOLDER PUTIH)
                        ZStack(alignment: .bottom) {
                            
                            // A. GAMBAR KAFE
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
                            .padding(-8)
                            
                            // B. FOLDER TAB PUTIH
                            VStack(alignment: .leading, spacing: 16) {
                                // Baris 1: Area Badges
                                HStack(spacing: 4) {
                                    TagView(text: place.typeTempat, backgroundColor: Color(red: 0.78, green: 0.98, blue: 0.35), textColor: Color(red: 0.15, green: 0.35, blue: 0.05))
                                    TagView(text: place.vibe, backgroundColor: Color(red: 0.75, green: 0.92, blue: 0.85), textColor: Color(red: 0.05, green: 0.30, blue: 0.25))
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
                                    tabWidth: 150,
                                    slopeWidth: 25,
                                    leftTabHeight: 135,
                                    rightTabHeight: 101,
                                    leftCornerRadius: 20,
                                    rightCornerRadius: 20
                                )
                                .fill(Color.white)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color("color_green"))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                }
                .contentShape(Rectangle())
            }

        case .result, .detail:
            // MARK: - LAYOUT RESULT & DETAIL (Gabungan logic utama + custom warna ijo dari kodemu)
            ZStack(alignment: .bottom) {
                // Gambar dengan penanganan AsyncImage lengkap dari kode utama + penyesuaian tinggi otomatis
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
                        // Tombol report muncul jika modenya detail
                        if mode == .detail {
                            Image(systemName: "exclamationmark.bubble.fill")
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
                            if mode == .detail {
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
                    viewModel: viewModel,
                    distancePillColor: Color("color_green") // Menggunakan modifikasi warna ijo dari kodemu
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
            .frame(height: cardHeight)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
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
