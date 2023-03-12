//
//  DownloadsView.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import SwiftUI

struct DownloadsView: View {
    
    let downloads: [DownloadInfo]
    
    var body: some View {
        ForEach(downloads) { download in
            VStack(alignment: .leading) {
                Text(download.name).font(.caption)
                ProgressView(value: download.progress)
            }
        }
    }
}
