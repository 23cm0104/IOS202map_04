//
//  ContentView.swift
//  IOS202map_04
//
//  Created by cmStudent on 2024/05/21.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject var fetcher = StationFetcher()
    @StateObject var locationManager = LocationManager()
    @State var showRoute: MKRoute?
    @State var transportType: MKDirectionsTransportType?
    
    var longitude: Double { return locationManager.currentLocation?.coordinate.longitude ?? 0.00 }
    var latitude: Double { return locationManager.currentLocation?.coordinate.latitude ?? 0.00 }
    
    var body: some View {
            NavigationStack {
                List(fetcher.stationList) { station in
                    NavigationLink(
                        destination: {
                            VStack {
                                HStack {
                                    Text("最寄駅: \(station.name)")
                                    Text("前の駅: \(station.prev ?? "なし")")
                                    Text("次の駅: \(station.next ?? "なし")")
                                }.padding(.top)
                                Text("距離: \(station.distance)")
                                Map() {
                                    UserAnnotation()
                                    Marker("\(station.name)", systemImage: "tram.circle", coordinate: CLLocationCoordinate2D(latitude: station.y, longitude: station.x))
                                    if let showRoute = locationManager.route?.polyline{
                                        MapPolyline(showRoute).stroke(.blue, style: StrokeStyle(lineWidth: 6, dash: [6, 3]))
                                    }
                                }.mapControls {
                                    MapUserLocationButton().mapControlVisibility(.visible)
                                    MapScaleView()
                                }.onAppear {
                                    locationManager.getRoute(from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), to: CLLocationCoordinate2D(latitude: station.y, longitude: station.x), transportType: MKDirectionsTransportType.automobile)
                                }
                                Button(action: {
                                    
                                }, label: {
                                    Label("移動方法を選択する", systemImage: "slider.horizontal.3")
                                }).padding(.top)
                            }
                        }
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
                Button(
                    action: { Task {
                        try? await fetcher.fetchData(longitude: longitude, latitude: latitude)
                    } }
                ) {
                    Label("更新", systemImage: "arrow.clockwise")
                }.padding(.top)
            }.navigationViewStyle(.stack)
        }
    }

#Preview {
    ContentView()
}
