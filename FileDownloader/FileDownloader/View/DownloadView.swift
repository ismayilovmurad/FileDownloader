//
//  DownloadView.swift
//  FileDownloader
//
//  Created by Murad Ismayilov on 12.03.23.
//

import SwiftUI

import SwiftUI
import UIKit
import Combine

/// The file download view.
struct DownloadView: View {
    /// The selected file.
    let file: File
    
    @EnvironmentObject var fileFetcher: FileFetcher
    
    /// The downloaded data.
    @State var fileData: Data?
    /// Should display a download activity indicator.
    @State var isDownloadActive = false
    
    // MARK: Store the timer task so you can cancel it when you’re done. The first thing you’d like to do when this flag is set to true or false is to cancel any previously running timer task. Add the following didSet accessor to downloadTask. In downloadTask, you’ll store an asynchronous task that returns no result and could throw an error. Task is a type like any other, so you can also store it in your view, model or any other scope. Task doesn’t return anything if it’s successful, so success is Void; likewise you return an Error if there’s a failure.
    @State var downloadTask: Task<Void, Error>? {
        didSet {
            timerTask?.cancel()
            
            // MARK: If the user just started a new download, you want to note the start time. You’ll use this later to calculate the duration based on the timer’s start time.
            guard isDownloadActive else { return }
            let startTime = Date().timeIntervalSince1970
            
            // MARK: Timer.publish creates a Combine publisher that emits the current date every second. Autoconnect makes the publisher start ticking automatically whenever someone subscribes to it. Map calculates the elapsed time in seconds and returns the duration as a String. Finally, and most importantly, values returns an asynchronous sequence of the publisher’s events, which you can loop over as usual. In fact, you can use for await with any Combine publisher by accessing its values property, which automatically wraps the publisher in an AsyncSequence. Similarly, the Future type in Combine offers an async property called value. This lets you await the future result asynchronously.
            let timerSequence = Timer
                .publish(every: 1, tolerance: 1, on: .main, in: .common)
                .autoconnect()
                .map { date -> String in
                    let duration = Int(date.timeIntervalSince1970 - startTime)
                    return "\(duration)s"
                }
                .values
            
            // MARK: Finally, still in the didSet accessor, add this code to create a new asynchronous task, store it in timerTask and loop over the sequence. Here, you iterate over timerSequence. Inside that loop, you assign each value to self.duration. As mentioned in the beginning of the section, duration is already wired to the UI, so the only thing left to do is test it.
            timerTask = Task {
                for await duration in timerSequence {
                    self.duration = duration
                }
            }
        }
    }
    
    @State var duration = ""
    
    @State var timerTask: Task<Void, Error>?
    
    var body: some View {
        List {
            // Show the details of the selected file and download buttons.
            FileDetails(
                file: file,
                isDownloading: !fileFetcher.downloads.isEmpty,
                isDownloadActive: $isDownloadActive,
                // Silver
                downloadSingleAction: {
                    
                    isDownloadActive = true
                    
                    // MARK: Download a file in a single go. await download(file:) inside the downloadSingleAction closure, which doesn’t accept async code. Running async requests from a non-async context. Task is a type that represents a top-level asynchronous task. Being top-level means it can create an asynchronous context — which can start from a synchronous context. Long story short, any time you want to run asynchronous code from a synchronous context, you need a new Task. We used Task(priority:operation:), which created a new asynchronous task with the operation closure and the given priority. By default, the task inherits its priority from the current context — so you can usually omit it. We need to specify a priority, for example, when you’d like to create a low-priority task from a high-priority context or vice versa.
                    Task {
                        do {
                            fileData = try await fileFetcher.fetchFileSilver(file: file)
                        } catch { }
                        isDownloadActive = false
                    }
                },
                downloadWithUpdatesAction: {
                    // Download a file with UI progress updates.
                    isDownloadActive = true
                    // MARK: This stores the task in downloadTask so you can access it later. Most importantly, it lets you cancel the task manually at will.
                    downloadTask = Task {
                        do {
                            // MARK: Here, you use withValue(_:) to bind whether or not the download supports partial downloads, based on the file’s extension. With the value bound, you call downloadWithProgress(file:). You can bind multiple values this way, and you can also overwrite the values from inner bindings.
                            try await FileFetcher
                                .$supportsPartialDownloads
                                .withValue(file.name.hasSuffix(".jpeg")) {
                                    fileData = try await fileFetcher.fetchFileGold(file: file)
                                }
                        } catch { }
                        isDownloadActive = false
                    }
                },
                downloadMultipleAction: {
                    // MARK: Download a file in multiple concurrent parts.
                    isDownloadActive = true
                    Task {
                        do {
                            fileData = try await fileFetcher.fetchFilePremium(file: file)
                        } catch { }
                        isDownloadActive = false
                    }
                }
            )
            if !fileFetcher.downloads.isEmpty {
                // Show progress for any ongoing downloads.
                DownloadsView(downloads: fileFetcher.downloads)
            }
            
            if !duration.isEmpty {
                Text("Duration: \(duration)")
                    .font(.caption)
            }
            
            if let fileData {
                // Show a preview of the file if it's a valid image.
                FilePreview(fileData: fileData)
            }
        }
        .animation(.easeOut(duration: 0.33), value: fileFetcher.downloads)
        .listStyle(.insetGrouped)
        .toolbar {
            Button(action: {
                // MARK: This time, instead of canceling the download task altogether, like you did in .onDisappear(...), you turn on the stopDownloads flag on SuperStorageModel. You’ll observe this flag while downloading. If it changes to true, you’ll know that you need to cancel your tasks internally.
                fileFetcher.stopDownloads = true
                
                timerTask?.cancel()
            }, label: { Text("Cancel All") })
            .disabled(fileFetcher.downloads.isEmpty)
        }
        // MARK: In here, you reset the file data and invoke reset() on the model too, which clears the download list.
        .onDisappear {
            fileData = nil
            fileFetcher.reset()
            // MARK: Manually cancel the task. Canceling downloadTask will also cancel all its child tasks — and all of their children, and so forth.
            downloadTask?.cancel()
        }
    }
}
