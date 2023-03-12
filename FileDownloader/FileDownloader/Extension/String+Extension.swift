//
//  String+Extension.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import Foundation

/// Easily throw generic errors with a text description.
extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
