//
//  PlaceCardExpandView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 13/07/26.
//

import SwiftUI
import Combine

struct PlaceCardExpandView: View {

    let place: Place
    let isChooseThisLocationBtnVisible: Bool
    @Binding var isExpanded: Bool
    @Binding var isComparing: Bool
    @State var viewModel: DecideViewModel
    let onSelectImageIndex: (Int) -> Void
    @Binding var selectedPlace: Place?
    let isDetail: Bool
    let isReported: Bool
    let onReport: () -> Void

    init(
        place: Place,
        isChooseThisLocationBtnVisible: Bool,
        isExpanded: Binding<Bool>,
        isComparing: Binding<Bool>,
        viewModel: DecideViewModel,
        onSelectImageIndex: @escaping (Int) -> Void,
        selectedPlace: Binding<Place?>,
        isDetail: Bool = false,
        isReported: Bool = false,
        onReport: @escaping () -> Void = {}
    ) {
        self.place = place
        self.isChooseThisLocationBtnVisible = isChooseThisLocationBtnVisible
        self._isExpanded = isExpanded
        self._isComparing = isComparing
        self._viewModel = State(initialValue: viewModel)
        self.onSelectImageIndex = onSelectImageIndex
        self._selectedPlace = selectedPlace
        self.isDetail = isDetail
        self.isReported = isReported
        self.onReport = onReport
    }

    // Helper status
    private var isSelected: Bool { viewModel.isSelected(place) }
    private var isCheckDisabled: Bool { viewModel.isCompareLimitReached && !isSelected }

    // Di PlaceCardExpandView.swift
    var body: some View {
        VStack { // 1. Kunci jarak atas-bawah di sini (bukan 0)

            PlaceCardExpandPhotoView(
                isComparing: isComparing,
                isSelected: isSelected,
                isCheckDisabled: isCheckDisabled,
                place: place,
                viewModel: viewModel,
                isDetail: isDetail,
                isReported: isReported,
                onReport: onReport,
                onSelectImageIndex: onSelectImageIndex,
            )

            PlaceCardExpandInfoView(
                place: place, isChooseThisLocationBtnVisible: isChooseThisLocationBtnVisible,
                isExpanded: $isExpanded, selectedPlace: $selectedPlace
            )
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        .transition(.identity)
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemGray6)
            .ignoresSafeArea()

        ScrollView {
            PlaceCardExpandView(
                place: Place.dummyData[0], isChooseThisLocationBtnVisible: false,
                isExpanded: .constant(false),
                isComparing: .constant(true),
                viewModel: DecideViewModel(),
                onSelectImageIndex: { index in },
                selectedPlace: .constant(nil),
            )
            .padding(.horizontal)
            .padding(.vertical)
        }
    }
}
