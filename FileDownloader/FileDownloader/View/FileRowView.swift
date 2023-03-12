//
//  FileRowView.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import SwiftUI

struct FileRowView: View {
    
    let file: File
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(file.name)
                Spacer()
                Image(systemName: "chevron.right")
            }
            HStack {
                Image(systemName: "photo")
                Text(sizeFormatter.string(fromByteCount: Int64(file.size)))
                Text(" ")
                Text(dateFormatter.string(from: file.date))
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.bottom, 10)
            .font(.caption)
            .foregroundColor(Color.primary)
        }
    }
}
