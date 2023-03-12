//
//  Formatter.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import Foundation

let sizeFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useMB]
    formatter.isAdaptive = true
    return formatter
}()

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
