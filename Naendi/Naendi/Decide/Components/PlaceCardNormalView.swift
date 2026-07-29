//
//  PlaceCardNormalView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import SwiftUI


struct PlaceCardNormalView: View {
    let place: Place
    var mode: PlaceCardMode
    let isReported: Bool
    let isTagVisible: Bool
    let isDetail: Bool
    let onReport: () -> Void
    @Binding var isExpanded: Bool
    @Binding var isComparing: Bool
    @State var viewModel: DecideViewModel

    init(
        place: Place,
        mode: PlaceCardMode = .landing,
        isReported: Bool,
        isTagVisible: Bool,
        isDetail: Bool = false,
        onReport: @escaping () -> Void = {},
        isExpanded: Binding<Bool>,
        isComparing: Binding<Bool>,
        viewModel: DecideViewModel
    ) {
        self.place = place
        self.mode = mode
        self.isReported = isReported
        self.isTagVisible = isTagVisible
        self.isDetail = isDetail
        self.onReport = onReport
        self._isExpanded = isExpanded
        self._isComparing = isComparing
        self._viewModel = State(initialValue: viewModel)
    }

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
                                } else if !viewModel.isNetworkConnected {
                                    NoInternetPlaceholder(paddingBottom: 32)
                                } else {
                                    ZStack {
                                        Color.gray.opacity(0.1)
                                        ProgressView().padding(.bottom, 32)
                                    }
                                }
                            }
                        } else {
                            Color.gray.opacity(0.3)
                                .overlay { Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray) }
                        }
                    }
                    .clipped()
                    .allowsHitTesting(false)

                DistanceCheckmarkView(
                    isComparing: isComparing,
                    isSelected: isSelected,
                    isCheckDisabled: isCheckDisabled,
                    place: place,
                    viewModel: viewModel,
                    distancePillColor: Color("color_green"),
                    isTagVisible: isTagVisible,
                    isDetail: isDetail,
                    isReported: isReported,
                    hidesMetadataFromAccessibility: true,
                    onReport: onReport
                )
                .zIndex(isComparing ? 3 : 1)

                // Tombol Expand
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.nama)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary).lineLimit(1)
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill").foregroundColor(.yellow).font(.body)
                                    .accessibilityHidden(true)
                                Text("\(place.rating, specifier: "%.1f")").font(.body).fontWeight(.semibold).foregroundColor(.primary)
                                    .accessibilityLabel("Rating \(place.accessibilityRatingDescription)")
                                Text("•").foregroundColor(.secondary).font(.body)
                                Text("(\(place.jumlahReview))").font(.caption).foregroundColor(.secondary)
                                    .accessibilityLabel("\(place.accessibilityReviewCountDescription) reviews")
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.down").font(.title3).fontWeight(.bold) .foregroundColor(.primary)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .allowsHitTesting(!isComparing)
                .accessibilityHidden(true)
                .zIndex(2)

                if !isComparing {
                    Button {
                        expandCard()
                    } label: {
                        Color.clear
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(place.nama))
                    .accessibilityValue(Text(resultCardAccessibilitySummary))
                    .accessibilityHint("Double-tap to show expanded information.")
                    .accessibilityAddTraits(.isButton)
                    .zIndex(4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

        } else if mode == .landing {
            ZStack (alignment: .bottom) {
                Button {
                    expandCard()
                } label: {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: 278)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(place.nama))
                .accessibilityValue(Text(landingCardAccessibilitySummary))
                .accessibilityHint("Double-tap to show expanded information.")
                .accessibilityAddTraits(.isButton)
                .zIndex(4)

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
                                        } else if !viewModel.isNetworkConnected {
                                            NoInternetPlaceholder(paddingBottom: 64)
                                        } else {
                                            ZStack {
                                                Color.gray.opacity(0.1)
                                                ProgressView().padding(.bottom, 40)
                                            }
                                        }
                                    }
                                } else {
                                    Color.gray.opacity(0.3)
                                        .overlay { Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray) }
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .allowsHitTesting(false)
                            .padding(.horizontal, 12)
                            .padding(.bottom, 25)

                        DistanceCheckmarkView(
                            isComparing: false,
                            isSelected: false,
                            isCheckDisabled: true,
                            place: place,
                            viewModel: viewModel,
                            distancePillColor: Color("color_green"),
                            isTagVisible: isTagVisible,
                            isDetail: isDetail,
                            isReported: isReported,
                            hidesMetadataFromAccessibility: isDetail,
                            onReport: onReport
                        )
                        .zIndex(isDetail ? 3 : 1)
                        .padding(.top, 4)
                        .padding(.horizontal, 2)


                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 4) {
                                TagView(text: place.typeTempat, backgroundColor: Color.orange.opacity(0.15), textColor: Color(red: 0.90, green: 0.45, blue: 0.10))

                                TagView(text: place.vibe, backgroundColor: Color.blue.opacity(0.15), textColor: Color(red: 0.10, green: 0.45, blue: 0.90))

                                switch place.halal.lowercased() {
                                    case "halal":
                                        TagView(text: "Halal", backgroundColor: Color.green.opacity(0.15), textColor: Color(red: 0.15, green: 0.65, blue: 0.30))
                                    case "non-halal":
                                        TagView(text: "Nonhalal", backgroundColor: Color(red: 0.98, green: 0.85, blue: 0.85),
                                                textColor: Color(red: 0.75, green: 0.22, blue: 0.22))
                                    default:
                                        EmptyView()
                                }
                                Spacer()
                            }
                            .frame(height: 10)
                            .accessibilityHidden(isDetail)

                            // Button Expand
                            Button {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    isExpanded.toggle()
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(place.nama).font(.title3)
                                            .fontWeight(.bold).foregroundColor(.primary).lineLimit(1)
                                        HStack(spacing: 6) {
                                            Image(systemName: "star.fill").foregroundColor(.yellow).font(.body)
                                                .accessibilityHidden(true)
                                            Text("\(place.rating, specifier: "%.1f")").font(.body).fontWeight(.semibold).foregroundColor(.primary)
                                                .accessibilityLabel("Rating \(place.accessibilityRatingDescription)")
                                            Text("•").foregroundColor(.secondary).font(.body)
                                            Text("(\(place.jumlahReview))").font(.caption).fontWeight(.semibold).foregroundColor(.secondary)
                                                .accessibilityLabel("\(place.accessibilityReviewCountDescription) reviews")
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down").font(.system(size: 18, weight: .bold)).foregroundColor(.primary)
                                }
                                .padding(12)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .zIndex(2)
                            .accessibilityHidden(isDetail)
                            .accessibilityLabel(place.nama)
                            .accessibilityValue("Rating \(place.accessibilityRatingDescription), \(place.accessibilityReviewCountDescription) reviews")
                            .accessibilityHint("Shows more details about this place.")
                            .accessibilityAction {
                                expandCard()
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .frame(height: 130)
                        .background(
                            FolderTabShape(
                                tabWidth: 215,
                                slopeWidth: 30,
                                leftTabHeight: 135,
                                rightTabHeight: 101,
                                leftCornerRadius: 20,
                                rightCornerRadius: 20
                            )
                            .fill(Color(.secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)

                        )
                    }

                }
                .zIndex(1)
                .accessibilityHidden(true)
                .frame(maxWidth: .infinity)
                .frame(height: 278)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .contentShape(Rectangle())
        }
    }

    private func expandCard() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            isExpanded = true
        }
    }

    private var resultCardAccessibilitySummary: String {
        return String(
            format: String(
                localized: "Rating %@, %@ reviews, distance %@, %lld reports"
            ),
            locale: .current,
            place.accessibilityRatingDescription,
            place.accessibilityReviewCountDescription,
            viewModel.calculateDistance(to: place),
            Int64(viewModel.reportCount(for: place))
        )
    }

    private var detailCardAccessibilitySummary: String {
        if let halalStatus = halalAccessibilityDescription {
            return String(
                format: String(
                    localized: "Type %@, vibe %@, dietary status %@, rating %@, %@ reviews, distance %@, %lld reports"
                ),
                locale: .current,
                String(localized: String.LocalizationValue(place.typeTempat)),
                String(localized: String.LocalizationValue(place.vibe)),
                halalStatus,
                place.accessibilityRatingDescription,
                place.accessibilityReviewCountDescription,
                viewModel.calculateDistance(to: place),
                Int64(viewModel.reportCount(for: place))
            )
        }

        return String(
            format: String(
                localized: "Type %@, vibe %@, rating %@, %@ reviews, distance %@, %lld reports"
            ),
            locale: .current,
            String(localized: String.LocalizationValue(place.typeTempat)),
            String(localized: String.LocalizationValue(place.vibe)),
            place.accessibilityRatingDescription,
            place.accessibilityReviewCountDescription,
            viewModel.calculateDistance(to: place),
            Int64(viewModel.reportCount(for: place))
        )
    }

    private var halalAccessibilityDescription: String? {
        switch place.halal.lowercased() {
        case "halal":
            return String(localized: "Halal")
        case "non-halal", "nonhalal":
            return String(localized: "Non-Halal")
        default:
            return nil
        }
    }

    private var landingCardAccessibilitySummary: String {
        guard isTagVisible, let tagDescription = landingTagAccessibilityDescription else {
            return detailCardAccessibilitySummary
        }

        return String(
            format: String(
                localized: "Recommendation %@, %@"
            ),
            locale: .current,
            tagDescription,
            detailCardAccessibilitySummary
        )
    }

    private var landingTagAccessibilityDescription: String? {
        guard let tag = viewModel.landingTag(for: place) else { return nil }

        switch tag {
        case .nearby:
            return String(localized: "Nearby")
        case .top(let type):
            return String(
                format: String(localized: "Top %@"),
                locale: .current,
                String(localized: String.LocalizationValue(type))
            )
        }
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemGray6).ignoresSafeArea()

        PlaceCardNormalView(place: Place.dummyData[0], isReported: false, isTagVisible: false, isExpanded: .constant(false), isComparing: .constant(false), viewModel: DecideViewModel())
        .padding()
    }
}
