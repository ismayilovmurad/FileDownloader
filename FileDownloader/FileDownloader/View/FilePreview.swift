//
//  FilePreview.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import SwiftUI

struct FilePreview: View {
    
    let fileData: Data
    
    var body: some View {
        Section("Preview") {
            VStack(alignment: .center) {
                if let image = UIImage(data: fileData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 200)
                        .cornerRadius(10)
                } else {
                    Text("No preview")
                }
            }
        }
    }
}
