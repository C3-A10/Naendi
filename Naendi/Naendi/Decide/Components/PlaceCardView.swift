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

/// Shared id for the photo that exists in both card states: the normal card's
/// thumbnail and the expanded gallery's first image are the same URL.
let placeCardHeroImageID = "placeCardHeroImage"

extension View {
    /// Applies the effect only to the hero; other views must stay out of the
    /// namespace entirely rather than hold an unmatched id.
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

    // Height the card should currently occupy. The two subtrees both take part in
    // layout while a transition runs, so the height is driven explicitly instead of
    // letting the container jump to whichever child is taller.
    private var cardHeight: CGFloat? {
        isExpanded ? (expandedHeight ?? collapsedHeight) : collapsedHeight
    }

    var body: some View {
        ZStack(alignment: .top) {
            if isExpanded {
                PlaceCardExpandView(place: place, isChooseThisLocationBtnVisible: isChooseThisLocationBtnVisible, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel, onSelectImageIndex: onSelectImageIndex, selectedPlace: $selectedPlace, isDetail: isDetail, isReported: isReported, onReport: onReport, hero: hero)
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                        guard height > 0 else { return }
                        // First expansion: the height arrives after the toggle's
                        // transaction, so it needs its own animation.
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
        .fixedSize(horizontal: false, vertical: true)   // children keep their natural height while the frame animates
        .frame(height: cardHeight, alignment: .top)
        .clipShape(RoundedRectangle(cornerRadius: isExpanded || mode == .result ? 32 : 20, style: .continuous))
        .shadow(color: Color.black.opacity(isExpanded || mode == .result ? 0.12 : 0.3), radius: 12, x: 0, y: 6)
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
