//
//  FileDownloaderApp.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import SwiftUI

@main
struct FileDownloaderApp: App {
    var body: some Scene {
        WindowGroup {
            FileListView(fileFetcher: FileFetcher(), fileListFetcher: FileListFetcher(), usageQuotaFetcher: UsageQuotaFetcher())
        }
    }
}
