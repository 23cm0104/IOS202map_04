//
//  ItemInfoView.swift
//  IOS202map_04
//
//  Created by cmStudent on 2024/06/06.
//

import SwiftUI
import MapKit

struct ItemInfoView: View {
    @State private var lookAroundScene: MKLookAroundScene?
    var selectedResult: MKMapItem
    func getLookAroundScene () {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
        }
    }
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text ("\(selectedResult.name ?? "")")
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding (10)
            }
            .onAppear {
                getLookAroundScene()
            }
            .onChange(of: selectedResult) {
                getLookAroundScene()
            }
    }
}
//
//#Preview {
//    ItemInfoView()
//}
