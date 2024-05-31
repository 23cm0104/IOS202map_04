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
    @State var vehicle = 0
    let ways: [MKDirectionsTransportType] = [.automobile, .walking, .any]
    
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
                                let way = ways[vehicle]
                                switch way {
                                case .walking:
                                    locationManager.getRoute(from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), to: CLLocationCoordinate2D(latitude: station.y, longitude: station.x), transportType: MKDirectionsTransportType.walking)
                                case .any:
                                    locationManager.getRoute(from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), to: CLLocationCoordinate2D(latitude: station.y, longitude: station.x), transportType: MKDirectionsTransportType.any)
                                default:
                                    locationManager.getRoute(from: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), to: CLLocationCoordinate2D(latitude: station.y, longitude: station.x), transportType: MKDirectionsTransportType.automobile)
                                }
                            }
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
            HStack{
                Text("移動方法を選択する")
                Spacer()
                Picker(selection: $vehicle, label: Text("移動方法")){
                    Text("オートモード").tag(0)
                    Text("歩いで").tag(1)
                    Text("他の方法").tag(2)
                }
            }.padding(.horizontal)
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
