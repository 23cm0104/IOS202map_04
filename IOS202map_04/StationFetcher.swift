//
//  StationFetcher.swift
//  IOS202map_04
//
//  Created by cmStudent on 2024/05/23.
//

import Foundation

class StationFetcher: ObservableObject {
    @Published var stationList: [Station] = []
    
    func fetchData(x: Double, y: Double) async
    throws {
        
        guard let url = URL(string: "https://express.heartrails.com/api/json?method=getStations&x=\(x).0&y=\(y)") else { throw FtetchError.badJSON }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FtetchError.badRequest }
        
        Task { @MainActor in
            stationList = try JSONDecoder().decode(StationResponse.self, from: data).response.station
        }
    }
}

enum FtetchError: Error {
    case badRequest
    case badJSON
}
