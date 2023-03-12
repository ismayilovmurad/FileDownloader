//
//  FileFetcher.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import Foundation

class FileFetcher: ObservableObject {
    /// The list of currently running downloads.
    @Published var downloads: [DownloadInfo] = []
    
    // MARK: If the user initiates a JPEG download, we’ll set supportsPartialDownloads to true. Task-local properties need to be either static for the type, or global variables. The @TaskLocal property wrapper offers a method called withValue() that allows you to bind a value to an async task — or, simply speaking, inject it into the task hierarchy.
    @TaskLocal static var supportsPartialDownloads = false
    
    func fetchFileSilver(file: File) async throws -> Data {
        
        guard let url = URL(string: "http://localhost:8080/files/download?\(file.name)") else {
            throw "Could not create the URL."
        }
        
        // MARK: Adds the file to the published downloads property of the model class. DownloadView uses it to display the ongoing download statuses onscreen. Offloading the two methods to a specific actor (the main actor or any other actor) requires that you call them asynchronously, which gives the runtime a chance to suspend and resume your call on the correct actor.
        await addDownload(name: file.name)
        
        // MARK: Fetch the file from the server.
        let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
        
        // MARK: Update the progress to 1.0 to indicate the download finished.
        await updateDownload(name: file.name, progress: 1.0)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw "The server responded with an error."
        }
        
        return data
    }
    
    /// Downloads a file, returns its data, and updates the download progress in ``downloads``.
    func fetchFileGold(file: File) async throws -> Data {
        return try await downloadWithProgress(fileName: file.name, name: file.name, size: file.size)
    }
    
    /// Downloads a file, returns its data, and updates the download progress in ``downloads``.
    // MARK: Iterates over the download sequence and collects all the bytes. It then updates the file progress at the end of each batch.
    private func downloadWithProgress(fileName: String, name: String, size: Int, offset: Int? = nil) async throws -> Data {
        
        guard let url = URL(string: "http://localhost:8080/files/download?\(fileName)") else {
            throw "Could not create the URL."
        }
        
        await addDownload(name: name)
        
        // MARK: Unlike before, when we used URLSession.data(for:delegate:) to return Data, we'll use an alternative API that returns URLSession.AsyncBytes. This sequence gives us the bytes it receives from the URL request, asynchronously. If the code specifies an offset, you create a URL request and pass it to URLSession.bytes(for:delegate:), which returns a tuple of the response details and an async sequence that enumerates the bytes of the file.
        let result: (downloadStream: URLSession.AsyncBytes, response: URLResponse)
        
        if let offset = offset {
            
            let urlRequest = URLRequest(url: url, offset: offset, length: size)
            
            result = try await URLSession.shared.bytes(for: urlRequest, delegate: nil)
            
            // MARK: This time, you check if the response code is 206, indicating a successful partial response.
            guard (result.response as? HTTPURLResponse)?.statusCode == 206 else {
                throw "The server responded with an error."
            }
            
        } else { // MARK: Handles a regular, non-partial request, to complete our if statement
            result = try await URLSession.shared.bytes(from: url, delegate: nil)
            
            guard (result.response as? HTTPURLResponse)?.statusCode == 200 else {
                throw "The server responded with an error."
            }
        }
        
        var asyncDownloadIterator = result.downloadStream.makeAsyncIterator()
        var accumulator = ByteAccumulator(name: name, size: size)
        
        while await !stopDownloads, !accumulator.checkCompleted() {
            while !accumulator.isBatchCompleted, let byte = try await asyncDownloadIterator.next() {
                accumulator.append(byte)
            }
            
            let progress = accumulator.progress
            
            // MARK: Generally speaking, the documentation recommends against using Task.detached(...) because it negatively affects the concurrency model’s efficiency. In this case, however, there’s nothing wrong with using it to see how it works. We create the task with a medium priority, so there’s no chance of it slowing down the ongoing download task.
            Task.detached(priority: .medium) {
                await self.updateDownload(name: name, progress: progress)
            }
            
            print(accumulator.description)
        }
        
        // MARK: If Self.supportsPartialDownloads is false, you throw a CancellationError to exit the function with an error. This stops the download immediately. If Self.supportsPartialDownloads is true, you continue the execution and return the partially downloaded file content.
        if await stopDownloads, !Self.supportsPartialDownloads {
            throw CancellationError()
        }
        
        return accumulator.data
    }
    
    /// Downloads a file using multiple concurrent connections, returns the final content, and updates the download progress.
    func fetchFilePremium(file: File) async throws -> Data {
        
        func partInfo(index: Int, of count: Int) -> (offset: Int, size: Int, name: String) {
            let standardPartSize = Int((Double(file.size) / Double(count)).rounded(.up))
            let partOffset = index * standardPartSize
            let partSize = min(standardPartSize, file.size - partOffset)
            let partName = "\(file.name) (part \(index + 1))"
            return (offset: partOffset, size: partSize, name: partName)
        }
        
        let total = 4
        let parts = (0..<total).map { partInfo(index: $0, of: total) }
        
        async let part1 = downloadWithProgress(fileName: file.name, name: parts[0].name, size: parts[0].size, offset: parts[0].offset)
        async let part2 = downloadWithProgress(fileName: file.name, name: parts[1].name, size: parts[1].size, offset: parts[1].offset)
        async let part3 = downloadWithProgress(fileName: file.name, name: parts[2].name, size: parts[2].size, offset: parts[2].offset)
        async let part4 = downloadWithProgress(fileName: file.name, name: parts[3].name, size: parts[3].size, offset: parts[3].offset)
        
        return try await [part1, part2, part3, part4].reduce(Data(), +)
    }
    
    /// Flag that stops ongoing downloads.
    @MainActor var stopDownloads = false
    
    @MainActor func reset() {
        stopDownloads = false
        downloads.removeAll()
    }
}
