//
//  FileListFetcher.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import Foundation

class FileListFetcher: ObservableObject {
    
    func fetchFileList() async throws -> [File] {
        
        guard let url = URL(string: "http://localhost:8080/files/list") else {
            throw "Could not create the URL."
        }
        
        // MARK: We use the shared URLSession to asynchronously fetch the data from the given URL. It’s vital that you do this asynchronously because doing so lets the system use the thread to do other work while it waits for a response. It doesn’t block others from using the shared system resources. Each time you see the await keyword, think suspension point. The current code will suspend execution. The method you await will execute either immediately or later, depending on the system load. If there are other pending tasks with higher priority, it might need to wait.
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw "The server responded with an error."
        }
        
        guard let list = try? JSONDecoder().decode([File].self, from: data) else {
            throw "The server response was not recognized."
        }
        
        return list
    }
    
}
