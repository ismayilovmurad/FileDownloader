//
//  DownloadInfo.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import Foundation

/// Download information for a given file.
struct DownloadInfo: Identifiable, Equatable {
    let id: UUID
    let name: String
    var progress: Double
}
