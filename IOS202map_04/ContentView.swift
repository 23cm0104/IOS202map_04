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
    
    var body: some View {
        ZStack{
            Map(){
                
            }
        }
        
        VStack{
            List(fetcher.stationList, id: \.self.name){station in
                HStack{
                    Text(station.name)
                    Text(String(station.x))
                    Text(String(station.y))
                }
            }
        }.task {
            try? await fetcher.fetchData(x: 135.0, y: 35.0)
        }
    }
}

#Preview {
    ContentView()
}
