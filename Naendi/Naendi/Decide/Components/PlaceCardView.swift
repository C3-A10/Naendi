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
    @State var viewModel: DecideViewModel
    
    @Binding var isComparing: Bool
    @Binding var selectedImageURL: URL?
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
        selectedImageURL: Binding<URL?>,
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
        self._selectedImageURL = selectedImageURL
        self._selectedPlace = selectedPlace
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if isExpanded {
                    PlaceCardExpandView(place: place, isChooseThisLocationBtnVisible: isChooseThisLocationBtnVisible, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel, selectedImageURL: $selectedImageURL, selectedPlace: $selectedPlace, isDetail: isDetail, isReported: isReported, onReport: onReport)
                } else {
                    PlaceCardNormalView(place: place, mode: mode, isReported: isReported, isTagVisible: isTagVisible, isDetail: isDetail, onReport: onReport, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel)
                }
            }
        }
    }
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
                selectedImageURL: .constant(nil), selectedPlace: .constant(Place.dummyData[0])
            )
            .padding(.vertical)
        }
    }
}
