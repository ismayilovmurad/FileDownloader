//
//  UsageQuotaFetcher.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import Foundation

class UsageQuotaFetcher: ObservableObject {
    
    // MARK: Get the user's usage quota
    func fetchUsageQuota() async throws -> String {
        guard let url = URL(string: "http://localhost:8080/files/status") else {
            throw "Could not create the URL."
        }
        
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw "The server responded with an error."
        }
        
        return String(decoding: data, as: UTF8.self)
    }
    
}
