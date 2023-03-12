//
//  FileFetcher+Extension.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import Foundation

extension FileFetcher {
    // MARK: Adds a new file to the list of ongoing downloads. Thanks to the @MainActor annotation, any calls to those two methods will automatically run on the main actor — and, therefore, on the main thread.
    @MainActor func addDownload(name: String) {
        let downloadInfo = DownloadInfo(id: UUID(), name: name, progress: 0.0)
        downloads.append(downloadInfo)
    }
    
    /// Updates the given file’s progress.
    @MainActor func updateDownload(name: String, progress: Double) {
        if let index = downloads.firstIndex(where: { $0.name == name }) {
            var info = downloads[index]
            info.progress = progress
            downloads[index] = info
        }
    }
}
