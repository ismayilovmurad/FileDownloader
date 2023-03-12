//
//  File.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import Foundation

struct File: Codable, Identifiable, Equatable {
    var id: String { return name }
    let name: String
    let size: Int
    let date: Date
    static let empty = File(name: "", size: 0, date: Date())
}
