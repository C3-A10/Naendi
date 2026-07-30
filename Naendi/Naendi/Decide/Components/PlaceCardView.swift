//
//  PlaceCardView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 13/07/26.
//

//
//  PlaceCardView.swift
//

import SwiftUI

let placeCardHeroImageID = "placeCardHeroImage"

struct PlaceCardTitleBlock: View {
    let place: Place
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(place.nama)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
            HStack(spacing: 6) {
                Image(systemName: "star.fill").foregroundColor(.yellow).font(.body)
                    .accessibilityHidden(true)
                Text("\(place.rating, specifier: "%.1f")").font(.body).fontWeight(.semibold).foregroundColor(.primary)
                    .accessibilityLabel("Rating \(place.accessibilityRatingDescription)")
                Text("•").foregroundColor(.secondary).font(.body)
                Text("(\(place.jumlahReview))").font(.caption).foregroundColor(.secondary)
                    .accessibilityLabel("\(place.accessibilityReviewCountDescription) reviews")
                if isExpanded && place.rangeHarga != "" {
                    Text("•").foregroundColor(.secondary).font(.caption)
                    Text(place.rangeHarga)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

struct PlaceCardTitleSlotKey: PreferenceKey {
    static let defaultValue: [Bool: Anchor<CGRect>] = [:]

    static func reduce(value: inout [Bool: Anchor<CGRect>], nextValue: () -> [Bool: Anchor<CGRect>]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    func placeCardTitleSlot(expanded: Bool) -> some View {
        anchorPreference(key: PlaceCardTitleSlotKey.self, value: .bounds) { [expanded: $0] }
    }
}

extension View {
    @ViewBuilder
    func heroMatch(_ isHero: Bool, id: String, in namespace: Namespace.ID, isSource: Bool = true) -> some View {
        if isHero {
            matchedGeometryEffect(id: id, in: namespace, isSource: isSource)
        } else {
            self
        }
    }
}

struct PlaceCardView: View {
    let place: Place
    let mode: PlaceCardMode
    let isChooseThisLocationBtnVisible: Bool
    let isTagVisible: Bool
    let isReportVisible: Bool
    let isDetail: Bool
    let isReported: Bool
    let onReport: () -> Void
    @State private var isExpanded: Bool = false
    @State private var collapsedHeight: CGFloat?
    @State private var expandedHeight: CGFloat?
    @Namespace private var hero
    @State var viewModel: DecideViewModel

    @Binding var isComparing: Bool
    let onSelectImageIndex: (Int) -> Void
    @Binding var selectedPlace: Place?

    init(
        place: Place,
        mode: PlaceCardMode,
        isChooseThisLocationBtnVisible: Bool,
        isTagVisible: Bool,
        isReportVisible: Bool,
        isDetail: Bool = false,
        isReported: Bool = false,
        onReport: @escaping () -> Void = {},
        viewModel: DecideViewModel,
        isComparing: Binding<Bool>,
        onSelectImageIndex: @escaping (Int) -> Void,
        selectedPlace: Binding<Place?>
    ) {
        self.place = place
        self.mode = mode
        self.isChooseThisLocationBtnVisible = isChooseThisLocationBtnVisible
        self.isTagVisible = isTagVisible
        self.isReportVisible = isReportVisible
        self.isDetail = isDetail
        self.isReported = isReported
        self.onReport = onReport
        self._viewModel = State(initialValue: viewModel)
        self._isComparing = isComparing
        self.onSelectImageIndex = onSelectImageIndex
        self._selectedPlace = selectedPlace
    }

    private var cardHeight: CGFloat? {
        isExpanded ? (expandedHeight ?? collapsedHeight) : collapsedHeight
    }

    var body: some View {
        ZStack(alignment: .top) {
            if isExpanded {
                PlaceCardExpandView(place: place, isChooseThisLocationBtnVisible: isChooseThisLocationBtnVisible, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel, onSelectImageIndex: onSelectImageIndex, selectedPlace: $selectedPlace, isDetail: isDetail, isReported: isReported, onReport: onReport, hero: hero)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                        guard height > 0 else { return }
                        withAnimation(.cardMorph) { expandedHeight = height }
                    }
            } else {
                PlaceCardNormalView(place: place, mode: mode, isReported: isReported, isTagVisible: isTagVisible, isDetail: isDetail, onReport: onReport, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel, hero: hero)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                        guard height > 0 else { return }
                        collapsedHeight = height
                    }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(height: cardHeight, alignment: .top)
        .clipShape(RoundedRectangle(cornerRadius: isExpanded || mode == .result ? 32 : 20, style: .continuous))
        .shadow(color: Color.black.opacity(isExpanded || mode == .result ? 0.12 : 0.3), radius: 12, x: 0, y: 6)
        .overlayPreferenceValue(PlaceCardTitleSlotKey.self) { slots in
            GeometryReader { proxy in
                if let slot = slots[isExpanded] ?? slots[!isExpanded] {
                    let frame = proxy[slot]
                    PlaceCardTitleBlock(place: place, isExpanded: isExpanded)
                        .frame(width: frame.width, height: frame.height, alignment: .topLeading)
                        .offset(x: frame.minX, y: frame.minY)
                        .accessibilitySortPriority(1)
                }
            }
            .animation(.cardMorph, value: isExpanded)
            .allowsHitTesting(false)
            .accessibilityHidden(!isExpanded)
        }
    }
}

extension Animation {
    static let cardMorph = Animation.spring(response: 0.45, dampingFraction: 0.85)
}

#Preview {
    ZStack {
        Color(UIColor.systemGray6)
            .ignoresSafeArea()

        ScrollView {
            PlaceCardView(
                place: Place.dummyData[0],
                mode: .result, isChooseThisLocationBtnVisible: true,
                isTagVisible: true, isReportVisible: true,
                viewModel: DecideViewModel(), isComparing: .constant(true),
                onSelectImageIndex: {index in }, selectedPlace: .constant(Place.dummyData[0])
            )
            .padding(.vertical)
        }
    }
}
