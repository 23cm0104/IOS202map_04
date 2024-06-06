//
//  ContentView.swift
//  IOS202map_04
//
//  Created by cmStudent on 2024/05/21.
//

import SwiftUI
import MapKit


struct ContentView: View {
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var position: MapCameraPosition = .automatic
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    
    @StateObject var fetcher = StationFetcher()
    @StateObject var locationManager = LocationManager()
    @State var showRoute: MKRoute?
    @State var transportType: MKDirectionsTransportType?
    @State var vehicle = 0
    let ways: [MKDirectionsTransportType] = [.any, .walking, .automobile, .transit]
    
    var longitude: Double { return locationManager.currentLocation?.coordinate.longitude ?? 0.00 }
    var latitude: Double { return locationManager.currentLocation?.coordinate.latitude ?? 0.00 }
    
    func search(for query: String, y: Double, x: Double) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = visibleRegion ?? MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: y, longitude: x),
            span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)
        )
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }
    var body: some View {
        NavigationStack {
            List(fetcher.stationList) { station in
                NavigationLink(
                    destination: {
                        Map(position: $position, selection: $selectedResult) {
                            UserAnnotation()
                            Marker("最寄駅: \(station.name)駅\n前の駅: \(station.prev ?? "なし")駅\n次の駅: \(station.next ?? "なし")駅\n距離: \(station.distance)\n郵便番号: \(station.postal)\n路線名: \(station.line)", systemImage: "tram.circle", coordinate: CLLocationCoordinate2D(latitude: station.y, longitude: station.x))
                            if let showRoute = locationManager.route?.polyline{
                                MapPolyline(showRoute).stroke(.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [0.5, 10]))
                            }
                            ForEach(searchResults, id: \.self) { result in
                                Marker(item: result)
                            }.annotationTitles(.hidden)
                        }.mapControls {
                            MapUserLocationButton().mapControlVisibility(.visible)
                            MapPitchToggle()
                            MapCompass()
                            MapScaleView().mapControlVisibility(.hidden)
                        }.onAppear {
                            let way = ways[vehicle]
                            switch way {
                            case .walking:
                                transportType = .walking
                            case .automobile:
                                transportType = .automobile
                            case .transit:
                                transportType = .transit
                            default:
                                transportType = .any
                            }
                            locationManager.getRoute(from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), to: CLLocationCoordinate2D(latitude: station.y, longitude: station.x), transportType: transportType ?? .any)
                        }
                        .onMapCameraChange { context in
                            visibleRegion = context.region
                            
                        }
                        .safeAreaInset(edge: .bottom){
                            VStack(spacing: 0){
                                if let selectedResult {
                                    ItemInfoView(selectedResult: selectedResult)
                                        .frame(height: 128)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .padding([.top, .horizontal])
                                }
                                
                                HStack{
                                    Spacer()
                                    Button(action: {
                                        search(for: "parking", y: station.y, x: station.x)
                                    }, label: {
                                        Label("駐車場", systemImage: "car")
                                    }).padding([.top, .trailing])
                                    Button(action: {
                                        search(for: "station", y: station.y, x: station.x)
                                    }, label: {
                                        Label("駅", systemImage: "tram")
                                    }).padding([.top, .trailing])
                                    Spacer()
                                }.background(.thinMaterial)
                            }
                            .onChange(of: searchResults) {
                                position = .automatic
                            }
                        }}
                ){
                    HStack {
                        Text(station.prefecture)
                        Text(station.name)
                        Text(station.line)
                    }
                }
            }
            .task { try? await fetcher.fetchData(longitude: longitude, latitude: latitude) }
            .navigationTitle("最寄駅")
            HStack{
                Text("移動方法を選択する")
                Spacer()
                Picker(selection: $vehicle, label: Text("移動方法")){
                    Text("どれでも").tag(0)
                    Text("歩いで").tag(1)
                    Text("クルマで").tag(2)
                    Text("電車で").tag(3)
                }
            }.padding(.horizontal)
            Button(action: { Task {
                try? await fetcher.fetchData(longitude: longitude, latitude: latitude)
            } }
            ) {
                Label("更新", systemImage: "arrow.clockwise")
            }.padding()
        }.navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}
